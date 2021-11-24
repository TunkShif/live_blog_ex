---
title: A Slightly Deeper Dive into Generics in Kotlin
date: 2021-08-16
desc: "Generics programming and some type things"
tags: ["kotlin", "java", "type system"]
---

这是一篇关于 Kotlin 的泛型的文章，主要会与 Java 进行对比，本来还想写点进一步关于 Type Theroy 的东西，但现在自己相关水平还是太菜了，等继续把 OCaml 啃一段时间再来补充（

# 回顾 Java 当中的泛型

Java 在 1.5 版本才加入了泛型，为了保证所谓的 *backward compability*，其实现的机制使用的是 *type erasure*，这也因此带来了很多在泛型使用上反直觉的问题。

例如下面的例子

```java
List<String> list = new ArrayList<>();
list.add("string");
String first = list.get(0);
```

在 `List<String>` 当中的类型参数 `String` 仅在编译时能获知，而在运行时会被擦除，其存储的类型仍然只是单纯的 `Object`，仅仅是编译器帮我们在使用时做了强制转型来保证类型安全，就像下面这样子

```java
List list = new ArrayList<>();
list.add("string");
String first = (String) list.get(0);
```

因此各个泛型类之间也不存在任何继承关系，例如 `List<Number>` 与 `List<Integer>` 之间就没有任何继承关系，因为在经过泛型擦除之后运行时的参数类型信息已经丢失，因此下面的 Java 代码会产生错误

```java
List<Integer> integers = new ArrayList<>();
List<Number> numbers = integers; // !error
```

为了解决这个问题，Java 引入了 `extends` 和 `super` 通配符，因此上面的代码需要改写成下面这样子

```java
List<Integer> integers = new ArrayList<>();
List<? extends Number> numbers = integers;
```

关于 Java 的泛型机制暂时就回顾到这里，接下来看看 Kotlin 的泛型。

# 使用泛型类

Kotlin 当中的泛型类的定义与 Java 类似，只是在使用的时候，如果泛型参数类型可以被推导，可以省去不写泛型类型。

```kotlin
data class Box<T>(val value: T)
val box = Box(0) // box: Box<Int>
```

# 型变 | Variance

型变（*variance*）这个名词本身是范畴论里面的概念，在编程语言当中它指的是 *how subtyping between more complex types relates to subtyping between their components*，具体举例就是说列表 `List<Cat>` 与 `List<Animal>` 之间有何关系，函数 `f: () -> Cat` 与 `f: () -> Animal` 之间有何关系。

而由于 Java 泛型擦除的机制， Java 当中的泛型类型是不型变（*invariant*）的，也就是说 `List<Cat>` 并不是 `List<Animal>` 的子类型，它们之间没有任何关系。

泛型类型在实际运行时当中就仅仅是 `Object`，只是在编译时阶段，编译器为我们做了许多类型安全的检查。

例如观察下面一段代码

```java
List<String> strs = new ArrayList<String>();
List<Object> objs = strs; // 产生编译时错误
objs.add(1);
String s = strs.get(0); // 试图将 Integer 强制转型为 String 而抛出异常
```

`String` 是 `Object` 的子类，尽管将 `List<String>` 转型成为 `List<Object>` 是 make sense 的，但编译器会禁止我们这样做，以避免潜在的运行时错误，但这也会产生一些别的影响

例如再下面的一个例子

```java
interface Collection<E> {
    void addAll(Collection<E> items);
}

void copyAll(Collection<Object> to, Collection<String> from) {
    to.addAll(from);
}
```

上面的代码从直觉上来看完全没问题，事实上也完全是安全的，因为把 `String` 的集合加到其超类 `Object` 的集合当中是没什么问题的，但实际上 Java 的编译器不允许我们这样做，因为 `Collection<String>` 并不是 `Collection<Object>` 的子类型。

要达到实际预期效果的话，上面的接口定义得改成下面这样

