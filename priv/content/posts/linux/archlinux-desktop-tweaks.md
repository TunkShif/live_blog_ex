---
title: ArchLinux Desktop Environment Tweaks
date: 2021-08-14
desc: "Optimization for ArchLinux desktop especially WM users"
tags: ["linux"]
---

关于 ArchLinux 桌面用户（尤其是纯 WM 用户）的一些优化。

## 字体渲染

Linux 默认的字体渲染库是 `freetype2`，开箱即用出来的渲染效果糊的跟渣一样，就像下面这图一样

![default font rendering](https://i.loli.net/2021/08/14/nAbPfIK1xe6uaT9.png)

在古早时期有一个叫做 `Infinality` 的项目专门为 `freetype` 做 patch 来获得更好的字体渲染效果，但现在这个项目已经处于 deprecated 的状态，因为以及被合并到 `freetype` 上游了。

然而这个渲染方案在 ArchLinux 当中默认并没有启用，需要手动配置开启。（这很符合 ArchLinux K.I.S.S. 的理念，系统将所有软件包原本的样子提供给你，自己不掺任何私货）

手动编辑 `/etc/profiled.d/freetype.sh` 这个文件，根据注释提示将 `35` 改成 `38`，之后登出或重启一次就能看到效果。

```shell filename=/etc/profiled.d/freetype.sh
# Subpixel hinting mode can be chosen by setting the right TrueType interpreter
# version. The available settings are:
#
#     truetype:interpreter-version=35  # Classic mode (default in 2.6)
#     truetype:interpreter-version=38  # Infinality mode
#     truetype:interpreter-version=40  # Minimal mode (default in 2.7)
#
# There are more properties that can be set, separated by whitespace. Please
# refer to the FreeType documentation for details.

# Uncomment and configure below
export FREETYPE_PROPERTIES="truetype:interpreter-version=38"
```

更改了 `freetype` 的配置方案后的效果如下图，一下子清晰了很多。

![infinality font rendering](https://i.loli.net/2021/08/14/t4mEUMlvrypCFIO.png)

最后还可以再进一步优化，手动配置一下 hinting 和 antialias 啥的，把下面的配置抄进 `~/.config/fontconfig/fonts.conf`，最下面的字体设置可以根据喜好改成自己用的字体。

```xml 
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>

<fontconfig>
    <match target="font">
        <edit mode="assign" name="rgba">
            <const>rgb</const>
        </edit>
        <edit mode="assign" name="hinting">
            <bool>true</bool>
        </edit>
        <edit mode="assign" name="antialias">
            <bool>true</bool>
        </edit>
        <edit mode="assign" name="hintstyle">
            <const>hintslight</const>
        </edit>
        <edit mode="assign" name="lcdfilter">
            <const>lcddefault</const>
        </edit>
    </match>

<alias>
    <family>sans-serif</family>
    <prefer>
        <family>Noto Sans CJK SC</family>
    </prefer>
</alias>

<alias>
    <family>serif</family>
    <prefer>
        <family>Noto Serif CJK SC</family>
    </prefer>
</alias>

<alias>
    <family>monospace</family>
    <prefer>
        <family>Ubuntu Mono</family>
    </prefer>
</alias>

</fontconfig>
```

于是最终的字体渲染效果变成了这样，效果好了很多。


![final font rendering](https://i.loli.net/2021/08/14/FwWAy7G3fb6SYKe.png)

## GUI 应用的 ROOT 提权

有时候一些图形化界面的应用程序需要 root 权限才能正常使用，当然我们可以在终端当中用 `sudo` 执行启动，但会比较麻烦，更方便的操作方式是当我们打开一个需要 root 权限的应用时，应该弹出一个输入密码进行提权的对话框，如下图所示

![authentication prompt](https://i.loli.net/2021/08/14/m6MBN3fhjv2nTIg.png)

这需要安装 `polkit` 包来实现，同时还需要安装一个具体的 `authentication agent` 实现，像 Xfce，Mate 和 Lxde 这些 DE 都有自己的实现，这里推荐安装 `polkit-gnome`，所需要的依赖最少，不需要引入一些其它桌面环境的依赖。

安装之后需要将 `/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1` 开机自启。

## Laptop Touchpad

### 基本配置

对于笔记本的触摸板要想获得比较良好的体验的话，需要自己手动配置一些东西。

首先需要自己安装好对应驱动，让触控板先能够正常使用。但很多默认行为用起来都不大顺手，比如轻触点击的功能默认是关闭的，双指滚动的方向跟屏幕自然滚动的方向是相反的。

如果安装有完整 DE 环境的话，一般在设置中都能进行这些项目的调整，但仅用 WM 的话，需要自己手动写一些配置文件。

首先需要安装 `libinput` 这个包来获得配置输入设备的支持，然后可选安装 `xorg-xinput` 获得一个运行时配置输入设备的命令行工具。（~~Wayland 用户绕道~~）

之后就可以通过 `xinput` 命令来配置输入设备。

```shell
# 列出所有输入设备，找到对应设备的 id
$ xinput --list
⎡ Virtual core pointer                          id=2    [master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
⎜   ↳ ITE Tech. Inc. ITE Device(8910) Keyboard  id=11   [slave  pointer  (2)]
⎜   ↳ MSFT0001:00 04F3:3140 Mouse               id=14   [slave  pointer  (2)]
⎜   ↳ MSFT0001:00 04F3:3140 Touchpad            id=15   [slave  pointer  (2)]
⎣ Virtual core keyboard                         id=3    [master keyboard (2)]
    ↳ Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]
    ↳ Power Button                              id=6    [slave  keyboard (3)]
    ↳ Video Bus                                 id=7    [slave  keyboard (3)]
    ↳ Video Bus                                 id=8    [slave  keyboard (3)]
    ↳ Power Button                              id=9    [slave  keyboard (3)]
    ↳ Integrated Camera: Integrated C           id=10   [slave  keyboard (3)]
    ↳ ITE Tech. Inc. ITE Device(8910) Wireless Radio Control    id=12   [slave  keyboard (3)]
    ↳ Ideapad extra buttons                     id=13   [slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard              id=16   [slave  keyboard (3)]
    ↳ ITE Tech. Inc. ITE Device(8910) Keyboard  id=17   [slave  keyboard (3)]

# 列出目标设备的配置选项
$ xinput --list-props 15
Device 'MSFT0001:00 04F3:3140 Touchpad':
        Device Enabled (154):   1
        Coordinate Transformation Matrix (156): 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000
        libinput Tapping Enabled (309): 1
        libinput Tapping Enabled Default (310): 0
        libinput Tapping Drag Enabled (311):    1
        libinput Tapping Drag Enabled Default (312):    1

# 更改配置选项
$ xinput set-prop <device_id> <prop_id> <value>
```

通过 `xinput` 配置可能会遇到一些问题，在当前 session 结束（注销登出）之后，需要再次重新执行命令重新设置。

当然你可以把上述配置写成 shell 脚本然后开机自启，但是有时候如果你新增了某个输入设备，原本触控板的设备 ID 可能会发生变化，所以最好的配置方法还是手写 Xorg 的配置文件。

`libinput` 默认提供的配置文件在 `/usr/share/X11/xorg.conf.d/40-libinput.conf`，可以供参考，下面是我的触控板配置文件

```conf filename=/etc/X11/xorg.conf.d/30-touchpad.conf
Section "InputClass"
        Identifier "libinput touchpad settings"
        MatchIsTouchpad "on"
        Driver "libinput"
	Option "Tapping" "on"
	Option "NaturalScrolling" "true"
EndSection
```

上面的配置开启了触摸板轻触点击和自然滚动的选项（也就是双指上滑触控板实际上是往下翻页），更多配置选项可以参考 ArchLinux 的相关 [Wiki][0] 页面。

### 手势支持

`libinput-gestures` 这个库提供了触摸板的手势功能支持，比如双指捏合缩放之类的功能，具体安装与配置参考 [GitHub 主页][1]。

同时最好配合 `wmctrl xdotool` 这两个工具一起使用，前者可以用命令行来操作支持 `EWMH` 标准的 WM，后者可以用命令行来模拟组合按键，比如下面的几个例子：

```shell
# 等同于按下 Ctrl+Shift+V 组合键的操作
xdotool key ctrl+shift+v
# 等同于输入了 awesome
xdotool type awesome
```

结合以上工具可以高度定制化自己的手势操作了，比如下面我的配置文件里的例子

```shell
gesture pinch in    xdotool key super+s
gesture pinch out   xdotool key super+t
```

在触摸板上双指往内收缩即等同于按下 <kbd>Super</kbd>+<kbd>S</kbd> 键，是 `bspwm` 里将当前窗口更改为 floating 模式的快捷键。

---

## 参考教程

- [[SOLVED]Let my fonts like Ubuntu.][2]
- [How to make fonts look good on Arch Linux][3]

[0]: https://wiki.archlinux.org/title/Libinput#Via_Xorg_configuration_file
[1]: https://github.com/bulletmark/libinput-gestures
[2]: https://bbs.archlinux.org/viewtopic.php?pid=1683752#p1683752
[3]: https://novelist.xyz/tech/improve-font-rendering-arch-linux-no-infinality/?__cf_chl_managed_tk__=89bd02c0d032131e468aa130d3f2467fe15217a4-1624722544-0-AZs7MqK_Y4dLKCweD-YLBipu0yMJYaLR1oxyBmf-0XsX9MDV3VogT_zsPvS3Cc6KXcqu55heFswQhWM5TUEnv7Kqp1z5y-dNw1REYKCXrGxbhU-pZsgESzmrzvQZLbpkKsxVXbxGNh7GvQVk9a1JXRyA8lzYYKygXJCqyEXfx7kuEVBH4AuNkyUMIxckz8jdktEJ3MlyUQHdK2loCDjvK3h0Zh3Ssq_9otXGmM2tC3l2nUrFt6Odxr-B4BN8zTxTOnm-YtbBmxFakFk5bMPUHh-vj58auqxtmJ5PFzAZI9PcI4b5cCkyigbqstWMltlNEGkrS_Ygs_kEztWRxfy0S1pNGFeWGcLoGabPRTxstG79qYiVv_1_d8wwzZ-xUtcPSP3Q7vSfibEZuJSeftoxWsUiKB9nxMy49If-lhA9DPSxaT67gB6xlRuzAFZjBTpc0lleUaQ_DUo7H1ry_pzjQDYHpqQ2B14Xkh_B15M0LGQAdqA9p48-Iu0-6TKbRiUBCzfwLZDC6Nyn0h2BHezN11K_ALDsPDzmHY2ND3GEAgCW_NMCW92vhd64_QB1YLjLKOMJixc_vfbloIvDDqUDFoS2kkjYE65N3KoKeKAlxXVoeT8xq4gVh0oo7rFYX150Un9qnpPrBTQUMGfcCnw7v7tOACUjbDGRQKG60YV2qTuR
