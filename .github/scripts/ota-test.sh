#!/usr/bin/env bash
# OTA patch test suite for avbroot-extend.
#
# Tests various --option combinations against a real OTA zip and collects
# logs for every test case.  The script never aborts on error: every test
# runs to completion and its result is recorded in the summary.
#
# Environment variables (all required, set by the workflow):
#   AVBROOT     Path to the avbroot binary.
#   OTA         Path to the source OTA zip.
#   KEYS        Directory containing avb.key, ota.key, ota.crt, avb_pkmd.bin.
#   INPUT_IMG   Directory containing extracted partition images (boot.img).
#   LOGS        Directory where all logs are written.
#   OUTPUT_DIR  Directory for patched OTA zips (cleaned per test).
set +e

AVBROOT="${AVBROOT:?AVBROOT not set}"
OTA="${OTA:?OTA not set}"
KEYS="${KEYS:?KEYS not set}"
INPUT_IMG="${INPUT_IMG:?INPUT_IMG not set}"
LOGS="${LOGS:?LOGS not set}"
OUTPUT_DIR="${OUTPUT_DIR:?OUTPUT_DIR not set}"

PASS_FILE="$KEYS/passphrase.txt"
ORIG_PARTS="$LOGS/partition-list.log"

mkdir -p "$LOGS" "$OUTPUT_DIR"

RESULTS=()
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Pick a non-critical partition for --delete-partition tests.
pick_delete_partition() {
    [ -f "$ORIG_PARTS" ] || return 0
    for p in dsp keymaster multiimgqti qupfw devcfg shrm tz hyp imagefv featenabler; do
        if grep -qx "$p" "$ORIG_PARTS" 2>/dev/null; then
            echo "$p"
            return
        fi
    done
    grep -vE '^(boot|init_boot|vendor_boot|vbmeta|vbmeta_system|system|system_dlkm|vendor|vendor_dlkm|product|system_ext|odm|recovery|dtbo|mi_ext)$' \
        "$ORIG_PARTS" 2>/dev/null | head -1
}

# Run a single test case.
# Usage: run_test <id> <description> <extra_args...>
# Common args (--input, --output, --key-ota, --cert-ota, --pass-ota-file,
# --rootless) are added automatically.
run_test() {
    local id="$1"
    local desc="$2"
    shift 2

    local output="$OUTPUT_DIR/out_${id}.zip"
    local log="$LOGS/test_${id}.log"
    local verify_log="$LOGS/verify_${id}.log"
    local list_log="$LOGS/list_${id}.log"

    rm -f "$output"

    echo ""
    echo "============================================"
    echo "TEST $id: $desc"
    echo "============================================"

    local cmd=(
        "$AVBROOT" ota patch
        --input "$OTA"
        --output "$output"
        --key-ota "$KEYS/ota.key"
        --cert-ota "$KEYS/ota.crt"
        --pass-ota-file "$PASS_FILE"
        --rootless
        "$@"
    )

    {
        echo "=== TEST $id: $desc ==="
        echo "Command: ${cmd[*]}"
        echo "Disk space before:"
        df -h / | tail -1
        echo "Started: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        echo ""
    } > "$log"

    "${cmd[@]}" >> "$log" 2>&1
    local rc=$?

    echo "" >> "$log"
    echo "Exit code: $rc" >> "$log"
    echo "Disk space after:"
    df -h / | tail -1 >> "$log"
    echo "Finished: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$log"

    local status="FAIL"
    local size=0

    if [ "$rc" -eq 0 ] && [ -f "$output" ]; then
        size=$(stat -c %s "$output" 2>/dev/null || echo 0)
        echo "Output: $(ls -lh "$output" | awk '{print $5}') ($size bytes)" >> "$log"

        # Verify OTA signatures.
        {
            echo "=== VERIFY $id ==="
            echo "Command: $AVBROOT ota verify --input $output --cert-ota $KEYS/ota.crt"
            echo ""
            "$AVBROOT" ota verify --input "$output" --cert-ota "$KEYS/ota.crt" 2>&1
            echo "Verify exit code: $?"
        } > "$verify_log"

        # Verify with AVB public key if available.
        if [ -f "$KEYS/avb_pkmd.bin" ]; then
            {
                echo ""
                echo "=== VERIFY $id (with AVB public key) ==="
                echo "Command: $AVBROOT ota verify --input $output --cert-ota $KEYS/ota.crt --public-key-avb $KEYS/avb_pkmd.bin"
                echo ""
                "$AVBROOT" ota verify --input "$output" \
                    --cert-ota "$KEYS/ota.crt" \
                    --public-key-avb "$KEYS/avb_pkmd.bin" 2>&1
                echo "Verify (AVB) exit code: $?"
            } >> "$verify_log"
        fi

        # List partitions in the patched OTA.
        {
            echo "=== PARTITION LIST $id ==="
            "$AVBROOT" ota list --input "$output" 2>&1
        } > "$list_log"

        echo "" >> "$log"
        echo "--- Partition list ---" >> "$log"
        cat "$list_log" >> "$log"
        echo "" >> "$log"
        echo "--- Verify log ---" >> "$log"
        cat "$verify_log" >> "$log"

        status="PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAILED: patch exit code $rc or output missing" >> "$log"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    RESULTS+=("$status | $id | $desc | rc=$rc | size=$size")

    # Cleanup output and temp files.
    rm -f "$output"
    rm -rf /tmp/avbroot-test-temp-*

    echo "Result: $status (rc=$rc, size=$size)"
}

