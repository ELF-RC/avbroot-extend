### AVBROOT Extend

English | [中文](README_zh.md)

Original project: <https://github.com/chenxiaolong/avbroot>

AVBROOT Extend is an extended version of the original avbroot with support for more features and command-line options.

## Added features

The features added by AVBROOT Extend are available under `ota patch`:

```text
avbroot
└── ota
    └── patch
        ├── --disable-avb
        ├── --add-partition <PARTITION> <FILE> [SIZE]   repeatable
        ├── --dynamic-partition <PARTITION>             repeatable
        ├── --delete-partition <PARTITION>              repeatable
        └── --temp-dir <DIR>                            overrides TMPDIR
```

- `--disable-avb`: disables AVB verification and hashtree verification in the root `vbmeta` image, allowing `--key-avb` to be omitted. The OTA payload is still signed normally.
- `--add-partition <PARTITION> <FILE> [SIZE]`: adds a full partition image as a new payload `PartitionUpdate`. It can be repeated; when `SIZE` is specified, the image is zero-padded to that size.
- `--dynamic-partition <PARTITION>`: adds the partition name to the first `DynamicPartitionGroup` in the payload metadata. It can be repeated, and every name must match a `PARTITION` supplied to `--add-partition`. This is intended for newly added logical partitions.
- `--delete-partition <PARTITION>`: removes the partition's `PartitionUpdate` from the payload. For logical partitions, it also removes the name from every dynamic partition group; for static partitions, it only stops the OTA from flashing that partition. It can be repeated.
- `--temp-dir <DIR>`: directory for temporary files created during patching. Overrides the `TMPDIR` environment variable, which is useful when patching large OTAs that need several GB of scratch space.

