---
title: Get Started With Ecto
date: 2021-09-08
desc: "Learning how to use Ecto"
tags: ["elixir", "ecto", "tutorial", "database", "sql"]
draft: false
---

`Ecto` 是 Elixir 官方背书的一个库，提供了对不同数据库的 wrapper 以及一套由宏构建的查询 DSL。

## 创建项目

使用 `mix` 创建一个新的项目，注意需要引入 Supervisor 支持。

```bash
mix new ecto_demo --sup
```

然后修改 `mix.exs` 添加 `Ecto` 依赖以及对应数据库的 Adapter，这里演示就直接使用 SQLite 了，对应的 Adapter 依赖为 `ecto_sqlite3`，对于其它数据库例如 PostgreSQL 或 MySQL 需要添加其对应的 Adapter 依赖。

之后用 mix 获取依赖

```bash
mix deps.get
```

接下来我们还需要配置数据库的连接信息，使用 Ecto 提供的 Mix Task 来生成 Repo。

```bash
mix ecto.gen.repo -r EctoDemo.Repo
```

然后在 `config/config.exs` 当中修改数据库信息，对于 SQLite 只需要填入数据库存放的位置即可，对于 PostgreSQL 或 MySQL 还需要填写数据库的连接地址和端口以及用户名和密码。

```elixir
config :ecto_demo, EctoDemo.Repo,
  database: "priv/ecto_demo.db"
```

Ecto 默认用户使用的是 PostgreSQL，所以我们还需要在刚刚生成的 `EctoDemo.Repo` 模块当中更改对应的 Adapter。

```elixir
defmodule EctoDemo.Repo do
  use Ecto.Repo,
    otp_app: :ecto_demo,
    adapter: Ecto.Adapters.SQLite3
end
```

然后我们还需要修改 `application.ex`，将 `Ecto.Repo` 加入 Supervisor 树当中。

```elixir
def start(_type, _args) do
  children = [
    EctoDemo.Repo
  ]

  opts = [strategy: :one_for_one, name: EctoDemo.Supervisor]
  Supervisor.start_link(children, opts)
end
```

最后我们需要在 `config.exs` 里面添加以下设置，使得我们后续能够使用 `mix ecto.create`。

```elixir
config :ecto_demo, ecto_repos: [EctoDemo.Repo]
```

配置完成后执行 `mix ecto.create`，这将会按照上述的配置创建数据库，现在我们的目录下应该已经有了一个 `priv/ecto_demo.db` 的数据库文件。

## Table

数据库创建完成以后，还需要在数据库中创建表，我们将通过 `Migration` 的方式来创建表。关于 `Migration` 更多的解释，参考 [Active Record Migration - Ruby on Rails Guide][0]。

```elixir
mix ecto.gen.migration create_people
```

之后会得到一个空的 Migration。

```elixir
defmodule EctoDemo.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do

  end
end
```

修改 `change/0` 函数，使用 Ecto 提供的 DSL 来创建表。

惯例上，表的名称通常使用名词复数。

```elixir
def change do
  create table(:people) do
    add :first_name, :string
    add :last_name, :string
    add :age, :integer
  end
end
```

之后可以执行 `mix ecto.migrate` 来执行刚刚的 `migrate`，然后我们可以看到数据库当中已经新建了一个 `people` 的表。

如果刚刚编写的 migration 有误，可以执行 `mix ecto.rollback` 来回滚。

## Schema

Schema 是数据库中的数据在 Elixir 当中的呈现形式，通常一个 schema 与数据库当中的表相关联。

```elixir
defmodule EctoDemo.Person do
  use Ecto.Schema

  schema "people" do
    field :first_name, :string
    field :last_name, :string
    field :age, :integer
  end
end
```

上述定义描述了 `EctoDemo.Person` 这个 schema 会映射至数据库当中的 `people` 这个表，以及对应字段的映射。

惯例上，schema 的名称选用名词单数。

Ecto 提供的一系列宏会为 schema 生成对应的结构体，执行 `iex -S mix` 在 `iex` 里体验一下。

```elixir
iex(1)> alias EctoDemo.Person
iex(2)> person = %Person{}
iex(3)> person = %Person{ person | age: 19, first_name: "Chris" }
%EctoDemo.Person{
  __meta__: #Ecto.Schema.Metadata<:built, "people">,
  age: 19,
  first_name: "Chris",
  id: nil, 
  last_name: nil
}
iex(4)> person.age
19
```

之后可以直接使用 `Repo.insert` 函数将新建的 schema 实例存入数据库