# Skip a test (prerequisite not met).
skip_test() {
    local id="$1"
    local desc="$2"
    local reason="$3"

    echo ""
    echo "TEST $id: $desc — SKIPPED ($reason)"

    {
        echo "=== TEST $id: $desc ==="
        echo "SKIPPED: $reason"
    } > "$LOGS/test_${id}.log"

    RESULTS+=("SKIP | $id | $desc | $reason")
    SKIP_COUNT=$((SKIP_COUNT + 1))
}

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

echo "=== OTA Patch Test Suite ==="
echo "avbroot: $AVBROOT"
echo "OTA: $OTA"
echo ""

# Create a blank block-aligned image for --add-partition tests.
dd if=/dev/zero of="$INPUT_IMG/blank.img" bs=4096 count=1024 status=none
echo "Created blank image: $(ls -lh "$INPUT_IMG/blank.img" | awk '{print $5}')"

DELETE_PART=$(pick_delete_partition)
echo "Delete partition candidate: '$DELETE_PART'"

BOOT_IMG="$INPUT_IMG/boot.img"
if [ ! -f "$BOOT_IMG" ]; then
    echo "WARNING: boot.img not found; some tests will be skipped"
fi

# ---------------------------------------------------------------------------
# Priority 1: payload.py exact patterns
# ---------------------------------------------------------------------------

# T01: payload.py [06] — disable AVB (most common payload.py pattern).
run_test "t01" "payload.py[06] disable-avb + skip-system-ota-cert" \
    --disable-avb --skip-system-ota-cert

# T02: payload.py [04] — full AVB signing (first attempt).
run_test "t02" "payload.py[04] full AVB (first attempt)" \
    --key-avb "$KEYS/avb.key" --pass-avb-file "$PASS_FILE"

# T02b: payload.py [04] retry with --skip-system-ota-cert.
run_test "t02b" "payload.py[04] full AVB + skip-system-ota-cert (retry)" \
    --key-avb "$KEYS/avb.key" --pass-avb-file "$PASS_FILE" \
    --skip-system-ota-cert

# ---------------------------------------------------------------------------
# Priority 2: individual extension parameters
# ---------------------------------------------------------------------------

# T03: --temp-dir (custom temporary directory).
run_test "t03" "--temp-dir (custom temp directory)" \
    --disable-avb --skip-system-ota-cert \
    --temp-dir /tmp/avbroot-test-temp-t03

# T04: --delete-partition.
if [ -n "$DELETE_PART" ]; then
    run_test "t04" "--delete-partition $DELETE_PART" \
        --disable-avb --skip-system-ota-cert \
        --delete-partition "$DELETE_PART"
else
    skip_test "t04" "--delete-partition" "no suitable partition found"
fi

# T05: --replace boot (disable-avb).
if [ -f "$BOOT_IMG" ]; then
    run_test "t05" "--replace boot (disable-avb)" \
        --disable-avb --skip-system-ota-cert \
        --replace boot "$BOOT_IMG"
else
    skip_test "t05" "--replace boot (disable-avb)" "boot.img not found"
fi

