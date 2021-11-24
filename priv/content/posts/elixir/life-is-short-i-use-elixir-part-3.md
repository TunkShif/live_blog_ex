---
title: "Life Is Short I Use Elixir Part III"
date: 2021-07-04
desc: "Concurrency and OTP GenServer"
tags: ["elixir"]
---

本篇文章主要讲述 Elixir 当中的依附于 Erlang 的 Actor 模型的并发编程。

# 进程 Process

此处要讲的进程并不是一般所说的 OS 的进程，而是 Erlang BEAM 虚拟机当中的进程，其更加类似于一个轻量级的线程，或者说更像最近兴起的协程（尽管这两个类比都很不恰当）。因此后文当中提到进程的时候，如无特殊说明都是指的 Erlang 的进程而非 OS 的进程。

所有的 Erlang or Elixir 代码都是运行在进程当中的，根据 _Elixir in Action_ 这本书中简略的描述，一个 OS 进程下有许多个不同的 OS 线程，每个线程都有一个调度器（_Scheduler_），每个调度器又管理着许多不同的进程。

## PID

使用 `self/0` 函数可以获取到当前代码所运行的进程的 PID，因为 `iex` 也是一个 Elixir 程序，其也是运行在进程当中的，所以可以在 `iex` 当中运行 `self/0` 来查看进程 ID，其返回的结果类似于 `#PID<0.106.0>`。

## 创建进程

使用 `spawn/1` 函数可以创建一个新的进程，其接收一个函数并返回所创建的进程的 PID。当传入的函数执行完毕后这个进程便会被销毁。例如 `pid = spawn(fn -> "Hi, there~" end)`。

此外还有一个 `spawn/3` 函数，用法如 `spawn(MyModule, :my_func, [:param1, :param2])`，分别接收模块名，函数名，和参数列表。

`Process` 模块下提供了一系列与进程相关的函数，例如使用 `Process.alive?/1` 可以检测一个进程是否存活。

## Let it Crash!

由于各个进程之间是相互独立的，当一个进程崩溃（即抛出 Error）的时候，另外的进程并不会受影响。

例如在 iex 当中执行 `spawn(fn -> raise ErlangError end)`，新生成出来的进程会立刻崩溃，但不会影响到 iex 本身运行的进程。

但是如果使用 `spawn_link(fn -> raise ErlangError end)`，则新生成的进程会被链接到当前进程，即新的进程崩溃后，其所连接的进程也会崩溃。因此执行上面的函数之后，新生成的进程崩了，iex 也跟着一起崩了，但你会发现很快 iex 又自动重启了，这是后面可能会介绍的 `OTP Supervisor` 实现的进程崩溃自动重启的行为。

# 进程间通信

进程间的通信是通过消息传递来实现的，传递的消息内容可以是任何 Elixir Term。首先先来看几个例子：

## 发送信息

使用 `send/2` 函数向指定进程发送消息，例如 `send pid, {:ok, "Hello World!"}`

## 接收信息

每个进程都有一个自己的 mailbox，用来容纳传递进来的消息。使用 `receive/1` 函数（其实是宏）来接收信息，其用法非常类似于 `cond`，即根据模式匹配从 mailbox 当中选取出对应的消息处理后返回。

```elixir
receive do
  {:ok, msg} -> msg
  {:bye, msg} -> "Goodbye~ #{msg}"
end
```

若当前的 mailbox 当中没有可以匹配的消息，则当前进程则会挂起，知道出现能够匹配的消息，可以额外添加一个 `after` 子句，指定在一定时间后如果没有可匹配的消息的返回值。

```elixir
receive do
  {:ok, msg} -> msg
  {:bye, msg} -> "Goodbye~ #{msg}"
after
  5000 -> "No matching message found in mailbox"
end
```

### 持久运行的进程

从上述的例子当中可以看到，`receive` 函数在匹配到指定的消息后便会立即返回，但很多时候我们需要一个进程一直不断的接收消息，也就是要让 `receive` 函数持久运行，这时候我们会想到用循环，而记得在 Elixir 当中，我们要用递归代替循环。

```elixir
defmodule MyProcess do
  def loop do
    receive do
      {:ok, msg} ->
        IO.puts "Hi There~ #{msg}"
        loop
      {:bye, msg} ->
        IO.puts "Bye~ #{msg}"
    end
  end
end
```

# 使用进程维持状态

一般在其他编程语言当中，当我们需要在多个不同的地方共用一个变量的时候，我们可能会设一个全局的变量，但这在 Elixir 当中是不能实现的，对于这种情况我们使用一个专门的进程来维持状态。下面来写一个专门用来存储键值对的进程。

```elixir
defmodule KVStore do
  def start do
    spawn(__MODULE__, :loop, [%{}])
  end

  def loop(state) do
    receive do
      {:stop, msg} ->
        IO.puts msg
      {:put, key, val} ->
        new_state = Map.put(state, key, val)
        loop(new_state)
      {:get, key, caller} ->
        send caller, Map.fetch(state, key)
        loop(state)
      _ ->
        loop(state)
    end
  end
end
```

上面的例子中我们创建一个叫做 `KVStore` 的模块，其中的 `start/0` 函数生成了一个新的进程来运行我们的循环，在循环内一直等待接收其他进程传来的消息，根据传来的不同的消息做出对应的行为。具体的使用方法像下面这样：

```elixir
iex(1)> pid = KVStore.start
#PID<0.113.0>
iex(2)> send pid, {:put, :name, "Tom"}
{:put, :name, "Tom"}
iex(3)> send pid, {:get, :name, self}
{:get, :name, #PID<0.111.0>}
iex(4)> flush
{:ok, "Tom"}
:ok
iex(5)> Process.alive? pid
true
iex(6)> send pid, {:stop, "Bye~"}
Bye~
{:stop, "Bye~"}
iex(7)> Process.alive? pid
false
```

其中在使用 `spawn` 调用 `loop/1` 函数的时候，我们传入了一个空的字典，这就是我们初始的状态。

当进程收到 `:put` 消息的时候，我们创建了一个放入键值对后的新的字典，将这个新的字典作为初始状态接着循环下去，因为始终要记住 Elixir 当中变量是不可变的，我们不能直接改变原有的状态。

当进程收到 `:get` 消息的时候，`KVStore` 进程读取对应的值，再以消息的形式返回给调用它的进程（上面的例子当中也就是 iex），在 iex 中执行 flush，我们可以看见 mailbox 里的确收到了 `KVStore` 传递过来的消息。

当进程收到 `:stop` 消息的时候，不再继续循环下去，从而进程终结。

# OTP GenServer

从上述的例子我们了解了 Elixir 当中的进程模型，其核心就是在一个循环当中，通过模式匹配来对 mailbox 当中接收到的消息作出对应的响应，为了简化创建上述类似的进程的过程，Erlang 提供了 OTP GenServer （Generic Server）。

GenServer 规定了一组需要我们自己实现的回调函数，在模块当中使用 `use GenServer` 导入

```elixir
defmodule KVStore do
  use GenServer

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}
end
```

其中上面的 `start_link/1` 函数委托至了 `GenServer.start_link/3`, 用以提供一个初始状态启动进程，

> TO BE CONTINUED
> 施工中...
