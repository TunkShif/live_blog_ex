---
title: Building a JWT-Based User Authentication API With Phoenix
date: 2021-09-16
desc: "Building authenticatio API using PhoenixFramework and Guardian"
tags: ["elixir", "phoenix", "jwt"]
---

# Setting Up

首先新建项目，由于我们要构建的是一个单纯的 REST API，所以不需要 webpack 和 html 的支持。

```bash
mix phx favorito --no-webpack --no-html
```

之后到 `config/dev.exs` 内配置好开发测试用的数据库的连接信息，执行 `mix ecto.create` 来创建数据库。

然后引入必要的依赖，在 `mix.exs` 里添加

```elixir
def deps do
  [
    {:bcrypt_elixir, "~> 2.0"},
    {:guardian, "~> 2.0"},
    {:corsica, "~> 1.1"}
  ]
end
```

其中 `bcrypt_elixir` 是使用 `Bcrypt` 加密用户密码的库，`guardian` 是一个基于 `token` 的认证库，`corsica` 是一个用于解决跨域问题的库。

之后执行 `mix deps.get && mix compile` 来拉取并编译对应库。

# User Model

使用 Phoenix 提供的 mix task 来生成一个 `Account` context，这里的 context 个人感觉更相当于是业务设计上的一个分层概念，一个 context 可能会包含多个相关联的 model，而具体的业务操作包含在 context 里面。

```bash
mix phx.gen.html Account User users \
  username:string:unique \
  password:string
```

执行完上面的命令后，Phoenix 会很夸张地为我们自动生成很多东西，包括对应的 schema，migration，controller，view 以及单元测试，并且里面连基本的 CRUD 操作都全部写好了。。。

当然我们还是要根据需要进行调整，首先是 migration，这里面定义了数据库中表的结构，修改 `username` 和 `password_hash` 两个字段均为非空，并且 `username` 不得重复。

我们不会直接明文存储密码，而是存入使用 `Bcrypt` 哈希过后的值到 `password_hash` 字段。

```elixir
defmodule Favorito.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
```

接下来修改 schema，在 schema 里面我们新加了一个虚拟字段 `password`，因为这个字段不会实际存入数据库当中。

接着在自己添加的 `put_password_hash/1` 函数里面，我们调用了 `Bcrypt` 提供的函数将 changeset 当中的 `password` 字段进行哈希后存到 `password_hash` 里面。

```elixir
defmodule Favorito.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset

end
```

完成之后，执行 `mix ecto.migrate` 来执行刚刚创建的 migration。

之后再到 `Account` context 对应文件里，根据实际需要修改保留自动生成的函数，同时增加一个验证用户密码是否匹配的操作。

```elixir
defmodule Favorito.Account do
  import Ecto.Query, warn: false

  alias Favorito.Repo
  alias Favorito.Account.User

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def authenticate_user(username, password) do
    query = from u in User, where: u.username == ^username
    query |> Repo.one() |> verify_password(password)
  end

  defp verify_password(nil, _) do
    Bcrypt.no_user_verify()
    {:error, :user_not_found}
  end

  defp verify_password(user, password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :wrong_password}
    end
  end

end
```

新定义的 `authenticate_user/2` 函数接收用户名和密码，首先从数据库中查找出对应用户，然后传给 `verify_password/2` 函数进行验证。

在 `verify_password/2` 当中调用 `Bcrypt` 提供的相关函数来验证密码是否正确。

# Guardian

Guardian 是一个基于 token 的认证库，默认采用的是 JWT 进行验证，在使用之前首先需要创建一个自己的 `Guardian` 模块。

```elixir
defmodule FavoritoWeb.Guardian do
  use Guardian, otp_app: :favorito

  alias Favorito.Repo
  alias Favorito.Account.User

  def subject_for_token(%User{} = user, _claims), do: {:ok, to_string(user.id)}

  def subject_for_token(_, _), do: {:error, :unknown_resource_type}

  def resource_from_claims(%{"sub" => user_id}) do
    {:ok, Repo.get!(User, user_id)}
  end

  def resource_from_claims(_), do: {:error, :unknown_resouce_type}
end
```

其中的 `subject_for_token/2` 函数定义了使用 `User` 在数据库中的主键 ID 作为 subject，`resource_from_claims/1` 函数定义了如何通过 subject 获取到所需要的对象。