```java
interface Collection<E> {
    void addAll(Collection<? extends E> items);
}
```

上面的通配符 `? extends E` 表示 items 不仅可以接受 `E` 类型的集合，也可以接受 `E` 类型的子类的集合，这样我们能够安全地读取 `items` 当中 `E` 类型的元素，但不能写入，因为我们不知道其中具体的子类类型。

现在 `Collection<String>` 即是 `Collection<? extends Object>` 的子类型（看清楚这里说的是***类型***而不是***类***），也就是说 `extends` 通配符让该类型成为协变的（*covariant*）。

因此，将 `Collection<String>` 当中的元素读取成为 `Object` 是安全的，相反，向 `Collection<Object>` 当中放入 `String` 类型的元素也是安全的，在 Java 当中 `Collection<? super String>` 是 `Collection<Object>` 的超类型，即 `super` 通配符让类型变为逆变的（*contravariance*）。

*Effective Java* 的作者 Joshua Bloch 将仅能读取的对象命名为**生产者**（*producer*），将仅仅能进行写入操作的对象命名为**消费者**（*comsumer*），然后提出了以下建议：

<Admonition title="PECS" type="info" open>
"For maximum flexibility, use wildcard types on input parameters that represent producers or consumers", and proposes the following mnemonic:

PECS stands for Producer-Extends, Consumer-Super.
</Admonition>

# 声明处型变 | Declaration-Site Variance

不同于 Java 使用 `extends` 和 `super` 通配符来声明型变，Kotlin 引入了 `in` 和 `out` 两个关键字来声明型变。（~~从 C# 抄来的~~

事实上Java 的 `extends` 还有限定泛型类型的作用，Kotlin 里面是另外的语法实现该语义

下面的例子仍然会产生错误，因为默认不加任何修饰的泛型类 `T` 是不型变的

```kotlin
data class Box<T>(val value: T)
val box: Box<Number> = Box(0) // !error
```

只需要在泛型参数 `T` 前加上 `out` 修饰即可表明该类型为协变的，下面的代码即变得合法

```kotlin
data class Box<out T>(val value: T)
val box: Box<Number> = Box(0)
```

只需要根据上面提到的生产者-消费者模型，可以便于记忆 `in` `out` 的使用

定义几个有继承关系的类如下

```kotlin
open class Item
open class Tool : Item()
class Pickaxe : Tool()
```

一个使用生产者的例子如下，即将泛型类型作为函数的输出

```kotlin
interface Producer<out T> {
    fun produce(): T
}

class ItemProducer : Producer<Item> {
    override fun produce(): Item = Item()
}

class ToolProducer : Producer<Tool> {
    override fun produce(): Tool = Tool()
}

class PickaxeProducer : Producer<Pickaxe> {
    override fun produce(): Pickaxe = Pickaxe()
}

val producer0: Producer<Item> = ItemProducer()
val producer1: Producer<Item> = ToolProducer()
val producer2: Producer<Item> = PickaxeProducer()
```

另一个消费者的例子如下，即将泛型类型作为函数的输入

```kotlin
interface Consumer<in T> {
    fun consume(item: T)
}

class ItemConsumer : Consumer<Item> {
    override fun consume(item: Item) {
        println("Using $item")
    }
}

class ToolConsumer : Consumer<Tool> {
    override fun consume(item: Tool) {
        println("Using $item")
    }
}

class PickaxeConsumer : Consumer<Pickaxe> {
    override fun consume(item: Pickaxe) {
       println("Using $item")
    }
}

val consumer0: Consumer<Pickaxe> = ItemConsumer()
val consumer1: Consumer<Pickaxe> = ToolConsumer()
val consumer2: Consumer<Pickaxe> = PickaxeConsumer()

```

## 小结

- Kotlin 引入的泛型型变的概念是为了解决**类型安全**的问题，让编译器能够保证安全地进行强制转型。
- 当泛型参数声明为 `out T` 时，`C<Base>` 为 `C<Derived>` 的超类型。
- 当泛型参数声明为 `in T` 时，`C<Derived>` 为 `C<Base>` 的超类型。