```elixir
iex(1)> alias EctoDemo.Person
iex(2)> alias EctoDemo.Repo
iex(3)> %Person{ first_name: "Chris", age: 21 } |> Repo.insert
{:ok,
 %EctoDemo.Person{
   __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
   age: 21,
   first_name: "Chris", 
   id: 1,
   last_name: nil
 }}
```

## Validate

有时候我们需要对一个 schema 实例做出一些变更，在它被存入数据库前，我们希望能够对 schema 的一些字段做一些校验，Ecto 引入了 Changeset 来实现这一操作。

使用 `Ecto.Changeset.cast/3` 函数来创建一个 Changeset，第一个参数为 schema 对应的结构体，第二个参数为需要做出的改动，第三个参数为允许被更改的字段的列表。

```elixir
iex> %Person{first_name: "Chris", age: 21} |> Ecto.Changeset.cast(%{}, [:first_name, :last_name, :age])
#Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #EctoDemo.Person<>, valid?: true>
```

第二个参数为一个 map，包含需要做出改动的字段，能被改动的字段受到第三个参数的影响。

```elixir
iex> %Person{first_name: "Chris", age: 21} |> Ecto.Changeset.cast(%{age: 22}, [:first_name, :last_name, :age])
#Ecto.Changeset<
  action: nil,
  changes: %{age: 22},
  errors: [],
  data: #EctoDemo.Person<>,
  valid?: true
>
```

```elixir
iex> %Person{first_name: "Chris", age: 21} |> Ecto.Changeset.cast(%{age: 22}, [])                             
#Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #EctoDemo.Person<>, valid?: true>
```

按照惯例，我们会在 schema 模块当中定义对应的 `changeset/2` 函数以便于创建 Changeset。

```elixir
defmodule EctoDemo.Person do
  import Ecto.Changeset
  use Ecto.Schema
  alias EctoDemo.Person

  schema "people" do
    field :first_name, :string
    field :last_name, :string
    field :age, :integer
  end

  def changeset(%Person{} = person, params \\ %{}) do
    person
    |> cast(params, [:first_name, :last_name, :age])
  end

end
```

之后我们可以方便的创建 Changeset，同时 `Repo.insert/2` 函数可以直接接收 Changeset 作为参数，将记录插入到数据库。

```elixir
iex> %Person{first_name: "David", age: 21} |> Person.changeset |> Repo.insert
```

使用 Changeset 的好处是在将数据插入到数据库之前，可以对记录的字段进行校验以避免错误。

`Ecto.Changeset` 提供了一系列的校验函数便于我们使用，例如下面的 `Ecto.Changeset.validate_required/2` 函数可以用来校验必须字段。

```elixir
def changeset(%Person{} = person, params \\ %{}) do
  person
  |> cast(params, [:first_name, :last_name, :age])
  |> validate_required([:first_name, :age])
end
```

现在如果我们创建的结构体当中缺少了必须的字段，则创建的 changeset 则会无效，可以通过检查 `changeset.valid?` 字段查看某个 changeset 是否有效。

```elixir
iex> changeset = %Person{first_name: "David"} |> Person.changeset                        
#Ecto.Changeset<
  action: nil,
  changes: %{},
  errors: [age: {"can't be blank", [validation: :required]}],
  data: #EctoDemo.Person<>,
  valid?: false
>
```

如果强行将 invalid 的 changeset 插入到数据库，则会产生错误提示，而不会实际将变更插入到数据库。

```elixir
iex> Repo.insert changeset
{:error,
 #Ecto.Changeset<
   action: :insert,
   changes: %{}, 
   errors: [age: {"can't be blank", [validation: :required]}],
   data: #EctoDemo.Person<>,
   valid?: false
 >}
```

除了 `validate_required/2` 之外还有一些其它的校验函数，例如

```elixir
def changeset(%Person{} = person, params \\ %{}) do
  person
  |> cast(params, [:first_name, :last_name, :age])
  |> validate_required([:first_name, :age])
  |> validate_number(:age, greater_than: 0)
end
```

```elixir
iex> %Person{} |> Person.changeset(%{first_name: "Blake", age: -10})
#Ecto.Changeset<
  action: nil,
  changes: %{age: -10, first_name: "Blake"},
  errors: [
    age: {"must be greater than %{number}",
     [validation: :number, kind: :greater_than, number: 0]}
  ],
  data: #EctoDemo.Person<>,
  valid?: false
>
```

## Query

首先在演示查询之前，先清除掉之前的数据库添加一些 dummy data，执行下面的命令分别 drop、create、migrate。

