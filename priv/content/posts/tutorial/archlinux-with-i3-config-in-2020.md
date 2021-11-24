---
title: "Archlinux With I3 Config in 2020"
date: 2020-12-05
desc: "2020 年的 ArchLinux i3-wm 配置指南"
tags: ["archlinux", "linux", "i3", "eyecandy"]
---


![ArchLinux with i3 WM](https://i.loli.net/2021/01/23/BCrkQaVDKloiv6y.png)

从刚刚在笔记本上安装好 ArchLinux 时就一直想写这篇文章，记录一下配置的过程，期间一直[忙碌]^(摸鱼), 现在到放寒假了终于抽出时间来写这篇文章，
之前也有写过关于 ArchLinux 下 i3 的简单配置，链接在[这里][0]，随着更新里面的一些内容已经不大适用了，现在重新再写一下，顺带推荐一下一些实用的工具之类的。另外一些配置文件可以在[这里][1]找到。

---

## 准备工作

### 配置软件源

之前一直用的清华的源，但是 pacman 在下载大文件的时候一直会断连，换了其他的源后就好了，换回了以前一直用的中科大的源。

```
Server = http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
```

然后修改一下 pacman 的配置，在 `/etc/pacman.conf` 里把 `#Color` 注释掉，可以开启 pacman 的彩色显示输出，然后在里面添加 archlinuxcn 的源，同样用的中科大的镜像。

```
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
```

之后先安装 `archlinuxcn-keyring` 这个包导入签名，然后 `sudo pacman -S yay` 安装 yay，已死的 yaourt 的替代品，便于安装 AUR 的包。

### 配置代理

个人使用 clash 作为代理工具，直接在官方源中就有，可以直接用 pacman 安装，然后第一次启动会自动在配置目录 `~/.config/clash` 内下载一个 `Country.mmdb` 数据文件，接着将自己代理服务商提供的 `config.yml` 配置文件也放在 `~/.config/clash` 文件夹内，然后自己写一个 systemd 服务实现开机自启。

将下面的配置文件存入 `/etc/systemd/system/clash.service`，注意将 `User` 改为自己的用户名，然后执行 `sudo systemctl enable clash && sudo systemctl start clash` 来启动服务，之后 clash 将会随开机自启。

```conf
[Unit]
Description=Clash service
After=network.target

[Service]
Type=simple
User=tunkshif
ExecStart=/usr/bin/clash
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
```

之后可以用[这个][2] Web UI 作为前端来管理选择代理线路。

因为没有安装完整的桌面环境，缺乏系统层级的代理配置，所以在浏览器中要使用 SwitchyOmega 等扩展来配置代理，或者对于 chrome 可以在命令行内执行 `google-chrome-stable --proxy-server="http://127.0.0.1:7890"` 来配置浏览器的全局代理，对于终端内只需要设置 `export ALL_PROXY=http://127.0.0.1:7890` 即可。

## 桌面环境的安装与配置

### i3 wm

显卡驱动和 Xorg Server 的安装过程略去，直接用 `sudo pacman -S i3` 即可安装整个 i3 group，但要注意的是 `i3-gaps` 是 `i3-wm` 的 fork 项目，提供了窗口边距的支持，只需要安装两者中的一个即可。

![i3 group](https://i.loli.net/2021/01/23/3qTPvLGZzkM7nCQ.png)

接下来自己写配置文件，具体可以参照本文开头提到的旧文。

### i3 blocks

之前的 i3 blocks 是自带一些配置可用的，现在不自带配置方案了，可以在 GitHub 找，例如这个 [Repo][3]。

### 设置开机自启项目

在 i3 的配置文件的最开头写上 `exec --no-start-up-id <command>` 即可。

### 设置壁纸

用 feh 来设置壁纸，首先执行 `feh --bg-scale /path/to/your/wallpaper`，会生成一个 `~/.fehbg` 文件，然后在开机自启项写入 `sh ~/.fehbg` 即可。

### 设置窗口特效

要实现窗口透明、淡入淡出等效果需要单独安装 window compositor，以前用的是 compton，但这个项目不再维护了，现在可以直接安装 fork 自 compton 的 picom，以前的 compton 我记得好像是开箱即用的，但 picom 还需要手动配置。

首先执行 `cp /etc/xdg/picom.conf ~/.config/picom/picom.conf` 复制系统默认配置，然后自行修改配置。

建议按照自己的电脑情况调整配置，有些选项在我电脑上开启后会有非常明显的卡顿和掉帧现象。

个人的配置是 `shadow` 关闭，这个开启后窗口拖动会有残影，`fading` 开启，提供了窗口打开关闭时的淡入淡出的效果，`blur-background` 关闭，然后可以自行设置未聚焦窗口的透明度。

配置好后记得将 picom 加为开机自启。

### 应用启动器

使用 rofi 作为应用启动器，将启动快捷键在 i3 配置中绑定，`Mod+d` 启动选择应用列表，`Mod+Shift+d` 启动命令选择列表

```
bindsym $mod+d exec --no-startup-id "rofi -show drun -show-icons"
bindsym $mod+Shift+d exec --no-startup-id "rofi -show run"
```

![rofi](https://i.loli.net/2021/01/23/HdfgBADlb6WZios.png)

### 通知显示

使用 dunst 作为通知显示，具体效果如下图

![dunst](https://i.loli.net/2021/01/23/I7ErN4qGtb2DuPQ.png)

### 键位映射

我外接的机械键盘的所有的 Fn 键都没法用，查了下可以先装 `xorg-xev` 这个包，运行 `xev`，然后按下 F1 查看下是否能被检测到，如果能的话就可以自己手动将其映射为正确的键位。安装 `xorg-xmodmap` 这个包后，运行 `xmodmap -pke` 可以看到目前的键位映射表，之后按照对应格式将配置写入 `~/.Xmodmap` 即可。

### 主题配置

> _TO BE CONTINUED_

[0]: https://tunkshif.github.io/linux/i3-config.html
[1]: https://github.com/TunkShif/dotfiles
[2]: http://yacd.haishan.me/
[3]: https://github.com/vivien/i3blocks-contrib
