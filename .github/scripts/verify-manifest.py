#!/usr/bin/env python3
"""Verify payload manifest metadata of a patched OTA against expectations.

Extracts payload.bin from the OTA zip, decodes the DeltaArchiveManifest via
avbroot, then asserts that partition additions/deletions and dynamic
partition group changes are actually reflected in the manifest — not just
in the partition-name list that `avbroot ota list` prints.

Usage:
    verify-manifest.py <test_id> <ota_zip> <avbroot> <baseline_toml> <expect>

    baseline_toml: path to the original OTA's manifest TOML, or "none".
    expect: comma-separated tokens:
        same           partition set must match baseline (minus add/del)
        add:NAME       NAME must be present in manifest.partitions
        del:NAME       NAME must be absent from manifest.partitions
        dyn:NAME       NAME must appear in some dynamic partition group
        ops:NAME       NAME's PartitionUpdate must have >=1 operation
"""
import os
import re
import subprocess
import sys
import tempfile
import zipfile


def extract_payload_bin(ota_zip, dest):
    """Extract payload.bin from the zip (handles non-ASCII paths)."""
    with zipfile.ZipFile(ota_zip) as z:
        names = [n for n in z.namelist() if n.endswith("payload.bin")]
        if not names:
            return None
        with open(dest, "wb") as f:
            f.write(z.read(names[0]))
    return dest


def unpack_manifest(avbroot, payload_bin, toml_path):
    """Run avbroot payload unpack to produce the manifest TOML (no images)."""
    r = subprocess.run(
        [avbroot, "payload", "unpack", "-i", payload_bin,
         "--output-info", toml_path, "--no-output-images", "-q"],
        capture_output=True, text=True,
    )
    return r.returncode, r.stderr


def parse_partitions(toml_path):
    """Return list of (partition_name, op_count) in manifest order.

    op_count is the number of InstallOperation entries found within that
    partition's section. An empty operations array counts as 0.
    """
    results = []
    cur_name = None
    cur_ops = 0
    in_partition = False

    with open(toml_path, encoding="utf-8") as f:
        for line in f:
            stripped = line.strip()

            # New partition section.
            if stripped.startswith("[[manifest.partitions"):
                if cur_name is not None:
                    results.append((cur_name, cur_ops))
                cur_name = None
                cur_ops = 0
                in_partition = True
                continue

            # Any other table/array-of-tables header ends the current partition.
            if (stripped.startswith("[[") or stripped.startswith("[")) and \
                    not stripped.startswith("[[manifest.partitions"):
                if cur_name is not None:
                    results.append((cur_name, cur_ops))
                cur_name = None
                cur_ops = 0
                in_partition = False
                # A nested operations table inside the current partition.
                if stripped.startswith("[[manifest.partitions.operations"):
                    if cur_name is None:
                        # operations table appeared but we lost the parent;
                        # it belongs to the most recent partition.
                        if results:
                            n, c = results.pop()
                            cur_name = n
                            cur_ops = c
                    cur_ops += 1
                    in_partition = True
                continue

            if not in_partition:
                continue

            m = re.match(r'\s*partition_name\s*=\s*"(.+)"', line)
            if m:
                cur_name = m.group(1)
                continue

            # Empty operations array on one line: operations = []
            m2 = re.match(r'\s*operations\s*=\s*\[(.*)\]', line)
            if m2:
                inner = m2.group(1).strip()
                if inner:
                    cur_ops += len(re.findall(r'"([^"]+)"|(\{)', inner))
                # empty [] → 0 ops, nothing to do
                continue

    if cur_name is not None:
        results.append((cur_name, cur_ops))

    return results


def parse_dyn_groups(toml_path):
    """Return {group_name: [partition_name, ...]} from the manifest."""
    groups = {}
    cur_name = None
    in_group = False

    with open(toml_path, encoding="utf-8") as f:
        for line in f:
            stripped = line.strip()

            if stripped.startswith("[[manifest.dynamic_partition_metadata.groups"):
                in_group = True
                cur_name = None
                continue

            if (stripped.startswith("[[") or stripped.startswith("[")) and \
                    not stripped.startswith("[[manifest.dynamic_partition_metadata.groups"):
                in_group = False
                cur_name = None
                continue

            if not in_group:
                continue

            m = re.match(r'\s*name\s*=\s*"(.+)"', line)
            if m:
                cur_name = m.group(1)
                groups.setdefault(cur_name, [])
                continue

            m2 = re.match(r'\s*partition_names\s*=\s*\[(.*)\]', line)
            if m2 and cur_name is not None:
                items = re.findall(r'"([^"]+)"', m2.group(1))
                groups[cur_name].extend(items)

    return groups


