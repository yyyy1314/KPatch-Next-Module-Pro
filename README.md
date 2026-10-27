# KPatch-Next-Module-Pro

[KPatch-Next-Module](https://github.com/KernelSU-Next/KPatch-Next-Module) 的独立分支，为 Magisk/KernelSU 提供 KPM 管理。内核引擎采用 [KPatch-Next-Pro](https://github.com/yyyy1314/KPatch-Next-Pro)，基于 KernelPatch 0.13.9。

## 使用

下载 Release 中的模块 ZIP，直接在 Magisk/KernelSU 安装。首次启用需要在 WebUI 修补 boot 并重启；请先备份可正常启动的 boot。

仅支持 ARM64，不支持 APatch 或内置 KPM 的内核。模块更新不会自动更新 boot 中的补丁。当前仅验证编译，未验证真机兼容性。

## 构建与发布

Actions → Build → main。普通构建生成可直接安装的 ZIP；勾选 `create_draft` 创建预发布草稿，只上传一个模块 ZIP。

更新时递增 `module/module.prop` 的版本及 `versionCode`。发布 ZIP 后，再更新 `update.json`。升级内核引擎时同步修改工作流中的固定提交。

## 鸣谢

- [KPatch-Next-Module](https://github.com/KernelSU-Next/KPatch-Next-Module)：rifsxd、KOWX712
- [KPatch-Next](https://github.com/KernelSU-Next/KPatch-Next) 及贡献者
- [KernelPatch](https://github.com/bmax121/KernelPatch)：bmax121
- [APatch](https://github.com/bmax121/APatch)：补丁脚本
- [Magisk](https://github.com/topjohnwu/Magisk/tree/v30.6)：magiskboot

## 许可证

模块及 magiskboot：GPL-3.0；内核引擎：GPL-2.0；WebUI：MIT。保留原始版权声明，完整许可证见源码仓库及上游链接。Release 说明提供对应模块与引擎源码提交。
