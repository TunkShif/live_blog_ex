defmodule LiveBlogExWeb.PostLive do
  use LiveBlogExWeb, :live_view

  import LiveBlogExWeb.Components

  alias LiveBlogEx.Blog
  alias LiveBlogEx.Blog.Post

  def render(assigns) do
    ~H"""
    <div class="flex flex-col space-y-2 md:flex-row md:justify-between md:space-x-4 md:space-y-0">
      <div class="w-full md:w-[70%] mb-2">
        <div class="box">
          <.header frontmatter={@frontmatter} category={@category} />
          <article id="markdown" class="markdown line-numbers" phx-hook="MarkdownExt">
            <%= raw @content %>
          </article>

          <hr class="h-0 my-6 border-whitesmoke border-dashed border-2" />

          <div class="space-y-2">
            <.section_title icon="fas fa-tag" text="tags" />
            <.tag_group tags={@frontmatter.tags} />
          </div>
        </div>
      </div>

      <div class="relative md:w-[30%]">
        <div class="md:sticky md:top-1 space-y-2">
          <div class="box space-y-2">
            <.toc_section />
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"category" => category, "slug" => slug} = _params, _session, socket) do
    case Blog.get_post({category, slug}) do
      nil ->
        raise Blog.PostNotFoundError

      post ->
        socket =
          post
          |> Post.render()
          |> Map.take([:frontmatter, :content, :category])
          |> then(&assign(socket, &1))

        {:ok, socket}
    end
  end

  defp header(assigns) do
    ~H"""
    <div class="font-outfit mb-2">
      <h1 class="mb-2 text-2xl font-bold text-gray-700"><%= @frontmatter.title %></h1>
      <div class="flex items-center space-x-4">
        <span class="inline-flex items-center text-silver space-x-2">
          <i class="fas fa-calendar"></i>
          <span class="font-medium"><%= Date.to_string(@frontmatter.date) %></span>
        </span>
        <span class="inline-flex items-center text-silver space-x-2">
          <i class="fas fa-archive"></i>
          <span class="font-medium"><%= String.upcase(@category) %></span>
        </span>
      </div>
    </div>
    """
  end

  defp toc_section(assigns) do
    ~H"""
    <.section_title icon="fas fa-list" text="Table of Contents" />
    <div>
      <div id="table-of-contents" class="relative -font-outfit -text-gray-500">
        loading
      </div>
    </div>
    """
  end
end
