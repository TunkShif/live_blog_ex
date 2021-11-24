---
title: A Quick Glance at ADT
date: 2021-08-17
desc: "No type theory version of introduction to Algebraic Data Type"
tags: ["type system", "kotlin", "rust", "ocaml"]
---

今天这里要讲的 ADT 可不是在数据结构里面学到的 *Abstract Data Type*，而是类型系统里面的 *Algebraic Data Type*，也就是代数类型。

代数类型是一种组合类型，也就是说是由其它不同类型结合而成的新类型，正如其名字，代数类型使得类型系统可以变得像代数一样进行运算。

代数类型通常又包括和类型（*sum type*）与积类型（*product type*），在以前大家可能只能在 *Haskell OCaml ...* 之类的函数式编程语言当中能看到 ADT 的使用，但最近 *Rust* 把 ADT 里的 sum type 引入了工业界，或许才让更多的人了解到这一特性（~~虽然早前 `Scala Swift` 等也有 ADT 的支持，但似乎没 `Rust` 这么广泛的流行开~~

所以本文不会以类型论的视角来讲解 ADT，~~因为我也确实不会 type theory~~，只是一个简单的关于 sum type 和 product type 的介绍。

# A Glance at Rust's `enum`

首先来看一些 `Rust` 的例子

```rust
enum Size {
    Small,
    Medium,
    Large,
    Custom(isize)
}

fn main() {
    let small_size = Size::Small;
    let large_size = Size::Large;
    let custom_size = Size::Custom(128);
}
```

```rust
enum Message {
    Start,
    Move { x: i32, y: i32 },
    Into(String),
    Stop,
}

fn main() {
    let start_moving = Message::Start;
    let move_right = Message::Move { x: 5, y: 0 };
    let into_home = Message::Into("home".to_string());
    let stop_moving = Message::Stop;
}
```

我们可以看到 Rust 当中的枚举类型不同于一般 `C/C++ Java` 等语言当中的枚举，Rust 当中的枚举类型是可以给每个枚举变体另外附加上一个数据类型，像 Rust 当中的枚举类型这样的其实就叫做 **sum type**。

**sum type** 有时又叫做 *tagged union*，因为它可以通过给 union 这种结构类型打上 tag 来模拟实现，大概就像下面这个 `C++` 当中的例子

```cpp
union FooUnion {
  bool x;
  string y;
};

enum FooTag {
  BOOL, STRING
};

struct Foo {
  FooTag tag;
  FooUnion data;
};
```

# Start from Couting

下面一些代码示例会用 `OCaml` 写，如果有一门 ML 系语言基础的话相信也能看懂。

首先如果我们把某一类型当作一个集合，属于该类型的值当作该集合当中的元素，那么我们可以数出来该类型集合的元素个数。

例如 `void` 或 `unit` 类型的元素个数为 `0`，`boolean` 类型的元素个数为 `2`

下面定义的 `direction` 类型的元素个数为 `4`

```ocaml
type direction = N | E | S | W
```

## Product Type

**record** 就是一种 product type，也就是其它语言当中的结构体。

如果要计算下面定义的 `point` 类型的集合元素个数，那么就有 $card(point)=card(int)*card(int)$，而 `point` 类型集合当中的元素可以表示为 $point=\{(x, y)|x \in int, y \in int\}$。

实际上 `point` 类型集合就是 `int` 与 `int` 的笛卡尔积（*Cartesian Product*），可以写作 $point=int \times int$，所以这种类型叫做积类型。

```ocaml
type point = { x: int; y: int }
let o = { x=0; y=0 }
let p = { x=1; y=1 }
```

## Sum Type

再看看下面这个例子，我们首先定义的 `direction` 类型含有 4 个元素，接着定义的 `move` 类型包含的元素有 `Direction of N, Direction of E, Direction of S, Direction of W, NotMoving`。

我们可以看到有 $card(move)=card(direction)+1$，或者说 $direction=\{N, E, S, W\};move=direction + \{NotMoving\}$。

```ocaml
type direction = N | E | S | W
type move =
  |Direction of direction
  |NotMoving
```

上面 `OCaml` 的例子写成等价的 `Rust` 代码就像这样的

```rust
enum Direction {
    N, E, S, W
}

enum Move {
    Direction(Direction), NotMoving
}
```

## Genric Types

同样我们可以在 ADT 里面用上泛型，现在 `either` 类型集合的元素个数 $card(either)=card('a)+card('b)$

```ocaml
type ('a, 'b) either =
  |Left of 'a
  |Right of 'b
```

## Recursive Case

有时候在定义类型的时候会递归调用到正在定义的类型，例如下面链表和二叉树的例子

```ocaml
type 'a linked_list =
  |Empty
  |Node of 'a * 'a linked_list;;

type 'a bi_tree =
  |Empty
  |Node of 'a bi_tree * 'a bi_tree
```

至于这个怎么算类型集合的元素个数。。。~~这里就阵亡了不算了吧~~

# ADT Emulation

如果用过 ADT 的同学可能都清楚，这玩意要配合模式匹配用起来才舒服，例如下面一个没什么实际意义的 Rust 示例

```rust
enum Error {
    DivisionByZero
}

fn div(a: f64, b: f64) -> Result<f64, Error> {
    if b == 0.0 {
        Err(Error::DivisionByZero)
    } else {
        Ok(a/b)
    }
}

fn main() {
    match div(3.0, 0.0) {
        Ok(result) => println!("Result is {}", result),
        Err(_) => println!("DivisionByZero error")
    }
}
```

Kotlin 提供了 `sealed class` 的特性以及稍微强于 `switch` 的 `when` 表达式，可以模拟出一个 sum type 的低配版

```kotlin
sealed class Option<out T> {
    data class Some<out T>(val value: T) : Option<T>()
    object None : Option<Nothing>()

    companion object {
        fun <E> from(value: E?): Option<E> =
            value?.let { Some(value) } ?: None
    }
}

fun div(a:Float, b:Float): Option<Float> {
    val result = if (b == 0f) null else a/b
    return Option.from(result)
}

fun main() {
    when (val result = div(3f, 0f)) {
        is Option.Some -> println("3 / 0 = ${result.value}")
        is Option.None -> println("error")
    }
}
```

# Reference

- https://manishearth.github.io/blog/2017/03/04/what-are-sum-product-and-pi-types/
- https://fsharpforfunandprofit.com/posts/type-size-and-design/
- https://en.wikipedia.org/wiki/Algebraic_data_type
