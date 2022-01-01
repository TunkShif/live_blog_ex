defmodule LiveBlogExWeb.PostController do
  use LiveBlogExWeb, :controller

  alias LiveBlogEx.Blog
  alias LiveBlogEx.Blog.Post

  def index(conn, %{"category" => category, "slug" => slug} = _params) do
    case Blog.get_post({category, slug}) do
      nil ->
        raise Blog.PostNotFoundError

      post ->
        assigns =
          post
          |> Post.render()
          |> Map.take([:frontmatter, :content, :category])

        render(conn, "index.html", assigns)
    end
  end
end
