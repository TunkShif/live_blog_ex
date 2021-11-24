---
title: Plug into Web Development in Elixir
date: 2021-08-18
desc: "An intro to Elixir Plug"
tags: ["elixir", "web", "development", "plug"]
---

# What's Plug?

[Plug][0] 是 Elixir 最重量级的 Web 框架 [Phoneix Framework][1] 的中间层，根据官方文档的描述，Plug 是

> 1. A specification for composable modules between web applications
> 2. Connection adapters for different web servers in the Erlang VM

看完上面的介绍可能反而更加懵了，Plug 好像跟一般 `Java Python` 之类的 Web 框架里的存在的组件都不大一样。

根据 Elixir 的作者和 Plug 的贡献者 José Valim 自己的[回答][2]来看，Plug 是一个介于 Web Server 和 Web Framework 中间的一个通用抽象层。

Plug 封装了一个 `Plug.Conn` 的结构体，里面包含了与 Web Server 交互所需要的信息，包括 HTTP 请求和相应当中的 `METHOD STATUS PATH BODY` 等等信息，通过修改一个 `Plug.Conn` 当中的信息，将其传递给 Web Server 后，再次返回得到一个新的 `Plug.Conn`。

所以根据上面的描述，Plug 是一个 Web Server 之上的抽象适配层，其下面可以是不同的 Web Server 实现，但实际上 Elixir 官方目前只实现了对 [Cowboy][3] 这个基于 Erlang VM 的 Web Server。

# Get Started

首先用 Mix 来创建一个新的带有 Supervisor 支持的项目，执行 `mix new <project_name> --sup`，项目初始化完成后修改 `mix.exs` 添加 `Plug` 相关依赖，`plug_cowboy` 包括了 Cowboy Web Server 及其 Plug 的绑定。

```elixir 
# mix.exs

defp deps do
  [
    {:plug_cowboy, "~> 2.0"}
  ]
end
```

之后执行 `mix deps.get` 拉取相关依赖。

# A Glance at `Plug.Conn`

在正式编写我们的 Plug 项目的之前，先来看看 [Plug.Conn][4] 这个结构体到底包含了哪些东西。

`Plug.Conn` 代表一个 `Connection`，里面同时包含了 HTTP 的请求和相应的信息。

与请求相关的字段包括 `host` `method` `path_info` `req_headers` 等信息，与相应相关的字段包括 `resp_body` `resp_headers` `status` 等等。

还有一些特殊的字段比如 `cookies` `body_params` `query_params` 等等，这些字段需要手动调用特定函数后才会获取，例如调用 `fetch_query_params/2` 后才会获取到 `query_params` 字段。

另外在实际开发当中，我们还可以给 `Plug.Conn` 添加一些自己的额外信息，以 map 的形式存在 `assigns` 字段里面。

```elixir
%Plug.Conn{
  adapter: {Plug.Cowboy.Conn, :...},
  assigns: %{},
  body_params: %Plug.Conn.Unfetched{aspect: :body_params},
  cookies: %Plug.Conn.Unfetched{aspect: :cookies},
  halted: false,
  host: "localhost",
  method: "GET",
  owner: #PID<0.363.0>,
  params: %Plug.Conn.Unfetched{aspect: :params},
  path_info: ["haha"],
  path_params: %{},
  port: 4001,
  private: %{},
  query_params: %Plug.Conn.Unfetched{aspect: :query_params},
  query_string: "",
  remote_ip: {127, 0, 0, 1},
  req_cookies: %Plug.Conn.Unfetched{aspect: :cookies},
  req_headers: [
    {"accept", "*/*"},
    {"host", "localhost:4001"},
    {"user-agent", "curl/7.78.0"}
  ],
  request_path: "/haha",
  resp_body: nil,
  resp_cookies: %{},
  resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
  scheme: :http,
  script_name: [],
  secret_key_base: nil,
  state: :unset,
  status: nil
}
```

# My First Plug

简单来说，Plug 是一个特殊的类型为 `(Plug.Conn.t, Plug.opts) :: Plug.Conn.t` 函数，即接收一个 `Connection` 和一串 `options`，在函数内对 `Connection` 进行修改后再返回的一个函数。

除了这种函数式的 Plug，还有模块式的 Plug，但其核心还是上述的函数，接下来我们写一个简单的 Plug。

首先通过 `import Plug.Conn` 引入 `Plug.Conn` 模块下的所以函数和宏，之后我们需要实现规定好的两个回调函数。

`init/1` 函数用于初始化 `options`，将在 `call/2` 函数当中被调用。`call/2` 函数接收并返回一个 `Plug.Conn` 结构体。

在 `call/2` 函数内，我们可以使用之前 `import` 进来的函数来修改 `Plug.Conn`，根据函数名很容易能看出来下面的代码做了什么。

```elixir
defmodule PlugTest.MyPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello, World!")
  end
end
```

## Launch the Application

之后我们要通过 Supervisor 来启动我们的 Web Server，修改 `application.ex`，在 `children` 列表中配置启动 Cowboy Server，同时设置初始化启动我们刚刚编写的 Plug，并将服务器开放在 4001 端口上。

```elixir
defmodule PlugTest.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: PlugTest.MyPlug, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: PlugTest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

之后执行 `mix run --no-halt` 启动服务器，或者执行 `iex -S mix` 同时附带启动 `iex`。用浏览器或者 `curl` 访问 `http://localhost:4001`，会看见输出 `Hello, World!` 的信息。

# Lifecycle of a Plug

在 `Plug.Conn` 里有一个特别的字段 `state`，用来表明当前的 `Conn` 的状态，用下面一个例子来看看一个 `Conn` 的生命周期。

