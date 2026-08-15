# Redmi Note 4X (mido) Debian 13

适用于小米 Redmi Note 4X（代号 `mido`）的无图形 Debian 13 ARM64 镜像。

## 已验证功能

- Debian GNU/Linux 13 (trixie)
- Linux `7.1.3-msm8953`
- lk2nd 二级引导
- eMMC 根文件系统
- USB ECM 网络和 USB ACM 串口
- OpenSSH 与 systemd
- 重启后自动生成并保留 SSH 主机密钥
- 默认禁止 suspend、hibernate、hybrid-sleep 和空闲休眠，适合长期直供电运行

## 默认登录

- 用户名：`root` 或 `admin`
- 密码：`dengpeng`
- USB SSH 地址：`172.16.42.1`
- 兼容地址：`192.168.7.1`

## Release 文件

下载同一 Release 中的以下文件：

- `mido-lk2nd-official-modified.img`
- `mido-debian-7.1.3-modified-boot.img`
- `debian-trixie-arm64-mido-rootfs-modified.sparse.img`
- `mido-debian-7.1.3-stock-fastboot-combined-boot.img`
- `mido-flash-sha256.txt`
- `flash-mido.sh`

手机进入已解锁的 Fastboot，连接电脑后执行 `flash-mido.sh --check` 检查文件，随后执行 `flash-mido.sh --flash`。脚本只会选择产品名为 `mido` 或 `lk2nd-msm8953` 的设备；连接多个手机时不会选择 OnePlus 8T 的 `kona` 产品。原厂 Fastboot 使用组合 Boot 镜像，lk2nd Fastboot 使用独立 lk2nd 与 Boot 镜像。

刷写完成后，Linux 主机 USB 网卡使用 `172.16.42.2/24`，手机地址为 `172.16.42.1`。

系统中的休眠目标和对应服务均已 mask，logind 的按键与空闲动作设为 ignore；CPU 正常空闲节能不受影响。

## 构建与验证

详细的实机写入、Boot 分区读回比对、完整重启和 USB SSH 验证记录见 [`VERIFICATION.txt`](VERIFICATION.txt)。

上游组件及来源见 [`SOURCES.md`](SOURCES.md)。
