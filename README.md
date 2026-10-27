# KPatch Next Module — yyyy1314

Independently maintained unofficial derivative by [yyyy1314](https://github.com/yyyy1314), based on [KernelSU-Next/KPatch-Next-Module](https://github.com/KernelSU-Next/KPatch-Next-Module), [KPatch-Next](https://github.com/KernelSU-Next/KPatch-Next), and [KernelPatch](https://github.com/bmax121/KernelPatch). This is not an official upstream release. Original authorship, acknowledgements, and licenses are retained.

Module version: **0.0.1** (`versionCode=1`). Engine: **0.13.9-1**, based on KernelPatch 0.13.9.

## Build and download

The maintained branch is `main`. In Actions, run **Build** on `main`; download `KPatch-Next-Module-0.0.1` from Artifacts and import that ZIP directly into KernelSU/Magisk. The archive root contains `module.prop`, not another ZIP.

To prepare a release, manually run **Build** on `main` with `create_draft` enabled. After a successful build, the workflow creates a draft prerelease with the installable ZIP, module and engine source archives, and SHA-256 checksums. Review the draft before publishing. Workflow credentials are scoped to this repository.

The module reads updates from `main/update.json`. Future releases must increment `versionCode` in both `module/module.prop` and `update.json`, use the same module version, and point to the corresponding published ZIP. Upload release assets before making a newer update manifest available. Do not advertise an unpublished draft as an available upgrade.

## Installation and updates

ARM64 and an existing Magisk/KernelSU root environment are required. APatch and kernels with built-in KPM are unsupported. The patch script currently requires `CONFIG_KALLSYMS_ALL=y`.

Installing or updating this module does not update the patch already embedded in boot. Patching boot requires a separate explicit action and a reboot. Back up a known-working boot image first. Module uninstall does not undo the boot patch.

Module updates preserve `/data/adb/kp-next` and do not hot-replace running tools. A failed automatic KPM load keeps the `.kpm` file. Temporary KPM loads do not survive reboot. Embedded KPMs reside in boot; changing the engine may require rebuilding incompatible KPMs.

Build success confirms compilation only; device boot and KPM compatibility have not been validated. Version 0.0.1 is initially prepared as a prerelease. No migration from earlier experimental packages is provided.

---

## Credits

- Patch scripts from [APatch](https://github.com/bmax121/APatch)
- Engine maintained at [yyyy1314/KPatch-Next](https://github.com/yyyy1314/KPatch-Next), derived from [KernelSU-Next/KPatch-Next](https://github.com/KernelSU-Next/KPatch-Next) and [bmax121/KernelPatch](https://github.com/bmax121/KernelPatch)
- Original module authors: rifsxd and KOWX712; KernelPatch author: bmax121
- magiskboot binary from [Magisk](https://github.com/topjohnwu/Magisk)

## License

- KPatch-Next-Module is licensed under GNU General Public License v3 [GPL-3.0](/LICENSE)
- KPatch-Next binaries is licensed under GNU General Public License v2 [GPL-2.0](https://www.gnu.org/licenses/gpl-2.0.html)
- magiskboot binary from Magisk is licenced under GNU General Public License v3 [GPL-3.0](https://github.com/topjohnwu/Magisk/blob/master/LICENSE)
- WebUI is licensed under MIT License [MIT](/webui/LICENSE)
