defmodule LiveBlogEx.Blog do
  defstruct categories: [], tags: [], posts: []

  defmodule PostNotFoundError do
    defexception [:message, plug_status: 404]
  end

  use GenServer

  alias LiveBlogEx.Blog
  alias LiveBlogEx.Blog.Post

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %Blog{}, name: __MODULE__)
  end

  @impl true
  def init(state \\ %Blog{}) do
    {:ok, update(state)}
  end

  defp update(%Blog{} = blog) do
    posts = Post.all()

    categories =
      for post <- posts, into: MapSet.new() do
        post.category
      end
      |> MapSet.to_list()

    tags =
      for post <- posts, tag <- post.frontmatter.tags, into: MapSet.new() do
        tag
      end
      |> MapSet.to_list()

    %{blog | categories: categories, posts: posts, tags: tags}
  end

  def all_posts() do
    GenServer.call(__MODULE__, :all_posts)
  end

  def all_tags() do
    GenServer.call(__MODULE__, :all_tags)
  end

  def get_post({_category, _slug} = params) do
    GenServer.call(__MODULE__, {:get_post, params})
  end

  def get_posts({:category, _category} = params) do
    GenServer.call(__MODULE__, {:get_posts, params})
  end

  def get_posts({:tag, _tag} = params) do
    GenServer.call(__MODULE__, {:get_posts, params})
  end

  def update_posts() do
    GenServer.cast(__MODULE__, :update_posts)
  end

  @impl true
  def handle_call(:all_posts, _from, blog) do
    {:reply, blog.posts, blog}
  end

  @impl true
  def handle_call(:all_tags, _from, blog) do
    {:reply, blog.tags, blog}
  end

  @impl true
  def handle_call({:get_post, {category, slug}}, _from, blog) do
    post = blog.posts |> Enum.find(&(&1.category == category and &1.slug == slug))
    {:reply, post, blog}
  end

  @impl true
  def handle_call({:get_posts, {:category, category}}, _from, blog) do
    posts = blog.posts |> Enum.filter(&(&1.category == category))
    {:reply, posts, blog}
  end

  @impl true
  def handle_call({:get_posts, {:tag, tag}}, _from, blog) do
    posts = blog.posts |> Enum.filter(&(tag in &1.frontmatter.tags))
    {:reply, posts, blog}
  end

  @impl true
  def handle_cast(:update_posts, blog) do
    {:noreply, update(blog)}
  end
end
