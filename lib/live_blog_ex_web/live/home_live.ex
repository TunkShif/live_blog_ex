defmodule LiveBlogExWeb.HomeLive do
  use LiveBlogExWeb, :live_view

  import LiveBlogExWeb.Components

  alias LiveBlogEx.Blog

  @max_posts_per_page 8

  def render(assigns) do
    ~H"""
    <div class="flex flex-col space-y-2 md:flex-row md:justify-between md:space-x-4 md:space-y-0">
      <div class="md:w-[70%] space-y-4 mb-2">
        <.posts_section posts={@posts} current_page={@current_page} max_page={@max_page} />
      </div>

      <div class="relative md:w-[30%] md:max-w-xs">
        <div class="md:sticky md:top-2 space-y-2">
          <div class="box">
            <.profile_section />
          </div>

          <div class="box">
            <.tags_section tags={@tags} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    with current_page <- Map.get(params, "page", "1") |> String.to_integer(),
         all_posts <- Blog.all_posts(),
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

  defp profile_section(assigns) do
    ~H"""
      <div class="space-y-2">
        <figure class="flex justify-center items-center" >
          <img class="rounded-full border-2 border-whitesmoke shadow-sm" src="/images/avatar.jpeg" width="96" height="96" />
        </figure>
        <h2 class="text-lg text-gray-700 font-outfit font-bold text-center">
          TunkShif
        </h2>
        <h3 class="text-sm text-silver font-outfit text-center">
          Functional Programming
        </h3>
        <h3 class="text-sm text-silver font-outfit text-center">
          Language/Linguistics Enthusiast
        </h3>
        <div class="py-2 flex justify-center space-x-4">
          <a 
            href="https://github.com/TunkShif"
            target="_blank"
            class="px-2 py-1 bg-dogerblue bg-opacity-90 text-sm text-white rounded-[0.25em] shadow-sm outline-none transition duration-300 ease-in-out hover:bg-opacity-70 focus:bg-opacity-70">
            <i class="fab fa-github"></i>
            <span class="font-outfit font-bold" >GitHub</span>
          </a>
          <a
            href="https://twitter.com/TunkShif"
            target="_blank"
            class="px-2 py-1 bg-dogerblue bg-opacity-90 text-sm text-white rounded-[0.25em] shadow-sm outline-none transition duration-300 ease-in-out hover:bg-opacity-70 focus:bg-opacity-70">
            <i class="fab fa-twitter"></i>
            <span class="font-outfit font-bold">Follow</span>
          </a>
        </div>
      </div>
    """
  end
end