最后需要注意的是，声明处型变在使用上还是有限制，泛型型变只能在类和接口的定义当中声明使用，在顶层函数当中没办法使用。

# 类型投影 | Type Projection

类型投影这个概念不知道最初是在哪提出来的，在网上搜了半天也只找到了 Kotlin，Scala 和 C# 相关的一些文章，那么根据 C# 文档 [Projection Operation][0] 当中的描述，投影指的是将一个对象转换成另一个仅含有特定部分属性的对象，具体配合后续的例子会更好理解。

## 使用处型变 | Use-Site Variance

有些时候我们不能保证一个类或接口一定是生产者或消费者模型当中的一种,例如下面这个例子当中，泛型参数 `T` 既是 `invoke()` 的返回值，同时又是 `invoke(i: T)` 的参数，这时我们不得不将泛型变量声明为不型变的

<Admonition title="Tips" type="info">

下面的例子用到了运算符重载的特性，`invoke()` 对应的是直接调用对象的操作，即 `box()`，`invoke(i)` 对应的是传入单个参数的调用操作，即 `box(i)`

另外 `invoke()` 函数的返回类型 `T` 可以被推导出来，所以这里可以省略

</Admonition>

```kotlin
data class Box<T>(var item: T) {
    operator fun invoke() = item
    operator fun invoke(i: T) {
        this.item = i
    }
}
```

此时 `Box<Item>` 和 `Box<Tool>` 之间有没有任何子类型的关系，下面的代码就会产生错误

```kotlin
fun unbox(box: Box<Item>) {
    println(box())
}

val item = Box(Item())
val tool = Box(Tool())
val pickaxe = Box(Pickaxe())

unbox(item) // OK
unbox(tool) // ERROR
unbox(pickaxe) // ERROR
```

这时我们可以加上使用处型变的标注，将函数改成下面这样子

```kotlin
fun unbox(box: Box<out Item>) {
  println(box())
}
```

这就产生了类型投影，意即这里的 `box` 不再是一个普通的对象，而是一个受限制的被投影（*projected*）产生的对象，此时我们只能调用该对象返回 `T` 类型的方法。

上述 `unbox` 函数体内执行的 `box()` 即相当于执行了 `invoke()`, 但在函数体的作用域内我们访问不到含有单个参数的 `invoke(i)` 方法。

这里就相当于 Java 当中的 `Box<? extends Item>`。

类似的，如果我们需要使用 `invoke(i)` 方法，则需要换用 `in` 来修饰泛型类型，例如下面这个例子

```kotlin
fun fill(box: Box<in Pickaxe>) {
    box(Item())
}

```

## 星投影 | Star Projection

有时候我们可能无法获知类型参数的信息，或者是不需要关心泛型参数的具体类型，但让想保证类型安全，因此 Kotlin 提供了星投影的语法，即该泛型类型的任何实例化类型都将是该投影的子类型。

例如下面一个例子，这里我们可以调用 `box()` 方法，但不能调用 `box(i)` 方法，因为此时的 `box` 对象是只能进行读取操作的。

```kotlin
fun printAllBoxes(boxes: List<Box<*>>) {
    boxes.forEach { println(it()) }
}
```

在 Kotlin 的文档内还有更多的不用情况下星投影的 `out` `in` 限定的等价形式，具体参考 [Star Projection - Kotlin Docs][1]。

## 小结

类型投影依然是为了泛型的类型安全而引入的机制，星投影类型实际上等同于使用 Java 的 raw types，但是有编译器能够提供类型安全保障。

下面还有一张来自 [Dave Leeds on Kotlin][2] 网站的关于几种投影类型的总结表