# T06: --add-partition (blank image, disable-avb).
run_test "t06" "--add-partition extra_part (blank, disable-avb)" \
    --disable-avb --skip-system-ota-cert \
    --add-partition extra_part "$INPUT_IMG/blank.img"

# T07: --add-partition + --dynamic-partition.
run_test "t07" "--add-partition + --dynamic-partition" \
    --disable-avb --skip-system-ota-cert \
    --add-partition extra_part "$INPUT_IMG/blank.img" \
    --dynamic-partition extra_part

# T08: --replace boot (full AVB).
if [ -f "$BOOT_IMG" ]; then
    run_test "t08" "--replace boot (full AVB)" \
        --key-avb "$KEYS/avb.key" --pass-avb-file "$PASS_FILE" \
        --skip-system-ota-cert \
        --replace boot "$BOOT_IMG"
else
    skip_test "t08" "--replace boot (full AVB)" "boot.img not found"
fi

# ---------------------------------------------------------------------------
# Priority 3: full AVB mode tests
# ---------------------------------------------------------------------------

# T09: --re-sign boot (full AVB).
run_test "t09" "--re-sign boot (full AVB)" \
    --key-avb "$KEYS/avb.key" --pass-avb-file "$PASS_FILE" \
    --skip-system-ota-cert \
    --re-sign boot

# T10: --replace boot + --re-sign boot (full AVB).
if [ -f "$BOOT_IMG" ]; then
    run_test "t10" "--replace + --re-sign boot (full AVB)" \
        --key-avb "$KEYS/avb.key" --pass-avb-file "$PASS_FILE" \
        --skip-system-ota-cert \
        --replace boot "$BOOT_IMG" \
        --re-sign boot
else
    skip_test "t10" "--replace + --re-sign boot" "boot.img not found"
fi

# T11: --add-partition with full AVB (tests vbmeta chain attachment code).
if [ -f "$BOOT_IMG" ]; then
    run_test "t11" "--add-partition extra_part (full AVB, vbmeta chain)" \
        --key-avb "$KEYS/avb.key" --pass-avb-file "$PASS_FILE" \
        --skip-system-ota-cert \
        --add-partition extra_part "$BOOT_IMG"
else
    skip_test "t11" "--add-partition (full AVB)" "boot.img not found"
fi

# T12: --skip-system-ota-cert (full AVB, isolated).
run_test "t12" "--skip-system-ota-cert (full AVB)" \
    --key-avb "$KEYS/avb.key" --pass-avb-file "$PASS_FILE" \
    --skip-system-ota-cert

# ---------------------------------------------------------------------------
# Priority 4: combinations
# ---------------------------------------------------------------------------

# T13: combo — disable-avb + delete + temp-dir + replace.
if [ -f "$BOOT_IMG" ] && [ -n "$DELETE_PART" ]; then
    run_test "t13" "combo: disable-avb + delete + temp-dir + replace" \
        --disable-avb --skip-system-ota-cert \
        --delete-partition "$DELETE_PART" \
        --temp-dir /tmp/avbroot-test-temp-t13 \
        --replace boot "$BOOT_IMG"
else
    skip_test "t13" "combo" "prerequisites not met"
fi

# ---------------------------------------------------------------------------
# Priority 5: payload.py bug detection
# ---------------------------------------------------------------------------

# T14: --super-mode (payload.py uses this instead of --dynamic-partition).
# Expected to FAIL — --super-mode is not a valid avbroot option.
run_test "t14" "--super-mode (expected FAIL: wrong param in payload.py)" \
    --disable-avb --skip-system-ota-cert \
    --add-partition extra_part "$INPUT_IMG/blank.img" \
    --super-mode extra_part

# T15: --fingerprint (payload.py uses this but it was reverted).
# Expected to FAIL — --fingerprint was reverted.
run_test "t15" "--fingerprint (expected FAIL: reverted param)" \
    --disable-avb --skip-system-ota-cert \
    --fingerprint boot "test/fingerprint"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "============================================"
echo "TEST SUMMARY"
echo "============================================"
{
    echo "=== TEST SUMMARY ==="
    echo "Total: ${#RESULTS[@]}"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    echo "Skipped: $SKIP_COUNT"
    echo ""
    for r in "${RESULTS[@]}"; do
        echo "  $r"
    done
} | tee "$LOGS/summary.log"

echo ""
echo "Logs saved to: $LOGS/"
echo "Done."

exit 0
