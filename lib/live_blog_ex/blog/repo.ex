defmodule LiveBlogEx.Blog.Repo do
  use GenServer

  alias LiveBlogEx.Blog

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: Blog.Repo)
  end

  @impl true
  def init(state \\ nil) do
    unless File.dir?(content_path()) do
      init_repo()
    end

    {:ok, state}
  end

  def update() do
    GenServer.cast(Blog.Repo, :update_repo)
  end

  defp repo_url, do: "https://github.com/#{Application.get_env(:live_blog_ex, :repo)}"
  defp priv_path, do: Application.app_dir(:live_blog_ex, "priv")
  defp content_path, do: Path.join(priv_path(), "content")

  defp init_repo, do: System.cmd("git", ["clone", repo_url(), "content"], cd: priv_path())

  defp update_repo do
    System.cmd("git", ["pull"], cd: content_path())
    Blog.update_posts()
  end

  @impl true
  def handle_cast(:update_repo, state) do
    update_repo()
    {:noreply, state}
  end
end