修改我们的上面写的第一个 Plug，在每一次操作之前都对它的状态进行一次审查。这里用到了最新版本 Elixir 1.12 才引入的 `tap/2` 函数。

```elixir
defmodule PlugTest.MyPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> tap(&inspect_state/1)
    |> put_resp_content_type("text/plain")
    |> tap(&inspect_state/1)
    |> resp(200, "Hello, World!")
    |> tap(&inspect_state/1)
    |> send_resp()
    |> tap(&inspect_state/1)
  end

  defp inspect_state(%Plug.Conn{state: state}) do
    IO.inspect(state)
  end
end
```

之后运行启动服务器，并用浏览器访问，可以看到控制台有以下输出内容

```
:unset
:unset
:set
:sent
```

由此可以看到一个 `Plug.Conn` 的生命周期。在 Supervisor 的配置里，我们配置启动了 `Plug.Cowboy, scheme: :http, plug: PlugTest.MyPlug, options: [port: 4001]`，我们也可以手动执行 `Plug.Cowboy.http` 函数来启动 Cowboy 服务器。

在启动服务器的同时我们就将我们写的 Plug 挂载了上去，在有客户端向服务器发送请求时，此时的 `Conn` 的状态为 `unset`，在调用 `resp/3` 函数设置了 `Conn` 的 `status code` 和 `response body` 之后，`Conn` 的状态变成了 `set`，最终使用 `send_resp/1` 函数之后，我们将响应发送给了客户端，最终 `Conn` 的状态变为 `sent`。

# Built-in Plugs

现在我们了解到，Plug 用于将接收到的 `Conn` 进行一系列操作之后，再将其返回或者是最终将响应发送给客户端，由此一系列的 Plug 可以形成 Pipeline。

Plug 项目官方提供了一些可以直接使用的 `Plugs`，首先我们来看看增加路由功能的 [Plug.Router][5]。

## Router Plug

另外新建一个模块来编写我们的 Router Plug，首先我们使用了 `use Plug.Router`，这会将在 `Plug.Router` 模块内定义好的一些代码注入到当前模块。

之后使用了 `plug :match` 和 `plug :dispatch`，`plug/2` 是一个宏，用于调用一系列 Plug 形成 Pipeline，后面可以是模块式的 Plug，也可以是函数式的 Plug。所有的请求都会以此经由所定义的 Pipiline。

其中 `:match` 是用来匹配路径并传递给 `:dispatch` 将请求分发到对应的不同函数上，之后可以用 `get post put patch delete match` 等宏以 DSL 的形式来构建自己的路由规则。

光看代码将已经能很清楚的知道具体的功能了，之后记得将 Supervisor 配置里启动 Cowboy 时初始化挂载的 Plug 改成新写的这个。

```elixir
defmodule PlugTest.MyRouter do
  use Plug.Router

  plug :match
  plug :dispatch
  
  get "/hello" do
    send_resp(conn, 200, "Hello, World!")
  end

  get "/hello/:name" do
    send_resp(conn, 200, "Hello, #{name}")
  end

  match _ do
    send_resp(conn, 400, "404 NOT FOUND :(")
  end
end
```

实际测试一下，可以按照预期正常工作

```shell
$ curl "http://localhost:4001/"
404 NOT FOUND :(
$ curl "http://localhost:4001/hello"
Hello, World!
$ curl "http://localhost:4001/hello/name"
Hello, name
```

## Logger Plug

[Plug.Logger][6] 基于 Elixir 内建的 `Logger` 模块给我们的 Plug 提供了打印调试信息日志的功能，只需要在我们的 Router Plug 的 Pipeline 后再追加一个 `plug` 调用就能启用日志功能。

```elixir
plug :match
plug :dispatch
plug Plug.Logger, log: :debug
```

实际输出效果

```shell
$ mix run --no-halt
Compiling 1 file (.ex)
13:01:39.497 [debug] GET /
13:01:43.158 [debug] GET /test
```

## Basic Auth

Plug 还内建了一个登陆验证的 Plug，简单使用的示例如下，要注意 Pipeline 中各个 Plug 使用的顺序，首先要先经由验证后才进行后续的路由匹配，所以登陆验证的 Plug 要放在首位。

之后用浏览器访问会弹出对话框提示输入用户密码，如果验证失败则返回 401。

```elixir
import Plug.BasicAuth

plug :basic_auth, username: "test", password: "secret"
plug :match
plug :dispatch
plug Plug.Logger, log: :debug
```

# Wrap Up

相信看到这里已经对 Plug 的开发模型有了一个简单的认识，通过复用已有的 Plug 以及自己按照编写新的 Plug，然后调用一系列 Plug 形成 Pipeline，由此可以快速地开发出简易的 Web 网站来。

之后还会介绍基于 Plug 的 MVC 模式的 Web 开发框架 Phoenix Framework，让 `CRUD` 型的业务开发更加简便。

# Reference

- https://ieftimov.com/post/a-deeper-dive-in-elixir-plug/
- https://dev.to/mpevec9/understanding-elixir-plug-o77
- https://elixirschool.com/en/lessons/specifics/plug/

[0]: https://hexdocs.pm/plug/readme.html
[1]: https://www.phoenixframework.org/
[2]: https://stackoverflow.com/questions/26304727/what-is-elixir-plug
[3]: https://github.com/ninenines/cowboy
[4]: https://hexdocs.pm/plug/Plug.Conn.html
[5]: https://hexdocs.pm/plug/Plug.Router.html
[6]: https://hexdocs.pm/plug/Plug.Logger.html
