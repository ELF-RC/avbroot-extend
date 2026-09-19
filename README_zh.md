### AVBROOT Extend

[English](README.md) | 中文

原项目：<https://github.com/chenxiaolong/avbroot>

AVBROOT Extend 是原版 avbroot 的扩展版本，支持更多功能和命令行参数。

## 新增功能

AVBROOT Extend 新增的功能位于 `ota patch`：

```text
avbroot
└── ota
    └── patch
        ├── --disable-avb
        ├── --add-partition <PARTITION> <FILE> [SIZE]   可重复
        ├── --dynamic-partition <PARTITION>             可重复
        └── --delete-partition <PARTITION>              可重复
```

- `--disable-avb`：关闭根 `vbmeta` 镜像中的 AVB 验证和 hashtree 验证，因此可以省略 `--key-avb`。OTA payload 本身仍会正常签名。
- `--add-partition <PARTITION> <FILE> [SIZE]`：将完整分区镜像作为新的 payload `PartitionUpdate` 添加进去。参数可重复；指定 `SIZE` 时，会用零填充镜像到该大小。
- `--dynamic-partition <PARTITION>`：将分区名写入 payload 元数据中的第一个 `DynamicPartitionGroup`。参数可重复，并且每个名称都必须与 `--add-partition` 提供的某个 `PARTITION` 匹配。该参数用于新增逻辑分区。
- `--delete-partition <PARTITION>`：从 payload 中删除该分区的 `PartitionUpdate`。对于逻辑分区，还会从所有动态分区组中删除该名称；对于静态分区，只是不再由 OTA 刷写该分区。参数可重复。

