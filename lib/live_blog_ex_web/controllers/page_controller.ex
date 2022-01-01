defmodule LiveBlogExWeb.PageController do
  use LiveBlogExWeb, :controller

  alias LiveBlogEx.Blog

  @max_posts_per_page 8

  def index(conn, params) do
    with current_page <- Map.get(params, "page", "1") |> String.to_integer(),
         all_posts <- Blog.all_posts(),
         chunked <- Enum.chunk_every(all_posts, @max_posts_per_page),
         max_page <- Enum.count(chunked),
         posts <- Enum.at(chunked, current_page - 1) do
      if is_nil(posts) do
        raise LiveBlogEx.Blog.PostNotFoundError
      end

      tags = Blog.all_tags()

      render(conn, "index.html",
        page_title: "Home",
        current_page: current_page,
        max_page: max_page,
        posts: posts,
        tags: tags
      )
    end
  end

  def page(conn, params) do
    render(conn, "page.html")
  end
end
