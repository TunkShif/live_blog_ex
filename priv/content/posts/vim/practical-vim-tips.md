---
title: "Practical Vim Tips"
date: 2021-03-05
desc: "原生风格的 Vim 使用技巧"
tags: ["vim"]
---

# Getting Started

Vim Action = Operator + Motion

## Operators

| Trigger | Effect      |
| ------- | ----------- |
| `c`     | Change      |
| `d`     | Delete      |
| `y`     | Yank        |
| `g~`    | Switch case |
| `gu`    | Lowercase   |
| `gU`    | Uppercase   |
| `>`     | Shift right |
| `<`     | Shift left  |
| `=`     | Autoindent  |

### Custom Operator

| Trigger | Effect                                                     | Plugin                                               |
| ------- | ---------------------------------------------------------- | ---------------------------------------------------- |
| `z`     | to the next search result                                  | [vim-sneak](https://github.com/justinmk/vim-sneak)   |
| `s`     | to surround text object with quotes, brackets or HTML tags | [vim-srround](https://github.com/tpope/vim-surround) |

## Motions

### Left-Right Motions

| Trigger   | Effect                                                  |     |     |
| --------- | ------------------------------------------------------- | --- | --- |
| `h`       | characters to the left                                  |     |     |
| `l`       | characters to the left                                  |     |     |
| `0`       | to the first character of the line                      |     |     |
| `^`       | to the first non-blank character of the line            |     |     |
| `$`       | to the end of the line                                  |     |     |
| `f{char}` | to the first occurrence of {char} to the right          |     |     |
| `F{char}` | to the first occurrence of {char} to the left           |     |     |
| `t{char}` | till before the first occurrence of {char} to the right |     |     |
| `T{char}` | till before the first occurrence of {char} to the left  |     |     |

### Up-Down Motions

| Trigger | Effect                                |
| ------- | ------------------------------------- |
| `j`     | line downward linewise                |
| `k`     | line upward linewise                  |
| `gg`    | goto line [count], default first line |
| `G`     | goto line [count], default last line  |

### Word-Motions

| Trigger | Effect                                                |
| ------- | ----------------------------------------------------- |
| `w`     | jump by start of words (punctuation considered words) |
| `W`     | jump by words (spaces separate words)                 |
| `e`     | jump to end of words (punctuation considered words)   |
| `E`     | jump to end of words (no punctuation)                 |
| `b`     | jump to start of words (punctuation considered words) |
| `B`     | jump to start of words (no punctuation)               |

### Text Object Motions

| Trigger | Effect              |
| ------- | ------------------- |
| `(`     | sentences backward  |
| `)`     | sentences forward   |
| `{`     | paragraphs backward |
| `}`     | paragraphs forward  |

### Text Object Selection

| Modifiers | Effect                                                               |
| --------- | -------------------------------------------------------------------- |
| `a`       | a ..., leading or trailing white space is included, but not counted. |
| `i`       | inner ..., white space between words is counted too.                 |

| Object  | Effect              |
| ------- | ------------------- |
| `w` `W` | word                |
| `s`     | sentence            |
| `p`     | paragraph           |
| `[` `]` | bracket block       |
| `{` `}` | brace block         |
| `(` `)` | parenthesis block   |
| `<` `>` | angle bracket block |
| `t`     | html tag block      |
| `"` `'` | quote block         |

# Vim Tips

## Number Increment and Decrement

Pressing <kbd>C-a</kbd> or <kbd>C-x</kbd> to increse or decrease a number by 1. If the current cursor is not a number, it will find the first number of the current line.

## Multiline Operation

Press <kbd>C-v</kbd> to enter Visual-Block mode, then select target lines, then do operation on one line. For insert, use <kbd>I</kbd> to enter insert mode.

## Make Correction in Insert Mode

| Keystrokes     | Effect                    |
| -------------- | ------------------------- |
| <kbd>C-h</kbd> | delete back one character |
| <kbd>C-w</kbd> | delete back one word      |
| <kbd>C-u</kbd> | delete back one line      |

## Go back to Normal Mode in Insert Mode

| Keystrokes     | Effecct                      |
| -------------- | ---------------------------- |
| <kbd>Esc</kbd> | switch to normal mode        |
| <kbd>C-[</kbd> | switch to normal mode        |
| <kbd>C-o</kbd> | switch to insert-normal mode |

In insert-normal mode, we can excute a single command then switch to insert mode immediately.

## Paste from a Register without Leaving Insert Mode

Pressing <kbd>C-r {register}</kbd> in insert mode.

Pressing <kbd>C-r C-p {register}</kbd> to insert text literally and fix any unintended indentation.

## Evaluate an Expression from Register

Pressing <kbd>C-r={expression}</kbd> to evaluate an expression and paste it directly without leaving insert mode.

## Insert Character From ASCII Code or Unicode

From insert mode, type <kbd>C-v{code}</kbd> with a three-digit number to insert a character.

For example, `A` can be inserted with <kbd>C-v065</kbd>.

Unicode characters can be inserted using a four-digit hexademical code.

For example, `¿` can be inserted with <kbd>C-vu00bf</kbd>.

Besides, we can insert character literal by using <kbd>C-v{char}</kbd>.

For example, we can insert a tab with <kbd>C-v&lt;Tab&gt;</kbd>.

## Insert Digraph in Insert Mode

`æ` can be inserted using <kbd>C-vae</kbd>, and `¿` can be inserted using <kbd>C-v?I</kbd>.

## Overwriting Text with Replace Mode

Press `R` to enter replace mode, then the following typed characters will overwrite existing text.

A tab character is visually of multi-character length, but it represents a single character. And replace mode treats a tab as s single character.

In virtual replace mode, triggered by pressing <kbd>gR</kbd>, a tab chracter is treated as multuple characters as in `tabstop` setting.

Use `r{char}` or `gr{char}` to apply a single replacement.

## Selecting with Visual Mode

There're three visual mode variants, character-wise, line-wise and block-wise visual mode, triggered by <kbd>v</kbd> <kbd>V</kbd> <kbd>C-v</kbd> respectively.

In visual mode, one end of the selected text is fixed, and the other moves freely with our cursor. We can use <kbd>o</kbd> to go to the other end of selected text.

Press <kbd>gv</kbd> to reselected the last visual selection.