## 贡献者
- [ELF-RC](https://github.com/ELF-RC)
- [ChuiShui233](https://github.com/ChuiShui233)
- [chenxiaolong](https://github.com/chenxiaolong)

## 命令树

以下命令树根据当前源码 `avbroot/src/cli` 中的 Clap 命令定义整理。

```text
avbroot
├── 全局参数
│   ├── -V, --version
│   ├── --log-level <LEVEL>                         默认：info
│   └── --log-format <FORMAT>                       short | medium | long；默认：short
│
├── avb
│   ├── unpack
│   │   ├── -i, --input <FILE>                      必填
│   │   ├── --output-info <FILE>                    默认：avb.toml
│   │   ├── --output-raw <FILE>                     默认：raw.img
│   │   ├── --no-output-raw
│   │   ├── --ignore-invalid
│   │   └── -q, --quiet
│   ├── pack
│   │   ├── -o, --output <FILE>                     必填
│   │   ├── --input-info <FILE>                     默认：avb.toml
│   │   ├── --output-info <FILE>
│   │   ├── --input-raw <FILE>                      默认：raw.img
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
│   │   └── [同 pack 的签名和显示参数]
│   ├── info [别名：dump]
│   │   ├── -i, --input <FILE>
│   │   └── -q, --quiet
│   ├── verify
│   │   ├── -i, --input <FILE>
│   │   ├── -p, --public-key <FILE>
│   │   ├── -r, --repair
│   │   └── --fail-if-missing
│   ├── verify-device [仅 Android]
│   │   ├── -p, --public-key <FILE>
│   │   └── -P, --partition <NAME>                   默认：vbmeta
│   └── digest
│       └── -i, --input <FILE>
│
├── boot
│   ├── 全局参数：-q, --quiet；-d, --debug
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── --output-header <FILE>                   默认：boot.toml
│   │   ├── --output-kernel <FILE>                   默认：kernel.img
│   │   ├── --no-output-kernel
│   │   ├── --output-ramdisk-prefix <FILE>           默认：ramdisk.img.
│   │   ├── --no-output-ramdisk
│   │   ├── --output-second <FILE>                   默认：second.img
│   │   ├── --no-output-second
│   │   ├── --output-recovery-dtbo <FILE>            默认：recovery_dtbo.img
│   │   ├── --no-output-recovery-dtbo
│   │   ├── --output-dtb <FILE>                      默认：dtb.img
│   │   ├── --no-output-dtb
│   │   ├── --output-vts-signature <FILE>            默认：vts_signature.img
│   │   ├── --no-output-vts-signature
│   │   ├── --output-bootconfig <FILE>               默认：bootconfig.txt
│   │   └── --no-output-bootconfig
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── --input-header <FILE>                    默认：boot.toml
│   │   ├── --input-kernel <FILE>                    默认：kernel.img
│   │   ├── --input-ramdisk-prefix <FILE>            默认：ramdisk.img.
│   │   ├── --input-second <FILE>                    默认：second.img
│   │   ├── --input-recovery-dtbo <FILE>             默认：recovery_dtbo.img
│   │   ├── --input-dtb <FILE>                       默认：dtb.img
│   │   ├── --input-vts-signature <FILE>             默认：vts_signature.img
│   │   └── --input-bootconfig <FILE>                默认：bootconfig.txt
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
│   ├── 全局参数：-q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── --output-info <FILE>                      默认：cpio.toml
│   │   ├── --output-tree <DIR>                       默认：cpio_tree
│   │   └── --no-output-tree
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── --input-info <FILE>                       默认：cpio.toml
│   │   ├── --input-tree <DIR>                        默认：cpio_tree
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
│   │   └── -p, --parity <BYTES>                      默认：2
│   ├── update
│   │   ├── -i, --input <FILE>
│   │   ├── -f, --fec <FILE>
│   │   └── -r, --range <START> <END>                可重复
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
│   │   ├── -b, --block-size <BYTES>                  默认：4096
│   │   ├── -a, --algorithm <NAME>                    默认：sha256
│   │   └── -s, --salt <HEX>                          默认：空字符串
│   ├── update
│   │   ├── -i, --input <FILE>
│   │   ├── -H, --hash-tree <FILE>
│   │   └── -r, --range <START> <END>                可重复
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
│   │   ├── -s, --subject <SUBJECT>                   默认：CN=avbroot
│   │   └── -v, --validity <DAYS>                     默认：10000
│   ├── encode-avb
│   │   ├── -o, --output <FILE>
│   │   ├── 以下三者必须选择一个：-k, --key <FILE>
│   │   │                       或 -p, --public-key <FILE>
│   │   │                       或 -c, --cert <FILE>
│   │   ├── --pass-env-var <ENV_VAR>
│   │   └── --pass-file <FILE>
│   ├── decode-avb
│   │   ├── -o, --output <FILE>
│   │   └── -k, --key <FILE>
│   └── extract-avb [隐藏兼容命令]
│       └── [参数同 encode-avb]
│
├── lp
│   ├── 全局参数：-q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>                        必填；可重复
│   │   ├── --output-info <FILE>                      默认：lp.toml
│   │   ├── --output-images <DIR>                     默认：lp_images
│   │   ├── --no-output-images
│   │   └── -s, --slot <NUMBER>
│   ├── pack
│   │   ├── -o, --output <FILE>                       必填；可重复
│   │   ├── --input-info <FILE>                       默认：lp.toml
│   │   └── --input-images <DIR>                      默认：lp_images
│   ├── repack
│   │   ├── -i, --input <FILE>                        必填；可重复
│   │   ├── -o, --output <FILE>                       必填；可重复
│   │   └── -s, --slot <NUMBER>
│   └── info
│       └── -i, --input <FILE>
│
├── ota
│   ├── patch
│   │   ├── -i, --input <FILE>                        必填
│   │   ├── -o, --output <FILE>
│   │   ├── --key-avb <FILE>                          除非使用 --disable-avb，否则必填
│   │   │   └── 别名：--privkey-avb
│   │   ├── --key-ota <FILE>                          必填；别名：--privkey-ota
│   │   ├── --cert-ota <FILE>                         必填
│   │   ├── --pass-avb-env-var <ENV_VAR>              别名：--passphrase-avb-env-var
│   │   ├── --pass-avb-file <FILE>                    别名：--passphrase-avb-file
│   │   ├── --pass-ota-env-var <ENV_VAR>              别名：--passphrase-ota-env-var
│   │   ├── --pass-ota-file <FILE>                    别名：--passphrase-ota-file
│   │   ├── --signing-helper <PROGRAM>
│   │   ├── --signing-method <METHOD>
│   │   ├── --replace <PARTITION> <FILE>              可重复
│   │   ├── --add-partition <PARTITION> <FILE> [SIZE] 可重复
│   │   ├── --delete-partition <PARTITION>           可重复
│   │   ├── --dynamic-partition <PARTITION>          可重复；需要 --add-partition
│   │   ├── --re-sign <PARTITION>                    可重复
│   │   ├── 以下三者必须选择一个：--magisk <FILE>
│   │   │                       或 --prepatched <FILE>
│   │   │                       或 --rootless
│   │   ├── --magisk-preinit-device <PARTITION>
│   │   ├── --magisk-random-seed <NUMBER>
│   │   ├── --ignore-magisk-warnings
│   │   ├── --ignore-prepatched-compat                可重复计数
│   │   ├── --skip-system-ota-cert
│   │   ├── --skip-recovery-ota-cert
│   │   ├── --dsu
│   │   ├── --clear-vbmeta-flags
│   │   ├── --disable-avb                           与 --clear-vbmeta-flags 互斥
│   │   ├── --vabc-algo <ALGO>                       none | lz4 | gz[,LEVEL]
│   │   ├── --zip-mode <MODE>                        streaming | seekable；默认：streaming
│   │   └── --boot-partition <PARTITION>              隐藏兼容参数
│   ├── extract
│   │   ├── -i, --input <FILE>
│   │   ├── -d, --directory <DIR>                    默认：.
│   │   ├── 以下图像选择参数互斥：
│   │   │   ├── -a, --all
│   │   │   ├── -n, --none
│   │   │   └── -p, --partition <PARTITION>          可重复
│   │   ├── --boot-only                              隐藏兼容参数
│   │   ├── --boot-partition <PARTITION>              隐藏兼容参数
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
│   ├── 全局参数：-q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── --output-info <FILE>                      默认：payload.toml
│   │   ├── --output-images <DIR>                     默认：payload_images
│   │   ├── --no-output-images
│   │   └── --skeleton
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── -O, --output-properties <FILE>
│   │   ├── --input-info <FILE>                       默认：payload.toml
│   │   ├── --input-images <DIR>                      默认：payload_images
│   │   ├── -k, --key <FILE>                          必填
│   │   ├── --pass-env-var <ENV_VAR>
│   │   ├── --pass-file <FILE>
│   │   ├── --signing-helper <PROGRAM>
│   │   └── --signing-method <METHOD>
│   ├── repack
│   │   ├── -i, --input <FILE>
│   │   ├── -o, --output <FILE>
│   │   ├── -O, --output-properties <FILE>
│   │   └── [签名参数同 payload pack]
│   └── info
│       └── -i, --input <FILE>
│
├── sparse
│   ├── 全局参数：-q, --quiet
│   ├── unpack
│   │   ├── -i, --input <FILE>
│   │   ├── -o, --output <FILE>
│   │   └── --preserve
│   ├── pack
│   │   ├── -o, --output <FILE>
│   │   ├── -i, --input <FILE>
│   │   ├── -b, --block-size <BYTES>                  默认：4096
│   │   └── -r, --region <START> <END>                可重复
│   ├── repack
│   │   ├── -i, --input <FILE>
│   │   └── -o, --output <FILE>
│   └── info
│       └── -i, --input <FILE>
│
└── zip
    ├── 全局参数：-q, --quiet
    ├── unpack
    │   ├── -i, --input <FILE>
    │   ├── --output-info <FILE>                      默认：ota.toml
    │   ├── --output-files <DIR>                      默认：ota_files
    │   ├── --no-output-files
    │   ├── --payload
    │   ├── --output-payload-info <FILE>               需要 --payload；默认：payload.toml
    │   ├── --output-payload-images <DIR>              需要 --payload；默认：payload_images
    │   ├── --no-output-payload-images                需要 --payload
    │   └── --payload-skeleton                         需要 --payload
    ├── pack
    │   ├── -o, --output <FILE>
    │   ├── --input-info <FILE>                       默认：ota.toml
    │   ├── --output-info <FILE>
    │   ├── --input-files <DIR>                       默认：ota_files
    │   ├── --payload
    │   ├── --input-payload-info <FILE>                需要 --payload；默认：payload.toml
    │   ├── --input-payload-images <DIR>               需要 --payload；默认：payload_images
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
    │   ├── [签名参数同 zip pack]
    │   └── --zip-mode <MODE>
    └── info
        └── -i, --input <FILE>

隐藏兼容命令：
├── avbroot patch        = avbroot ota patch
├── avbroot extract      = avbroot ota extract
├── avbroot magisk-info  = avbroot boot magisk-info
└── avbroot key extract-avb = avbroot key encode-avb
```

所有命令均支持 `--help`。