## Contributors
- [ELF-RC](https://github.com/ELF-RC)
- [ChuiShui233](https://github.com/ChuiShui233)
- [chenxiaolong](https://github.com/chenxiaolong)

## Command tree

The following tree is generated from the current Clap command definitions in `avbroot/src/cli`.

```text
avbroot
├── Global options
│   ├── -V, --version
│   ├── --log-level <LEVEL>                         default: info
│   └── --log-format <FORMAT>                       short | medium | long; default: short
│
├── avb
│   ├── unpack
│   │   ├── -i, --input <FILE>                      required
│   │   ├── --output-info <FILE>                    default: avb.toml
│   │   ├── --output-raw <FILE>                     default: raw.img
│   │   ├── --no-output-raw
│   │   ├── --ignore-invalid
│   │   └── -q, --quiet
│   ├── pack
│   │   ├── -o, --output <FILE>                     required
│   │   ├── --input-info <FILE>                     default: avb.toml
│   │   ├── --output-info <FILE>
│   │   ├── --input-raw <FILE>                      default: raw.img
│   │   ├── --recompute-size
│   │   ├── -k, --key <FILE>
│   │   ├── -f, --force
│   │   ├── --pass-env-var <ENV_VAR>
│   │   ├── --pass-file <FILE>
│   │   ├── --signing-helper <PROGRAM>
│   │   ├── --signing-method <METHOD>
│   │   └── -q, --quiet
│   ├── repack
│   │   ├── -i, --input <FILE>
│   │   ├── -o, --output <FILE>
│   │   └── [pack signing and display options]
│   ├── info [alias: dump]
│   │   ├── -i, --input <FILE>
│   │   └── -q, --quiet
│   ├── verify
│   │   ├── -i, --input <FILE>
│   │   ├── -p, --public-key <FILE>
│   │   ├── -r, --repair
│   │   └── --fail-if-missing
│   ├── verify-device [Android only]
│   │   ├── -p, --public-key <FILE>
│   │   └── -P, --partition <NAME>                   default: vbmeta
│   └── digest
│       └── -i, --input <FILE>
│
├── boot
│   ├── Global options: -q, --quiet; -d, --debug
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── --output-header <FILE>                   default: boot.toml
│   │   ├── --output-kernel <FILE>                   default: kernel.img
│   │   ├── --no-output-kernel
│   │   ├── --output-ramdisk-prefix <FILE>           default: ramdisk.img.
│   │   ├── --no-output-ramdisk
│   │   ├── --output-second <FILE>                   default: second.img
│   │   ├── --no-output-second
│   │   ├── --output-recovery-dtbo <FILE>            default: recovery_dtbo.img
│   │   ├── --no-output-recovery-dtbo
│   │   ├── --output-dtb <FILE>                      default: dtb.img
│   │   ├── --no-output-dtb
│   │   ├── --output-vts-signature <FILE>            default: vts_signature.img
│   │   ├── --no-output-vts-signature
│   │   ├── --output-bootconfig <FILE>               default: bootconfig.txt
│   │   └── --no-output-bootconfig
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── --input-header <FILE>                    default: boot.toml
│   │   ├── --input-kernel <FILE>                    default: kernel.img
│   │   ├── --input-ramdisk-prefix <FILE>            default: ramdisk.img.
│   │   ├── --input-second <FILE>                    default: second.img
│   │   ├── --input-recovery-dtbo <FILE>             default: recovery_dtbo.img
│   │   ├── --input-dtb <FILE>                       default: dtb.img
│   │   ├── --input-vts-signature <FILE>             default: vts_signature.img
│   │   └── --input-bootconfig <FILE>                default: bootconfig.txt
│   ├── repack
│   │   ├── -i, --input <FILE>
│   │   └── -o, --output <FILE>
│   ├── info
│   │   └── -i, --input <FILE>
│   └── magisk-info
│       └── -i, --image <FILE>
│
├── completion
│   └── -s, --shell <SHELL>                           bash | elvish | fish | powershell | zsh
│
├── cpio
│   ├── Global option: -q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── --output-info <FILE>                      default: cpio.toml
│   │   ├── --output-tree <DIR>                       default: cpio_tree
│   │   └── --no-output-tree
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── --input-info <FILE>                       default: cpio.toml
│   │   ├── --input-tree <DIR>                        default: cpio_tree
│   │   └── --sort
│   ├── repack
│   │   ├── -i, --input <FILE>
│   │   └── -o, --output <FILE>
│   └── info
│       ├── -i, --input <FILE>
│       └── --trailer
│
├── fec
│   ├── generate
│   │   ├── -i, --input <FILE>
│   │   ├── -f, --fec <FILE>
│   │   └── -p, --parity <BYTES>                      default: 2
│   ├── update
│   │   ├── -i, --input <FILE>
│   │   ├── -f, --fec <FILE>
│   │   └── -r, --range <START> <END>                repeatable
│   ├── verify
│   │   ├── -i, --input <FILE>
│   │   └── -f, --fec <FILE>
│   └── repair
│       ├── -i, --input <FILE>
│       └── -f, --fec <FILE>
│
├── hash-tree
│   ├── generate
│   │   ├── -i, --input <FILE>
│   │   ├── -H, --hash-tree <FILE>
│   │   ├── -b, --block-size <BYTES>                  default: 4096
│   │   ├── -a, --algorithm <NAME>                    default: sha256
│   │   └── -s, --salt <HEX>                          default: empty
│   ├── update
│   │   ├── -i, --input <FILE>
│   │   ├── -H, --hash-tree <FILE>
│   │   └── -r, --range <START> <END>                repeatable
│   └── verify
│       ├── -i, --input <FILE>
│       └── -H, --hash-tree <FILE>
│
├── key
│   ├── generate-key
│   │   ├── -o, --output <FILE>
│   │   ├── -t, --key-type <TYPE>                     rsa2048 | rsa4096 | rsa8192 | mldsa65 | mldsa87
│   │   ├── --pass-env-var <ENV_VAR>
│   │   └── --pass-file <FILE>
│   ├── generate-cert
│   │   ├── -k, --key <FILE>
│   │   ├── --pass-env-var <ENV_VAR>
│   │   ├── --pass-file <FILE>
│   │   ├── -o, --output <FILE>
│   │   ├── -s, --subject <SUBJECT>                   default: CN=avbroot
│   │   └── -v, --validity <DAYS>                     default: 10000
│   ├── encode-avb
│   │   ├── -o, --output <FILE>
│   │   ├── exactly one of: -k, --key <FILE>
│   │   │              or: -p, --public-key <FILE>
│   │   │              or: -c, --cert <FILE>
│   │   ├── --pass-env-var <ENV_VAR>
│   │   └── --pass-file <FILE>
│   ├── decode-avb
│   │   ├── -o, --output <FILE>
│   │   └── -k, --key <FILE>
│   └── extract-avb [hidden compatibility command]
│       └── [same options as encode-avb]
│
├── lp
│   ├── Global option: -q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>                        required; repeatable
│   │   ├── --output-info <FILE>                      default: lp.toml
│   │   ├── --output-images <DIR>                     default: lp_images
│   │   ├── --no-output-images
│   │   └── -s, --slot <NUMBER>
│   ├── pack
│   │   ├── -o, --output <FILE>                       required; repeatable
│   │   ├── --input-info <FILE>                       default: lp.toml
│   │   └── --input-images <DIR>                      default: lp_images
│   ├── repack
│   │   ├── -i, --input <FILE>                        required; repeatable
│   │   ├── -o, --output <FILE>                       required; repeatable
│   │   └── -s, --slot <NUMBER>
│   └── info
│       └── -i, --input <FILE>
│
├── ota
│   ├── patch
│   │   ├── -i, --input <FILE>                        required
│   │   ├── -o, --output <FILE>
│   │   ├── --key-avb <FILE>                          required unless --disable-avb
│   │   │   └── alias: --privkey-avb
│   │   ├── --key-ota <FILE>                          required; alias: --privkey-ota
│   │   ├── --cert-ota <FILE>                         required
│   │   ├── --pass-avb-env-var <ENV_VAR>              alias: --passphrase-avb-env-var
│   │   ├── --pass-avb-file <FILE>                    alias: --passphrase-avb-file
│   │   ├── --pass-ota-env-var <ENV_VAR>              alias: --passphrase-ota-env-var
│   │   ├── --pass-ota-file <FILE>                    alias: --passphrase-ota-file
│   │   ├── --signing-helper <PROGRAM>
│   │   ├── --signing-method <METHOD>
│   │   ├── --replace <PARTITION> <FILE>              repeatable
│   │   ├── --add-partition <PARTITION> <FILE> [SIZE] repeatable
│   │   ├── --delete-partition <PARTITION>           repeatable
│   │   ├── --dynamic-partition <PARTITION>          repeatable; requires --add-partition
│   │   ├── --re-sign <PARTITION>                    repeatable
│   │   ├── exactly one of: --magisk <FILE>
│   │   │              or: --prepatched <FILE>
│   │   │              or: --rootless
│   │   ├── --magisk-preinit-device <PARTITION>
│   │   ├── --magisk-random-seed <NUMBER>
│   │   ├── --ignore-magisk-warnings
│   │   ├── --ignore-prepatched-compat                repeatable counter
│   │   ├── --skip-system-ota-cert
│   │   ├── --skip-recovery-ota-cert
│   │   ├── --dsu
│   │   ├── --clear-vbmeta-flags
│   │   ├── --disable-avb                           conflicts with --clear-vbmeta-flags
│   │   ├── --vabc-algo <ALGO>                       none | lz4 | gz[,LEVEL]
│   │   ├── --zip-mode <MODE>                        streaming | seekable; default: streaming
│   │   ├── --temp-dir <DIR>                         overrides TMPDIR
│   │   └── --boot-partition <PARTITION>              hidden compatibility option
│   ├── extract
│   │   ├── -i, --input <FILE>
│   │   ├── -d, --directory <DIR>                    default: .
│   │   ├── mutually exclusive extraction selection:
│   │   │   ├── -a, --all
│   │   │   ├── -n, --none
│   │   │   └── -p, --partition <PARTITION>          repeatable
│   │   ├── --boot-only                              hidden compatibility option
│   │   ├── --boot-partition <PARTITION>              hidden compatibility option
│   │   ├── --fastboot
│   │   ├── --cert-ota <FILE>
│   │   └── --public-key-avb <FILE>
│   ├── verify
│   │   ├── -i, --input <FILE>
│   │   ├── --cert-ota <FILE>
│   │   ├── --public-key-avb <FILE>
│   │   ├── --skip-recovery-ota-cert
│   │   └── --fail-if-missing
│   └── list
│       └── -i, --input <FILE>
│
├── payload
│   ├── Global option: -q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── --output-info <FILE>                      default: payload.toml
│   │   ├── --output-images <DIR>                     default: payload_images
│   │   ├── --no-output-images
│   │   └── --skeleton
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── -O, --output-properties <FILE>
│   │   ├── --input-info <FILE>                       default: payload.toml
│   │   ├── --input-images <DIR>                      default: payload_images
│   │   ├── -k, --key <FILE>                          required
│   │   ├── --pass-env-var <ENV_VAR>
│   │   ├── --pass-file <FILE>
│   │   ├── --signing-helper <PROGRAM>
│   │   └── --signing-method <METHOD>
│   ├── repack
│   │   ├── -i, --input <FILE>
│   │   ├── -o, --output <FILE>
│   │   ├── -O, --output-properties <FILE>
│   │   └── [same signing options as payload pack]
│   └── info
│       └── -i, --input <FILE>
│
├── sparse
│   ├── Global option: -q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── -o, --output <FILE>
│   │   └── --preserve
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── -i, --input <FILE>
│   │   ├── -b, --block-size <BYTES>                  default: 4096
│   │   └── -r, --region <START> <END>                repeatable
│   ├── repack
│   │   ├── -i, --input <FILE>
│   │   └── -o, --output <FILE>
│   └── info
│       └── -i, --input <FILE>
│
└── zip
    ├── Global option: -q, --quiet
    ├── unpack
    │   ├── -i, --input <FILE>
    │   ├── --output-info <FILE>                      default: ota.toml
    │   ├── --output-files <DIR>                      default: ota_files
    │   ├── --no-output-files
    │   ├── --payload
    │   ├── --output-payload-info <FILE>               requires --payload; default: payload.toml
    │   ├── --output-payload-images <DIR>              requires --payload; default: payload_images
    │   ├── --no-output-payload-images                requires --payload
    │   └── --payload-skeleton                         requires --payload
    ├── pack
    │   ├── -o, --output <FILE>
    │   ├── --input-info <FILE>                       default: ota.toml
    │   ├── --output-info <FILE>
    │   ├── --input-files <DIR>                       default: ota_files
    │   ├── --payload
    │   ├── --input-payload-info <FILE>                requires --payload; default: payload.toml
    │   ├── --input-payload-images <DIR>               requires --payload; default: payload_images
    │   ├── -k, --key <FILE>
    │   ├── -c, --cert <FILE>
    │   ├── --pass-env-var <ENV_VAR>
    │   ├── --pass-file <FILE>
    │   ├── --signing-helper <PROGRAM>
    │   ├── --signing-method <METHOD>
    │   └── --zip-mode <MODE>                         streaming | seekable
    ├── repack
    │   ├── -i, --input <FILE>
    │   ├── -o, --output <FILE>
    │   ├── [same signing options as zip pack]
    │   └── --zip-mode <MODE>
    └── info
        └── -i, --input <FILE>

Hidden compatibility commands:
├── avbroot patch        = avbroot ota patch
├── avbroot extract     = avbroot ota extract
├── avbroot magisk-info = avbroot boot magisk-info
└── avbroot key extract-avb = avbroot key encode-avb
```

All commands also provide `--help`.

This command works for any OTA, regardless if it's patched or unpatched.

If the `--cert-ota` and `--public-key-avb` options are omitted, then the signatures are only checked for validity, not that they are trusted.

## Tab completion

Since avbroot has tons of command line options, it may be useful to set up tab completions for the shell. These configs can be generated from avbroot itself.

#### bash

Add to `~/.bashrc`:

```bash
eval "$(avbroot completion -s bash)"
```

#### zsh

Add to `~/.zshrc`:

```bash
eval "$(avbroot completion -s zsh)"
```

#### fish

Add to `~/.config/fish/config.fish`:

```bash
avbroot completion -s fish | source
```

#### PowerShell

Add to PowerShell's `profile.ps1` startup script:

```powershell
Invoke-Expression (& avbroot completion -s powershell)
```

## Advanced Usage

### Using a prepatched boot image

avbroot can replace the boot image with a prepatched image instead of applying the root patch itself. This is useful for using a boot image patched by the Magisk app or for KernelSU. To use a prepatched Magisk boot image or a KernelSU boot image, pass in `--prepatched <boot image>` instead of `--magisk <apk>`. When using `--prepatched`, avbroot will skip applying the Magisk root patch, but will still apply the OTA certificate patch.

Note that avbroot will validate that the prepatched image is compatible with the original. If, for example, the header fields do not match or a boot image section is missing, then the patching process will abort. The checks are not foolproof, but should help protect against accidental use of the wrong boot image. To bypass a somewhat "safe" subset of the checks, use `--ignore-prepatched-compat`. To ignore all checks (strongly discouraged!), pass it in twice.

### Skipping root patches

avbroot can be used for just re-signing an OTA by specifying `--rootless` instead of `--magisk`/`--prepatched`. With this option, the patched OTA will not be rooted. The only modification applied is the replacement of the OTA verification certificate so that the OS can be upgraded with future (patched) OTAs.

### Skipping OTA certificate patches

avbroot can skip modifying `otacerts.zip` with the `--skip-system-ota-cert` and `--skip-recovery-ota-cert` options. **Do not use these unless you have a good reason to do so.**

When `--skip-system-ota-cert` is used, the OTA certificates in the `system` partition will not be modified. This prevents custom OTA updater apps from installing further patched OTAs while booted into Android.

When `--skip-recovery-ota-cert` is used, the OTA certificates in the `vendor_boot` or `recovery` partition will not be modified. **This prevents sideloading further patched OTAs from recovery mode.**

If `--skip-recovery-ota-cert` is used because the OTA certificate was already manually added to the boot image, then [verifying the patched OTA](#verifying-otas) afterwards is recommended to ensure that it was properly done. The verification process is only capable of checking the boot image's copy of the OTA certificates, not the system image's copy of them.

### Skipping all patches

To have avbroot make the absolute minimal changes:

* Specify `--skip-system-ota-cert`
* Specify `--skip-recovery-ota-cert`
* Specify `--rootless`
* Omit `--dsu`

This will re-sign the `vbmeta` partition and the OTA with the custom keys, but leave all other partitions untouched.

**This should only be used for advanced troubleshooting.** Without the OTA certificate patches, the resulting OTA will not be able to install further updates.

### Replacing partitions

avbroot supports replacing entire partitions in the OTA, even partitions that are not boot images (eg. `vendor_dlkm`). A partition can be replaced by passing in `--replace <partition name> /path/to/partition.img`.

The only behavior this changes is where the partition is read from. When using `--replace`, instead of reading the partition image from the original OTA's `payload.bin`, it is read from the specified file. Thus, the replacement partition images must have proper vbmeta footers, like the originals.

This has no impact on what patches are applied. For example, when using Magisk, the root patch is applied to the boot partition, no matter if the partition came from the original `payload.bin` or from `--replace`.

### Re-signing partitions

avbroot will automatically re-sign any partitions in the OTA that it modifies. However, partitions that are otherwise unmodified can also be re-signed with `--re-sign <partition name>`. This is useful, for example, when the OTA contains partitions signed with the public AOSP test key.

### Booting signed GSIs

Android's [Dynamic System Updates (DSU)](https://developer.android.com/topic/dsu) feature uses a different root of trust than the regular system. Instead of using the bootloader's `avb_custom_key`, it obtains the trusted keys from the `first_stage_ramdisk/avb/*.avbpubkey` files inside the `init_boot` or `vendor_boot` ramdisk. These files are encoded in the same binary format as `avb_pkmd.bin`.

avbroot can add the custom AVB public key to this directory by passing in `--dsu` when patching an OTA. This allows booting [Generic System Images (GSI)](https://developer.android.com/topic/generic-system-image) signed by the custom AVB key.

### Clearing vbmeta flags

Some Android builds may ship with a root `vbmeta` image with the flags set such that AVB is effectively disabled. When avbroot encounters these images, the patching process will fail with a message like:

```
Verified boot is disabled by vbmeta's header flags: 0x3
```

To forcibly enable AVB (by clearing the flags), pass in `--clear-vbmeta-flags`.

### Changing virtual A/B CoW compression algorithm

The virtual A/B CoW compression algorithm can be changed by passing in `--vabc-algo <algo>` with `gz` or `lz4`. OTAs normally use an algorithm that is compatible with the initial version of Android shipped on the device.

* Devices launching with Android 12 support `gz` and `brotli` (unsupported by avbroot)
* Devices launching with Android 14 support `lz4`
* Devices launching with Android 15 support `zstd` (unsupported by avbroot)

Picking a fast algorithm, like lz4, can speed up OTA installation significantly when installing via a custom OTA updater app. However, there is no performance difference when sideloading an OTA from recovery mode.

Note that the currently running version of Android must support the specified compression algorithm or else the OTA will fail to install. For example, trying to install an Android 14 OTA that uses lz4 CoW compression will fail if the running system is Android 13.

### Non-interactive use

avbroot prompts for the private key passphrases interactively by default. To run avbroot non-interactively, either:

* Supply the passphrases via files.

    ```bash
    avbroot ota patch \
        --pass-avb-file /path/to/avb.passphrase \
        --pass-ota-file /path/to/ota.passphrase \
        <...>
    ```

    On Unix-like systems, the "files" can be pipes. With shells that support process substituion (bash, zsh, etc.), the passphrase can be queried from a command (eg. querying a password manager).

    ```bash
    avbroot ota patch \
        --pass-avb-file <(command to query AVB passphrase) \
        --pass-ota-file <(command to query OTA passphrase) \
        <...>
    ```

* Supply the passphrases via environment variables. This is less secure since any process running as the same user can see the environment variable values.

    ```bash
    export PASSPHRASE_AVB="the AVB passphrase"
    export PASSPHRASE_OTA="the OTA passphrase"

    avbroot ota patch \
        --pass-avb-env-var PASSPHRASE_AVB \
        --pass-ota-env-var PASSPHRASE_OTA \
        <...>
    ```

* Use unencrypted private keys. This is strongly discouraged.

### Extracting an OTA

To extract the partition images contained within an OTA's `payload.bin`, run:

```bash
avbroot ota extract \
    --input /path/to/ota.zip \
    --directory extracted
```

By default, this only extracts the images that could potentially be patched by avbroot. To extract all images, use the `--all` option. To extract specific images, use the `--partition <name>` option, which can be specified multiple times.

This command also supports extracting the embedded OTA certificate and AVB public key using the `--cert-ota` and `--public-key-avb` options. To extract only these components, pass in `--none` to skip extracting partition images.

### Listing partitions in OTA

To list all partitions in an OTA, run:

```bash
avbroot ota list --input ota.zip
```

The output format is one partition per line with no formatting.

### Zip write mode

By default, avbroot uses streaming writes for the output OTA during patching. This means it computes the sha256 digest for the digital signature as the file is being written. This mode causes the zip file to contain data descriptors, which is part of the zip standard and works on the vast majority of devices. However, some devices may have broken zip file parsers and fail to properly read OTA zip files containing data descriptors. If this is the case, pass in `--zip-mode seekable` when patching.

The seekable mode writes zip files without data descriptors, but as the name implies, requires seeking around the file instead of writing it sequentially. The sha256 digest for the digital signature is computed after the zip file has been fully written.

### Signing with an external program

avbroot supports delegating all signing operations to an external program with the `--signing-helper` option. When using this option, the `--key-avb` and `--key-ota` options must be given a public key instead of a private key.

For each signing operation, avbroot will invoke the program with:

```bash
<helper> <algorithm> <public key>
```

The algorithm is one of the following:

* `SHA256_RSA2048`
* `SHA256_RSA4096`
* `SHA256_RSA8192`
* `SHA512_RSA2048`
* `SHA512_RSA4096`
* `SHA512_RSA8192`
* `MLDSA65`
* `MLDSA87`

The public key is what was passed to avbroot. The program can use the public key to find the corresponding private key (eg. on a hardware security module).

For RSA signing, avbroot will write a PKCS#1 v1.5 padded digest to `stdin` and the helper program is expected to perform a raw RSA signing operation and write the raw signature (octet string matching key size) to `stdout`.

For ML-DSA signing, avbroot will provide the actual data to sign to `stdin` and the helper program is expected to output the raw ML-DSA signature to `stdout`.

By default, this behavior is compatible with the `--signing_helper` option in AOSP's avbtool. However, avbroot additionally extends the arguments to support non-interactive use. If `--pass-{avb,ota}-file` or `--pass-{avb,ota}-env-var` are used, then the helper program will be invoked with two additional arguments that point to the password file or environment variable.

```bash
<helper> <algorithm> <public key> file <pass file>
# or
<helper> <algorithm> <public key> env <env file>
```

Note that avbroot will verify the signature returned by helper program against the public key. This ensures that the patching process will fail appropriately if the wrong private key was used.

### 16K page size developer option

On recent devices running Android 16 and newer, there may be an option in Android's developer options to switch to a 16K page size kernel. This will not work when running an avbroot-patched OS. The switch internally works by flashing incremental OTAs:

* `/vendor/boot_otas/boot_ota_16k.zip` to switch to the 16K page size kernel (requires the `boot` partition to be currently flashed with the 4K kernel)
* `/vendor/boot_otas/boot_ota_4k.zip` to switch to the 4K page size kernel (requires the `boot` partition to be currently flashed with the 16K kernel)

These `boot_otas` are unflashable when running an avbroot-patched OS because the `payload.bin` inside of them are signed by the OEM's key. These are also not proper OTA files. They don't contain any OTA metadata and the zip file itself is not signed. It's nothing more than a plain old zip file that stores a signed `payload.bin`.

There are no plans to add support for patching these `boot_otas`. It requires support for modifying filesystems and handling incremental OTAs, both of which are very non-trivial.

Folks who are determined to make this work anyway can try these manual steps to sign these `boot_otas` with your own key. Since the incremental OTAs are not being regenerated, the `boot` partition must be left unmodified when running `avbroot ota patch`.

1. Unpack `vendor.img` with avbroot and [afsr](https://github.com/chenxiaolong/afsr).

    ```bash
    avbroot avb unpack -i vendor.img
    afsr unpack -i raw.img
    ```

2. Extract `payload.bin` from `boot_otas/boot_ota_16k.zip`.

3. Re-sign `payload.bin` with your OTA key.

    ```bash
    avbroot payload repack \
        -i payload.bin.orig \
        -o payload.bin \
        -k ota.key \
        --output-properties payload_properties.txt
    ```

4. Create a new zip of `payload.bin` and `payload_properties.txt`. The files must be stored uncompressed (eg. with `zip -0`).

5. Repeat the procedure for `boot_otas/boot_ota_4k.zip`.

6. Repack `vendor.img` and sign it with your AVB key.

    ```bash
    afsr pack -o raw.img
    avbroot avb pack -o vendor.img -k avb.key --recompute-size
    ```

7. Patch the (normal) OTA with:

    ```bash
    avbroot ota patch \
        --replace vendor <modified vendor> \
        <normal arguments...>
    ```

## Building from source

Make sure the [Rust toolchain](https://www.rust-lang.org/) is installed. Then run:

```bash
cargo build --release
```

The output binary is written to `target/release/avbroot`.

Debug builds work too, but they will run significantly slower (in the sha256 computations) due to compiler optimizations being turned off.

### Android cross-compilation

To cross-compile for Android, install [cargo-android](https://github.com/chenxiaolong/cargo-android) and use the `cargo android` wrapper. To make a release build for aarch64, run:

```bash
cargo android build --release --target aarch64-linux-android
```

It is possible to run the tests if the host is running Linux, qemu-user-static is installed, and the executable is built with `RUSTFLAGS=-C target-feature=+crt-static` and `--features static`.

## Verifying digital signatures

To verify the digital signatures of the downloads, follow [the steps here](https://github.com/chenxiaolong/chenxiaolong/blob/master/VERIFY_SSH_SIGNATURES.md).

## Contributing

([AI policy](https://github.com/chenxiaolong/chenxiaolong/blob/master/AI_POLICY.md))

Contributions are welcome! However, I'm unlikely to accept changes for supporting devices that behave significantly differently from Pixel devices.

## License

avbroot is licensed under GPL-3.0-only. Please see [`LICENSE`](./LICENSE) for the full license text.
