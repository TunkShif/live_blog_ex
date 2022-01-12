defmodule LiveBlogExWeb.Components do
  use Phoenix.Component
  import Phoenix.HTML.Link

  alias LiveBlogExWeb.Router.Helpers, as: Routes

  def nav_bar(assigns) do
    assigns =
      assigns
      |> assign(
        mobile_nav_item_classes:
          "flex items-center w-full p-1 space-x-1 rounded-sm outline-none transition ease-in-out duration-300 hover:bg-gray-200 hover:bg-opacity-60 hover:text-dogerblue focus:bg-gray-200 focus:bg-opacity-60 focus:text-dogerblue",
        nav_item_classes:
          "flex items-center w-full p-1 spacex-x-1 outline-none transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue"
      )

    ~H"""
    <div class="p-2 mb-2 flex justify-between items-center">
      <h1 class="text-2xl text-gray-700 font-oswald font-bold transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue">
        <%= link to: Routes.page_path(LiveBlogExWeb.Endpoint, :index) do %>
        TUNKSHIF.ONE
        <% end %>
      </h1>
      <nav class="flex items-center">
        <div class="relative md:hidden" x-data="{ open: false }">
          <button
            class="text-xl text-gray-700 outline-none transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue"
            @click="open = !open">
            <i class="fas fa-bars"></i>
          </button>
          <div class="absolute right-0 text-gray-700 font-medium bg-white rounded-sm shadow-md outline-none" x-show="open" @click.away="open = false" x-transition>
            <div class="p-2 flex flex-col space-y-1">
              <.nav_item icon="fas fa-home" text="Home" class={@mobile_nav_item_classes} />
              <.nav_item icon="fas fa-archive" text="Archive" class={@mobile_nav_item_classes} />
              <.nav_item icon="fas fa-info-circle" text="About" class={@mobile_nav_item_classes} />
            </div>
          </div>
        </div>
        <div class="hidden md:flex space-x-4 text-lg text-gray-700 font-oswald font-bold">
          <.nav_item icon="fas fa-home" text="HOME" class={@nav_item_classes} />
          <.nav_item icon="fas fa-archive" text="ARCHIVE" class={@nav_item_classes} />
          <.nav_item icon="fas fa-info-circle" text="ABOUT" class={@nav_item_classes} />
        </div>
      </nav>
    </div>
    """
  end

  defp nav_item(assigns) do
    ~H"""
    <%= link to: Routes.page_path(LiveBlogExWeb.Endpoint, :index), class: @class do%>
      <span class="flex justify-center items-center text-lg p-1"><i class={@icon}></i></span>
      <span><%= @text %></span>
    <% end %>
    """
  end

  def footer(assigns) do
    ~H"""
    <div class="my-4 text-gray-600 font-oswald font-bold space-y-1">
      <h1>2022 © TUNKSHIF</h1>
      <p class="text-sm">
        Powered By <span class="underline">PETL</span> (Phoenix · Elixir · TailwindCSS · LiveView)
      </p>
    </div>
    """
  end

  def section_title(assigns) do
    ~H"""
    <h2 class="flex items-center text-lg text-silver space-x-2">
      <i class={@icon}></i>
      <span class="font-oswald font-bold"><%= String.upcase(@text) %></span>
    </h2>
    """
  end

  def tags_section(assigns) do
    ~H"""
      <div class="space-y-2 ">
        <.section_title icon="fas fa-tag" text="tags" />
        <.tag_group tags={@tags} />
      </div>
    """
  end

  def tag_group(assigns) do
    ~H"""
    <div class="flex flex-wrap max-h-32 md:max-h-[36em] overflow-y-auto">
      <%= for tag <- @tags do %>
        <.tag_item tag={tag} />
      <% end %>
    </div>
    """
  end

  def tag_item(assigns) do
    ~H"""
    <span
      class="px-2 py-1 mr-2 my-2 text-gray-600 text-sm font-bold font-outfit bg-whitesmoke rounded-sm transition duration-300 ease-in-out hover:bg-blue-100 hover:text-dogerblue focus:bg-blue-100 focus:text-dogerblue">
        <%= link @tag, to: Routes.tag_path(LiveBlogExWeb.Endpoint, :index, @tag) %>
    </span>
    """
  end

  def posts_section(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= for post <- @posts do %>
        <.post frontmatter={post.frontmatter} category={post.category} slug={post.slug} />
      <% end %>
    </div>
    <.pagination current_page={@current_page} max_page={@max_page} />
    """
  end

  def post(assigns) do
    language = case Map.get(assigns.frontmatter, :lang) do
      "zh" -> "中文"
      _ -> "EN"
    end
    assigns =
      assigns
      |> assign(
        :post_link_classes,
        "transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue"
      )

    ~H"""
      <div class="box space-y-2">
        <h1 class="text-xl font-bold font-outfit text-gray-700">
          <%= link @frontmatter.title, to: Routes.post_path(LiveBlogExWeb.Endpoint, :index, @category, @slug), class: @post_link_classes %>
        </h1>
        <div class="text-gray-800">
          <%= @frontmatter.desc %>
        </div>
        <div class="flex items-center space-x-4">
          <span class="inline-flex items-center text-silver space-x-2">
            <i class="fas fa-calendar"></i>
            <span class="font-medium"><%= Calendar.strftime(@frontmatter.date, "%b, %d") %></span>
          </span>
          <span class="inline-flex items-center text-silver space-x-2">
            <i class="fas fa-archive"></i>
            <span class="font-medium"><%= String.upcase(@category) %></span>
          </span>
          <span class="inline-flex items-center text-silver space-x-2">
            <i class="fas fa-globe-asia"></i>
            <span class="font-medium"><%= language %></span>
          </span>
        </div>
      </div>
    """
  end

  def pagination(assigns) do
    assigns =
      assigns
      |> assign(
        :button_classes,
        "px-2 py-1 text-center  text-gray-600 font-bold font-outfit bg-white rounded-sm transition duration-300 ease-in-out hover:bg-blue-100 hover:text-dogerblue focus:bg-blue-100 focus:text-dogerblue"
      )
      |> assign(
        :active_button_classes,
        "px-2 py-1 text-center font-bold font-outfit rounded-sm bg-blue-100 text-dogerblue"
      )

    ~H"""
      <div class="flex justify-center items-center space-x-2">
        <%= unless @current_page == 1 do %>
          <%= live_redirect "PREV", to: Routes.home_path(LiveBlogExWeb.Endpoint, :page, @current_page - 1), class: @button_classes %>
        <% end %>
        <span class={@active_button_classes}><%= @current_page %></span>
        <%= unless @current_page == @max_page do %>
          <%= live_redirect "NEXT", to: Routes.home_path(LiveBlogExWeb.Endpoint, :page, @current_page + 1), class: @button_classes %>
        <% end %>
      </div>
    """
  end

  def profile_section(assigns) do
    ~H"""
      <div class="space-y-2">
        <figure class="flex justify-center items-center" >
          <img class="rounded-full border-2 border-whitesmoke shadow-sm" src="/images/avatar.jpeg" width="96" height="96" alt="avatar" />
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
