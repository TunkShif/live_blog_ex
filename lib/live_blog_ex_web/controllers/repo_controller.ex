defmodule LiveBlogExWeb.RepoController do
  use LiveBlogExWeb, :controller

  alias LiveBlogEx.Blog.Repo

  def update(conn, _params) do
    Repo.update()
    render(conn, "update.json")
  end
end