之后还需要在 `config.exs` 当中进行相关配置，其中的 `secret_key` 可以使用 `mix guardian.gen.secret` 来生成

```elixir
config :favorito, FavoritoWeb.Guardian,
  issuer: "Favorito",
  secret_key: "u1JqNJZzPCST5hGXt6wV5AaQI1ljdxIUc9MiTcojfQ6S2HXYOyd9JhO5eNcFUuS6"
```

# Controller and View

首先我们在 `UserController` 当中定义一个用于登陆的 action。

该操作从 request body 读取 `username` 和 `password`，通过验证之后返回生成的 token。

```elixir
# router.ex

scope "/api", FavoritoWeb do
  pipe_through :api
  post "/users/login", UserController, :login
end
```

```elixir
# user_controller.ex

defmodule FavoritoWeb.UserController do
  use FavoritoWeb, :controller

  alias Favorito.Account

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, user} <- Account.authenticate_user(username, password),
         {:ok, token, _claims} <- FavoritoWeb.Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("success.json", user: user, token: token)
    else
      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(FavoritoWeb.ErrorView)
        |> render("401.json", message: reason)
    end
  end
end
```

```elixir
# user_view.ex

defmodule FavoritoWeb.UserView do
  use FavoritoWeb, :view

  alias Favorito.Account.User

  def render("success.json", %{user: %User{} = user, token: token}) do
    %{
      "data" => %{
        "user" => %{
          "username" => user.username,
          "token" => token
        }
      }
    }
  end
end
```

# Plug Pipeline

Guardian 既可以单独用来验证签发 token，也可以使用其提供的一系列 Plug 来集成到 Web 项目当中。

首先必须要使用的一个 Plug 是 `Guardian.Plug.Pipeline`，指明我们自定义的 `Guardian` 模块以及一个作为 `error_handler` 的 controller 模块。

```elixir
pipeline :api do
  plug :accepts, ["json"]

  plug Guardian.Plug.Pipeline,
    error_handler: FavoritoWeb.UserController,
    module: FavoritoWeb.Guardian
end
```

`error_handler` 必须实现 `auth_error/3` 回调函数，用以处理验证错误的情况。

```elixir
# user_controller.ex

def auth_error(conn, {_type, _reason}, _opts) do
  conn
  |> put_status(:forbidden)
  |> put_view(FavoritoWeb.ErrorView)
  |> render("403.json", message: "Unauthenticated")
end
```

之后便可以使用 `Guardian.Plug.VerifyHeader` 这个 plug，它将会从请求的 header 当中的 `Authorization` 字段提取并校验 token。

另外还有 `Guardian.Plug.LoadResource`，它会将校验后的 token 对应的 resource 加载到 `conn` 当中，之后可以使用 `Guardian.Plug.current_resource/2` 来获取。

所以组成的完整的 pipeline 像下面这样

```elixir
pipeline :api do
  plug :accepts, ["json"]

  plug Guardian.Plug.Pipeline,
    error_handler: FavoritoWeb.UserController,
    module: FavoritoWeb.Guardian

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.LoadResource, allow_blank: true
end
```

还有一个 `Guardian.Plug.EnsureAuthenticated` 的 plug，用以确保是否通过 token 验证。通常情况下我们想要的是路由内的部分 endpoint 需要登陆验证后才能访问到，因此可以在需要登陆验证的 controller 里使用这个 plug。

例如下面这个例子使得 `UserController` 内的 `info` action 需要通过登陆验证后才能访问到，否则就会调用之前设定的 `error_handler` 内的 `auth_error/3` 回调函数进行错误处理。

```elixir
defmodule FavoritoWeb.UserController do
  use FavoritoWeb, :controller

  plug Guardian.Plug.EnsureAuthenticated when action in [:info]
end
```

# References

- [Phoenix Realworld Example App][0]
- [Guardian Docs][1]
- [Elixir Phoenix JWT][2]
- [Building a JSON API in Elixir with Phoenix 1.5][3]

[0]: https://github.com/gothinkster/elixir-phoenix-realworld-example-app
[1]: https://github.com/ueberauth/guardian
[2]: https://github.com/njwest/React-Native-Elixir-Phoenix-JWT
[3]: https://lobotuerto.com/blog/building-a-json-api-in-elixir-with-phoenix/
