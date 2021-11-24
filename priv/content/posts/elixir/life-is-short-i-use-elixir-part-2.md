---
title: "Life Is Short I Use Elixir - Part II"
date: 2021-04-25
desc: "Introduction to Meta-programming in Elixir"
tags: ["elixir"]
---

# 元编程 | Meta-programming

本文只能简单介绍一下 Elixir 当中的元编程，因为自己本身也没有怎么用到宏。

按照 Wikipedia，元编程值得是一门编程语言能够操作其程序代码的能力，也就是说可以将代码也视为一种数据类型的能力。如果简单来说，可以把元编程理解为“用代码来生成代码”的能力，很多语言都提供了或多或少的元编程支持。

例如 C 语言的预处理指令宏，C++ 的模板元编程，Java 的通过反射和注解实现的元编程能力等等。

一般人可能仅接触过的 C 语言当中的宏，其只能进行简单的文本替换，虽然如此，但还是能够玩出很多花，比如 [Cello][0] 这个项目，仅仅用 C 语言的宏实现了很多现代化语言的特性。

而 Elixir 当中的宏则更加强大，它实际上提供了直接操纵 AST(Abstract Syntax Tree) 的能力，来看看下面一些代码片段：

```elixir
# 在数据库中创建表
create table(:users) do
 add :username, :string
 add :password, :string
end

# 建立数据库中表所对应的 schema
schema "users" do
  field :username, :string
  field :password_hash, :string
  field :password, :string, virtual: true
end

# 在数据库中查询记录
query = from u in User, where: u.username == "user", select: u
user = Repo.one(query)
user.username # "user
```

上述代码演示使用到了 `Ecto` 这个库，用于与数据库交互的，上述很多实现都依赖于宏。

可以看到，通过宏我们可以很构建出可读性很好的 DSL(Domain Specific Language) 出来。

事实上，连 `defmodule` `def` `for` `in` `if` `case` `with` 这些看上去像是关键字的东西其实都是宏。。。在第一次意识到这点时震惊了好久

## Quote & Unquote

> To Be Continued
> 可能关于宏的这部分不会怎么再写了，因为我自己也不太熟悉 233

[0]: http://libcello.org/
