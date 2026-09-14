### AVBROOT Extend

English | [中文](README_zh.md)

Original project: <https://github.com/chenxiaolong/avbroot>

AVBROOT Extend is an extended version of the original avbroot with support for more features and command-line options.

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
