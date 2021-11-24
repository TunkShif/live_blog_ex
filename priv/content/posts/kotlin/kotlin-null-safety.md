---
title: "Kotlin - Null Safety"
date: 2021-03-14
desc: "Kotlin Basic - Null Safety"
tags: ["kotlin"]
---

# Type System and Nullbility

$Type? = Type\ or\ null$

Variables declared with `Type` type cannot be `null` and also cannot be assigned with a variable with `Type?` type.

# Handling `null`

## Safe Call Operator

```kotlin
val foobar = foo?.bar()

val foobar = if (foo != null) foo.bar() else null
```

The result type of such an invocation is _nullable_.

This operator can also be used to access property.

## Elvis Operator

```kotlin
val foobar = foo ?: bar

val foobar = if (foo != null) foo else bar

// usually used with safe call operator
val countryName = user?.address?.country ?: "Unknown"

// also can be used with throw
fun printCountryName(user: User?) {
    val countryName = user?.address?.country
        ?: throw IllegalArgumentException("No address found!")
    println("Country: $countryName")
}
```

## Safe Casts

```kotlin
val foobar = foo as? Bar

val foobar = if (foo is Bar) foo as Bar else null
```

## Non-Null Assertions

```kotlin
val foobar = foo!!

val foobar = if (foo != null) foo else throw NullPointerException()
```

## The `let` Function

```kotlin
// example
val email: String? = getEmailFromUserId(userId)

email?.let { sendEmailTo(it) }

if (email != null) {
    sendEmailTo(email)
}
```

## The `takeIf` and `takeUnless` Function

```kotlin
val number = Random.nextInt(100)
val str = "some random string"

val evenOrNull = number.takeIf { it % 2 == 0 }
val caps = str.takeIf { it.isNotEmpty }?.toUpperCase() ?: "UPPERCASE STRING"
```