def main():
    if len(sys.argv) != 6:
        print("Usage: verify-manifest.py <test_id> <ota_zip> <avbroot> "
              "<baseline_toml> <expect>", file=sys.stderr)
        return 2

    test_id, ota_zip, avbroot, baseline_toml, expect = sys.argv[1:6]

    tmpdir = tempfile.mkdtemp(prefix=f"manifest-{test_id}-")
    payload_bin = os.path.join(tmpdir, "payload.bin")
    manifest_toml = os.path.join(tmpdir, "manifest.toml")

    print(f"=== MANIFEST CHECK {test_id} ===")
    print(f"OTA: {ota_zip}")

    if not extract_payload_bin(ota_zip, payload_bin):
        print(f"FAIL: no payload.bin found in {ota_zip}")
        return 1

    rc, stderr = unpack_manifest(avbroot, payload_bin, manifest_toml)
    if rc != 0:
        print("FAIL: avbroot payload unpack failed")
        print(stderr)
        return 1

    parts = parse_partitions(manifest_toml)
    part_names = [p[0] for p in parts]
    groups = parse_dyn_groups(manifest_toml)
    all_dyn = set()
    for names in groups.values():
        all_dyn.update(names)

    baseline_names = []
    if baseline_toml != "none" and os.path.exists(baseline_toml):
        baseline_names = [p[0] for p in parse_partitions(baseline_toml)]

    # Parse expectation tokens.
    expected_add = []
    expected_del = []
    expected_dyn = []
    expected_ops = []
    expect_same = False
    for token in expect.split(","):
        token = token.strip()
        if token == "same":
            expect_same = True
        elif token.startswith("add:"):
            expected_add.append(token[4:])
        elif token.startswith("del:"):
            expected_del.append(token[4:])
        elif token.startswith("dyn:"):
            expected_dyn.append(token[4:])
        elif token.startswith("ops:"):
            expected_ops.append(token[4:])

    errors = []

    for name in expected_add:
        if name not in part_names:
            errors.append(f"added partition '{name}' not in manifest partitions")

    for name in expected_del:
        if name in part_names:
            errors.append(f"deleted partition '{name}' still in manifest partitions")

    for name in expected_dyn:
        if name not in all_dyn:
            errors.append(f"dynamic partition '{name}' not in any group")

    op_map = dict(parts)
    for name in expected_ops:
        count = op_map.get(name)
        if count is None:
            errors.append(f"partition '{name}' missing; cannot check operations")
        elif count < 1:
            errors.append(f"partition '{name}' has {count} operations (expected >=1)")

    if expect_same and baseline_names:
        baseline_set = set(baseline_names)
        actual_set = set(part_names)
        for name in expected_add:
            baseline_set.discard(name)
            actual_set.discard(name)
        for name in expected_del:
            baseline_set.discard(name)
            actual_set.discard(name)
        extra = actual_set - baseline_set
        missing = baseline_set - actual_set
        if extra:
            errors.append(f"unexpected partitions added vs baseline: {sorted(extra)}")
        if missing:
            errors.append(f"unexpected partitions removed vs baseline: {sorted(missing)}")

    # Summary output.
    print(f"Partitions ({len(part_names)}): {', '.join(part_names)}")
    if groups:
        for gname, pnames in groups.items():
            print(f"  Dynamic group '{gname}': {pnames}")
    else:
        print("  No dynamic partition groups.")
    if baseline_names:
        print(f"Baseline partitions ({len(baseline_names)}): {', '.join(baseline_names)}")

    if errors:
        print()
        for e in errors:
            print(f"FAIL: {e}")
        return 1

    print("OK: manifest assertions passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