```bash
mix ecto.drop
mix ecto.create
mix ecto.migrate
```

然后添加几条记录到数据库当中。

```elixir
people = [
  %Person{first_name: "Ryan", last_name: "Bigg", age: 28},
  %Person{first_name: "John", last_name: "Smith", age: 27},
  %Person{first_name: "Jane", last_name: "Smith", age: 26},
]
people |> Enum.each(&(Repo.insert(&1)))
```

### 获取单个记录

要进行查询，首先使用 `Ecto.Query` 模块提供的函数先构建一个 Query，之后再将其传递给项目的 `Repo` 模块进行查询。

例如下面是一个从 `people` 表中查询第一条记录的 Query，使用的是 `Ecto.Query.one/2` 函数。

```elixir
iex> Ecto.Query.first(Person)
#Ecto.Query<from p0 in EctoDemo.Person, order_by: [asc: p0.id], limit: 1>
```

可以看到的是它返回的是一个 `Ecto.Query` 的结构体，尖括号里面的实际上是 Ecto 提供的 Query DSL 语法，因此我们实际上也可以自己写 Query。

Ecto 大量依赖 Elixir 宏构建了一套类似于 SQL 的查询 DSL，很容易可以看出下面查询语句的语义。

```elixir
iex> require Ecto.Query
iex> alias EctoDemo.Repo
iex> alias EctoDemo.Person
iex> query = Ecto.Query.from p in Person, order_by: [asc: p.id], limit: 1
#Ecto.Query<from p0 in EctoDemo.Person, order_by: [asc: p0.id], limit: 1>
```

之后将 query 传递给 `Repo.one` 函数来获取单条查询记录。可以看到查询语句返回的直接是对应 schema 的结构体。

```elixir
iex> Repo.one(query)
%EctoDemo.Person{
  __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
  age: 28,
  first_name: "Ryan",
  id: 1,
  last_name: "Bigg"
}
```

### 获取多个记录

使用 `Repo.all/1` 函数来获取 schema 所有的记录。

```elixir
iex> Repo.all(Person)  
[
  %EctoDemo.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 28,
    first_name: "Ryan",
    id: 1,
    last_name: "Bigg"
  },
  %EctoDemo.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 27,
    first_name: "John",
    id: 2,
    last_name: "Smith"
  },
  %EctoDemo.Person{
    __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
    age: 26,
    first_name: "Jane",
    id: 3,
    last_name: "Smith"
  }
]
```

### 根据 ID 获取单个记录

```elixir
iex> Person |> Repo.get(1)
%EctoDemo.Person{
  __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
  age: 28,
  first_name: "Ryan",
  id: 1,
  last_name: "Bigg"
}
```

### 根据字段获取单个记录

```elixir
iex> Person |> Repo.get_by(first_name: "Ryan")
%EctoDemo.Person{
  __meta__: #Ecto.Schema.Metadata<:loaded, "people">,
  age: 28,
  first_name: "Ryan",
  id: 1,
  last_name: "Bigg"
}
```

### 过滤结果

可以直接使用 `Ecto.Query.where` 函数，以下两种写法都可以，第二种写法适用于需要对字段作更加复杂的比较运算的情景。

```elixir
Person |> Ecto.Query.where(last_name: "Smith") |> Repo.all
Person |> Ecto.Query.where([p], p.last_name == "Smith") |> Repo.all
```

也可以手动使用 `Ecto.Query.from` 来构建 query。

```elixir
query = Ecto.Query.from p in Person, where: p.last_name == "Smith"
Repo.all(query)
```

需要注意的是，在查询语句里面引用到外部变量时，需要使用 pin operator 获取变量的字面值。

```elixir
last_name = "Smith"
Person |> Ecto.Query.where(last_name: ^last_name) |> Repo.all
```

## 更新与删除记录

使用 changeset 来更新数据库当中的记录，首先需要查询得到对应的 schema 结构体，然后使用 changeset 对其进行更改，之后再用 `Repo.update` 函数进行更新。

使用 changeset 的好处前面已经提到，它可以为我们对记录的字段进行校验。

```elixir
person = Ecto.Query.from(p in Person, where: p.first_name == "Ryan") |> Repo.one
person |> Person.changeset(%{age: 29}) |> Repo.update
```

要删除一条记录也非常简单，同意只需要先查询拿到对应的 schema 结构体，然后使用 `Repo.delete` 函数删除即可。

---

## TODO

- association
- virtual field

[0]: https://guides.rubyonrails.org/active_record_migrations.html
