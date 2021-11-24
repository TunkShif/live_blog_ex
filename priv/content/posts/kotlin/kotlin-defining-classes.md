---
title: "Kotlin - Defining Classes"
date: 2021-03-14
desc: "Kotlin Basic - Classes and Interfaces"
tags: ["kotlin"]
---

Classes and interfaces are `final` and `public` by default. And nested classes aren't inner by default.

# Interface

Interface, abstract class and sealed class.

```kotlin
interface Clickable {
    fun click()
    // methods can contain default implementation
    fun show() = println("Clicked!")
}

interface Focusable {
    fun show() = println("Focused!")
}

class Button : Clickable {
    // override modifier is mandatory
    override fun click = println("Button clicked!")

    override fun show() {
        // when implemented multiple interfaces with the same method name
        // specify which method to call by using angle brackets
        super<Clickable>.show()
        super<Focusable>.show()
    }
}

// only open class can be inherited
open class RichButton : Clickable {

    // only open method can be overriden in subclass
    open onClicked() = println("I'm clicked")

    // override without final implies being open
    final override fun click() = println("Clicked")
}

// abstract class are open by default
abstract class Animated {
    abstract fun animate()

    // non-abstract function are not open by default
    open fun stopAnimating() {
        println("Terminated!")
    }

    fun animateTwice() {
        println("Yayo~")
    }
}

// sealed class restricts the possibility of creating subclass
// all the direct subclass must be nested in the superclass
// sealed class are open by default
sealed class Expr {
    class Num(val value: Int) : Expr()
    class Sum(val left: Expr, val right: Expr) : Expr()
}

fun eval(e: Expr): Int =
    when(e) {
        is Expr.Num -> e.value
        is Expr.Sum -> eval(e.right) + eval(e.left)
        // there's no need for an else branch
    }
```

## Table: access modifiers

| Modifier   | Effect             | Note                                 |
| ---------- | ------------------ | ------------------------------------ |
| `final`    | Can't be overriden | Used by default                      |
| `open`     | Can be overriden   | Explicitly specified                 |
| `abstract` | Must be overriden  | Can be used only in abstract class   |
| `override` | Overrides a member | Overridden member is open by default |

## Table: visibility modifiers

| Modifier    | Class Member          | Top-level Member   |
| ----------- | --------------------- | ------------------ |
| `internal`  | Visble in a module    | Visble in a module |
| `protected` | Visible in subclasses | Not available      |
| `private`   | Visible in a class    | Visible in a file  |

In Java, we can access a `protected` member from the same package, but Kotlin does not allow that.

And an outer class does not see `private` members of its inner classes in Kotlin.

> TODO: More about inner or nesed class in Java and Kotlin

# Class

- _primary constructor_: usually the main, concise way to initialize a class and is declared outside of the class body
- _secondary constructor_: declared in the class body
- _initializer block_: additional initilization logic in class body
- _property_: in Java, a property is a field combined with its accessers, usually used in JavaBean

```java
// the name field is a property in this User Bean
public class User {
    private final String name;

    public User(String name) {
        this.name = name;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

```kotlin
/*
 * the constructor outside the class body is the primary constructor
 * it receives one parameter _name
 */
class User constructor(_name: String) {
    val name: String

    /*
     * primary constructor can't contain any initilization code
     * additional initilization logic excuted in a initializer block
     * excuted during an instance initilization
     * class body can contain multiple init blocks which will excuted in order
     */
    init {
        name = _name
    }
}

// keyword constructor can be ommitted if primary constructor doesn't have any annotations or modifiers
class User(_name: String) {
    // the property is inherited with the parameter in primary constructor
    val name = _name
}

// finally the code above can be simplified in this way
class User(val name: String)

// the property can have a default value
class User(val name: String, val isAdult: Boolean = true)

/*
 * when a class has a superclass, the primary constructor also needs to initialize
 * the superclass, provide the superclass constructor parameters after the superclass
 * reference in the base class list
 */
open class User(val name: String)

class WebsiteUser(name: String) : User(name)

// when no constructor is declared for a class, a default empty constructor will be generated
open class Button

/*
 * when inheriting the Button class and don't provide any constructors, we have to
 * explicitly invoke the constructor of the superclass
 */
class ImageButton : Button()

// we can make the primary constructor private
class Singleton private constructor()

/*
 * property in interface doesn't specify whether the value should be stored in a
 * backing fields or obtained throught a getter
 */
interface User {
    val name: String
}

class SubscribingUser(val email: String) : User {
    // get name from a custom getter, no backing field
    // invoke the getter method every time the name property is used
    override val name: String
        get() = email.substringBefore('@')
}

class TwitterUser(val accountName: String) : User {
    // initialize a property with a backing field
    // only invoke the getTwitterUserName method once during initilization
    override val name = getTwitterUserName(accountName)
}
```

> To Be Continued...
