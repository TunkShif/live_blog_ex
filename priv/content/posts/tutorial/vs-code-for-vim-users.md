---
title: VS Code For (Neo)Vim Users
date: 2021-08-23
desc: "Vim extension for better coding experience"
tags: ["configuration", "vscode", "vim", "neovim", "tutorial"]
---

## NeoVim Highlights

从开始习惯用 NeoVim 以及有一段时间了，现在发现已经很难离开 NeoVim，无论是键位的操作上还是 Plugin 的丰富度上，比如下面几个比较难以在 VS Code 上找到替代品的插件

### vim-startify

一个可自定义的启动页面，我在上面展示了自己保存的 `session` 和最近打开的文件，`session` 就相当于将常用的 project 状态保存下来，载入 session 后原来所打开的文件以及所在的工作目录都能恢复。

![](https://i.loli.net/2021/08/23/vPQs9Geqr4ogkFD.png)

### nvim-tree.lua

一个用以展示当前工作目录下的文件树的插件，不同于其它 Editor/IDE 的文件浏览器的是，它其实就是一个 vim 的 `window`，因此像用 `/pattern` 搜索，`gg` `G` 跳转等功能都可以使用。

更重要的是，可以直接用操作文本的几个 `operator` 来操作文件，比如用 `a` 来创建文件或文件夹，用 `r` 来重命名，用 `d` 来删除文件。

由于它仅仅是一个 `window`，我们可以直接使用 `<C-w>h` 和 `<C-w>l` 来在文件管理器窗口和代码编辑窗口跳转。

![](https://i.loli.net/2021/08/23/MGsrkaP23EOJiVD.png)

### telescope

这绝对是一个最让人离不开的插件，它本身是一个类似于 `fzf` 之类的模糊搜索的插件，但是它带来的功能却非常丰富。

比如在当前工作目录下根据文件名进行模糊搜索并即时预览文件内容

![](https://i.loli.net/2021/08/23/4nS3WhqgszMm9E7.png)

浏览最近打开的文件记录

![](https://i.loli.net/2021/08/23/qCf6DgQMHW1UzPV.png)

用 `ripgrep` 模糊搜索文件内容

![](https://i.loli.net/2021/08/23/Qgl8m2b4DrkL9tq.png)

除此之外还有更多查找选项可用

![](https://i.loli.net/2021/08/23/1H82a6UMtAqbVTC.png)

### quick-scope

一个可以说是 Quality of Life 的改善插件，对于经常使用 `f` `t` 在当前行内跳转的人来说非常有用。

它能够在按下 `f` `t` 后高亮显示出当前行内跳转次数最少的位置

![](https://i.loli.net/2021/08/23/u6QImg4FqzYplZn.png)

## Installing VS Code Vim Extension

虽然在 NeoVim 上有很多难以割舍的 plugin，但不管怎么说 VS Code 上的前端开发体验还是要好很多，加上 VS Code 的 Vim 扩展可自定义的功能还算不错，同样在 VS Code 里也能配置出一套使用起来还算可以的 workflow。

另外学习 Vim 键位的操作方式的好处就是，在流行的 IDE 平台上（~~没错，说的就是 JetBrains 家的 IDE~~）上都能找到 Vim 的模拟器扩展，并且最重要的是大多数的 Vim 扩展都能将键位映射到 IDE 原生的功能上去，这样基本可以实现不同 IDE 共用同一套键位配置。

进入正题，首先需要安装 VS Code 的 Vim Extension，然后按下 `Ctrl+,` 进入配置界面，再然后点击右上角的 `Open Settings (JSON)` 按钮，因为按键映射必须要手动编辑配置的 JSON 文件才行。

### 显示微调

我个人习惯开启显示相对行号，也就是像下面这张图一样，光标所在的行显示文件的实际行号，但当前行上下的其它行则显示相对于当前行的行号，这样的好处就是如果我想跳转到下图的 `[python]` 那一行，可以看到它对应的行号是 `7`，我只需要在 NORMAL 模式按下 `7k` 就行了。

![](https://i.loli.net/2021/08/23/teEdP8Kw4iqYguj.png)

另外还有一些显示上的设置，比如高亮显示 yank 的内容，智能显示相对行号（即仅在 NORMAL 和 VISUAL 模式下才显示相对行号）以及高亮显示搜索内容。

```json
{
  "editor.lineNumbers": "relative",
  "vim.highlightedyank.enable": true,
  "vim.smartRelativeLine": true,
  "vim.hlsearch": true
}
```

### 插件功能

VS Code 的 Vim 插件移植了部分 Vim 上非常流行且实用的插件，包括 `vim-surround`，`vim-commentary`，`vim-sneak` 和 `easymotion`。

`vim-surround` 是默认启用的，它提供了操作引号、括号以及 HTML tag 的 operator。

例如为 `word` 加上引号只需要 `ysiw"`，将 `"word"` 当中的双引号改成单引号只需要 `cs"'`。

`vim-commentary` 也是默认启用的，提供了添加或移除代码注释的 operator

只需要 `gcc` 即可注释掉当前行，或者在 VISUAL 模式下选中后 `gc` 来注释选中的部分，配合其它 vim 自带的 motion 也是可以的，比如 `gggcG` 注释掉整个文件。

`vim-sneak` 我测试用起来不太方便，更推荐使用 `easymotion`，这个需要手动在配置里启用，之后可以使用默认绑定的按键来调用。

例如 `<leader><leader>w` 之后，会在每一个 `w` text object 前出现一个 `anchor`，然后只要输入对应的 `anchor` 就能跳转到对应的位置。

这里有一张 easymotion 官方的[动图][0]更能演示效果，但不知道为什么挂不上来

![](https://i.loli.net/2021/08/23/Wm5HCRvoKjDQhYf.png)

除此之外还可以使用 `<leader><leader>j` 和 `<leader><leader>k` 在行间跳转，使用 `<leader><leader>s<char>` 可以搜索跳转到指定字符位置。

另外还有 `<leader><leader>f<char>` 可以在向后搜索跳转，但还是没 `quick-scope` 方便。

![](https://i.loli.net/2021/08/23/WPgxn2AG37eJ9Ly.png)

### 按键映射

VS Code 的 Vim 插件的按键映射配置起来比较麻烦，对应 `nnoremap` 的映射要写在配置文件里的 `vim.normalModeKeyBindingsNonRecursive` 项目里，这是一个数组，具体的一个映射项目类似于下面这样

```json
// 将 <leader>y 映射成为 "+y
{
  "before": ["<leader>", "y"],
  "after": ["\"", "+", "y"]
}

// 将 <leader><esc> 映射成 :nohl
{
  "before": ["<leader>", "<esc>"],
  "commands": [":nohl"]
}
```

配置里面的 `commands` 选项除了支持有限的 vim 本身的命令外，还可以是 VS Code 自己的 action 操作！

例如下面这样把 `K` 映射成显示悬浮信息，效果就等同于把鼠标悬浮弹出的显示

```json
{
  "before": ["K"],
  "commands": ["editor.action.showHover"]
}
```

那么这些 VS Code 自带的命令具体去哪里找呢？只需要进到 Keyboard Shortcuts 界面，然后搜索找到自己想要的操作，右击选择 `Copy Command ID` 即可复制到对应操作的 ID。

![](https://i.loli.net/2021/08/23/SCk92yJsehjAolW.png)

具体的按键映射配置贴在最下面了，下面讲一下具体的映射配置。

首先是复制粘贴，虽然扩展本身提供了一个 `vim.useSystemClipboard` 的选项，让系统的剪切板来接管默认未命名的寄存器，但这会产生一个问题，因为用 `d` 删除操作时，被删除的文本也是会被放到默认的未命名寄存器里面的，而大家一般都会经常使用到删除操作，这就会污染系统的剪切板。

比如说我先从浏览器复制了一段文本在系统的剪切板里，然后进入编辑器用 `d` 操作删除了一段文本，然后用 `p` 粘贴刚刚复制的文本，然而刚刚在进行 `d` 删除操作的时候，被删除的文本又被放进了系统剪切板，粘贴出来的还是刚刚被删掉的文本。。。

所以我改成了使用 `<leader>y` 和 `<leader>p` 来操作系统剪切板，同样还有 `<leader>yy` 复制当前整行内容的支持以及 VISUAL 模式的支持。

另外我习惯用 `[b` 和 `]b` 来切换已经打开的 tab，使用 `<leader>e` 从编辑器面板切换到左侧的文件管理器面板。

由于 VS Code 的 Vim 扩展的限制，在文件管理器面板里**只能**用 `j` `k` 来上下选择文件，在里面的其它按键根本不受 Vim 扩展控制。

因此我只能在 VS Code 自己的快捷键设置里将新建文件设置成 `Ctrl+Shift+n`，因为 `Ctrl+n` 和 Vim 扩展的按键冲突了，然后将 `Views: Focus Next Editor Group` 这个选项设置为 `Ctrl+Shift+Space`，这样可以从文件管理器面板跳转到编辑器面板，然后用默认的 `Delete` 按键删除文件，这样算是得到了一个极简版的 nvim-tree。

之后一些额外的功能我习惯按照以 `<leader> + 分组 + 操作` 的按键来组织管理。

**window**

- `<leader>wt`：*window->terminal* 打开终端
- `<leader>wx`：*window->叉掉* 关闭当前打开的 tab

**code**

- `K`：查看悬浮提示，效果就跟用鼠标悬浮在变量或函数上一样

![](https://i.loli.net/2021/08/23/GPZBY3ne9jsawRv.png)

- `gd`：*goto declaration* 跳转到变量或函数定义或声明处
- `gr`：*goto references* 跳转到变量或函数被引用处
- `<leader>cf`：*code->format* 格式化代码，NORMAL 模式下格式化整个文件，VISUAL 模式下格式化选中的部分
- `<leader>cr`：*code->rename* 变量重命名
- `<leader>ca`: *code->action* 执行 LSP 给出的代码优化或修复建议

**file**

- `<leader>fn`：*file->new* 新建文件
- `<leader>ff`：*file->find* 快速查找文件，代替 Telescope 的功能

这个本身使用了 VS Code 的 `Ctrl+P` 搜索查找文件的功能

![](https://i.loli.net/2021/08/23/a9lV2TBmRZc3I86.png)

## 按键映射配置

```json
"vim.normalModeKeyBindingsNonRecursive": [
  {
    "before": ["<leader>", "y"],
    "after": ["\"", "+", "y"]
  },
  {
    "before": ["<leader>", "p"],
    "after": ["\"", "+", "p"]
  },
  {
    "before": ["<leader>", "P"],
    "after": ["\"", "+", "P"]
  },
  {
    "before": ["[", "b"],
    "after": ["g", "T"]
  },
  {
    "before": ["]", "b"],
    "after": ["g", "t"]
  },
  {
    "before": ["<leader>", "<esc>"],
    "commands": [":nohl"]
  },
  {
    "before": ["K"],
    "commands": ["editor.action.showHover"]
  },
  {
    "before": ["<leader>", "c", "f"],
    "commands": ["editor.action.formatDocument"]
  },
  {
    "before": ["<leader>", "c", "r"],
    "commands": ["editor.action.rename"]
  },
  {
    "before": ["<leader>", "c", "a"],
    "commands": ["editor.action.quickFix"]
  },
  {
    "before": ["<leader>", "w", "t"],
    "commands": ["workbench.action.terminal.toggleTerminal"]
  },
  {
    "before": ["<leader>", "w", "x"],
    "commands": ["workbench.action.closeActiveEditor"]
  },
  {
    "before": ["g", "r"],
    "commands": ["editor.action.goToReferences"]
  },
  {
    "before": ["<Leader>", "e"],
    "commands": ["workbench.explorer.fileView.focus"]
  },
  {
    "before": ["<leader>", "f", "n"],
    "commands": ["explorer.newFile"]
  },
  {
    "before": ["<leader>", "f", "f"],
    "commands": ["workbench.action.quickOpen"]
  }
],
"vim.visualModeKeyBindingsNonRecursive": [
  {
    "before": ["<leader>", "y"],
    "after": ["\"", "+", "y"]
  },
  {
    "before": ["<leader>", "p"],
    "after": ["\"", "+", "p"]
  },
  {
    "before": ["<leader>", "P"],
    "after": ["\"", "+", "P"]
  },
  {
    "before": ["<leader>", "<esc>"],
    "commands": [":nohl"]
  },
  {
    "before": ["<leader>", "c", "f"],
    "commands": ["editor.action.formatDocument"]
  }
]
```

[0]: https://camo.githubusercontent.com/a7ba9f1318ef3a014b52c3fcdc7406c74b6f4d9834d1391342783371a83e4a72/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f333739373036322f323033393335392f61386539333864362d383939662d313165332d383738392d3630303235656138333635362e676966
