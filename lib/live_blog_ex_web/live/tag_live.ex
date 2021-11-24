defmodule LiveBlogExWeb.TagLive do
  use LiveBlogExWeb, :live_view

  alias LiveBlogEx.Blog
  import LiveBlogExWeb.Components

  @max_posts_per_page 8

  def render(assigns) do
    ~H"""
    <div class="flex flex-col-reverse md:flex-row md:justify-between md:space-x-4 md:space-y-0">
      <div class="md:w-[70%] space-y-4 mb-2">
        <.posts_section posts={@posts} current_page={@current_page} max_page={@max_page} />
      </div>

      <div class="relative mb-4 md:w-[30%] md:max-w-xs">
        <div class="md:sticky md:top-2 space-y-2">
          <div class="box">
            <.tags_section tags={@tags} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"tag" => tag} = params, _session, socket) do
    with current_page <- Map.get(params, "page", "1") |> String.to_integer(),
         all_posts <- Blog.get_posts({:tag, tag}),
         chunked <- Enum.chunk_every(all_posts, @max_posts_per_page),
         max_page <- Enum.count(chunked),
         posts <- Enum.at(chunked, current_page - 1) do
      if is_nil(posts) do
        raise LiveBlogEx.Blog.PostNotFoundError
      end

      tags = Blog.all_tags()

      socket =
        socket
        |> assign(:current_page, current_page)
        |> assign(:max_page, max_page)
        |> assign(:posts, posts)
        |> assign(:tags, tags)

      {:ok, socket}
    end
  end
end