![kinds of projections](https://i.loli.net/2021/08/16/1GAgC6jPJ3tHYuR.png)

# 泛型约束 | Generics Constraint

有时候我们想要对泛型参数 `T` 进行约束，使得它仅能接受特定的类型，在 Java 当中这个语义仍然是通过 `extends` 来表达的，但 Kotlin 当中采用了不同的语法。

例如下面的这个例子当中，泛型参数 `T` 后冒号后面的便是泛型约束的上界，即 `T` 只能被 `Comparable<T>` 的子类型替换。

```kotlin
fun <T : Comparable<T>> sort(list: List<T>)
```

对于没有显示声明上界的泛型参数，其默认的上界是 `Any?`，也就意味着泛型参数 `T` 默认是可以接受可空类型的。

在尖括号当中只能声明单个上界，如果想要声明多个上界，可以使用 `where` 语句，就像下面这样（~~直接抄文档的例子了~~

```kotlin
fun <T> copyWhenGreater(list: List<T>, threshold: T): List<String>
    where T : CharSequence,
          T : Comparable<T> {
    return list.filter { it > threshold }.map { it.toString() }
}
```

# 类型擦除

由于 JVM 的原因，其泛型的实现始终是采用的类型擦除的机制，也就是说泛型参数仅仅存在于编译时，在运行时将被擦拭，编译器只能尽可能的帮我们检查出会引发类型不安全的错误。

因此，出于 JVM 的限制，在泛型的使用中还会产生一些问题，例如下面的例子

```kotlin
fun <T> getClassName(cls: T): String = T::class.java.name // !error
getClassName(Box(0))
```

因为在运行时泛型类型 `T` 的信息已经被抹去，我们是无法动态的传入一个对象直接获取到该对象的类，通常的 workaround 是直接传入对象的类，就像下面这样

```kotlin
fun getClassName(cls: Class<*>): String = cls.name
val box = Box(0)
println(getClassName(box::class.java))
```

# 内联函数中的泛型

但 Kotlin 提供了内联函数，而在内联函数当中，我们可以使用具体化的参数类型。

简单的解释，内联函数定义后并不会真正产生新的函数，内联函数在被调用是时候，函数体会被像“*复制粘贴*”一样展开到所调用的位置，因此在内联函数当中可以获取到泛型参数的具体类型。

上面的例子可以改写成下面这样

```kotlin
inline fun <reified T> getClassName(cls: T): String = T::class.java.name
val box = Box(0)
println(getClassName(box))
```

而且内联函数还可以用在扩展函数上面！有了这个特性可以整出很多花活儿出来～

例如下面是一个 Kotlin 标准库当中的扩展函数，可以根据类型来筛选列表元素

```kotlin
inline fun <reified T> Iterable<*>.filterIsInstance() = filter { it is T }
val list = arrayListOf<Any>(0, 1, 2, 3, 4, 5, "what?")
println(list.filterIsInstance<Int>()) // [0, 1, 2, 3, 4, 5]
```

再比如下面这个例子，只要实现了 `Logging` 接口的类都会新增一个 `logger()` 方法（~~依赖注入了属于是~~

```kotlin
interface Logging
inline fun <reified T : Logging> T.logger(): Logger = LoggerFactory.getLogger(T::class.java)

data class Foo : Logging
val logger = Foo().logger()
```

# 总结

关于 Kotlin 的泛型的全部就总结到了这里，~~看完了说不定对 Rust 的学习也有一定帮助呢~~，总结下来的感受就一句话：C# 真的是现代化编程语言的业界标杆，另外 F# 其实也是看上去挺好的语言，可惜对于 **.NET** 我真的喜欢不起来 2333

# 参考

- https://stackoverflow.com/questions/44298702/what-is-out-keyword-in-kotlin
- https://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science)
- https://zhuanlan.zhihu.com/p/32583310
- https://www.baeldung.com/kotlin/generics

[0]: https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/projection-operations
[1]: https://kotlinlang.org/docs/generics.html#star-projections
[2]: https://typealias.com/concepts/type-projection/
