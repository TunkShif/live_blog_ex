defmodule LiveBlogExWeb.Components do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias LiveBlogExWeb.Router.Helpers, as: Routes

  def nav_bar(assigns) do
    assigns =
      assigns
      |> assign(
        :mobile_nav_item_classes,
        "flex items-center w-full p-1 space-x-1 rounded-sm outline-none transition ease-in-out duration-300 hover:bg-gray-200 hover:bg-opacity-60 hover:text-dogerblue focus:bg-gray-200 focus:bg-opacity-60 focus:text-dogerblue"
      )
      |> assign(
        :nav_item_classes,
        "flex items-center w-full p-1 spacex-x-1 outline-none transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue"
      )

    ~H"""
    <div class="p-2 mb-2 flex justify-between items-center">
      <h1 class="text-2xl text-gray-700 font-oswald font-bold transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue">
        <%= live_redirect to: Routes.home_path(LiveBlogExWeb.Endpoint, :index) do %>
        TUNKSHIF.ONE
        <% end %>
      </h1>
      <nav class="flex items-center">
        <div class="relative md:hidden">
          <button 
            class="text-xl text-gray-700 outline-none transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue"
            phx-click={toggle_dropdown()}>
            <i class="fas fa-bars"></i>
          </button>
          <div id="nav-dropdown" class="absolute right-0 text-gray-700 font-medium bg-white rounded-sm shadow-md outline-none hidden">
            <div class="p-2 flex flex-col space-y-1">
              <%= live_redirect to: Routes.home_path(LiveBlogExWeb.Endpoint, :index), class: @mobile_nav_item_classes do%>
                <.nav_item icon="fas fa-home" text="Home" />
              <% end %>
              <%= live_redirect to: Routes.home_path(LiveBlogExWeb.Endpoint, :index), class: @mobile_nav_item_classes do%>
                <.nav_item icon="fas fa-archive" text="Archive" />
              <% end %>
              <%= live_redirect to: Routes.home_path(LiveBlogExWeb.Endpoint, :index), class: @mobile_nav_item_classes do%>
                <.nav_item icon="fas fa-info-circle" text="About" />
              <% end %>
            </div>
          </div>
        </div>
        <div class="hidden md:flex space-x-4 text-lg text-gray-700 font-oswald font-bold">
          <%= live_redirect to: Routes.home_path(LiveBlogExWeb.Endpoint, :index), class: @nav_item_classes do%>
            <.nav_item icon="fas fa-home" text="HOME" />
          <% end %>
          <%= live_redirect to: Routes.home_path(LiveBlogExWeb.Endpoint, :index), class: @nav_item_classes do%>
            <.nav_item icon="fas fa-archive" text="ARCHIVE" />
          <% end %>
          <%= live_redirect to: Routes.home_path(LiveBlogExWeb.Endpoint, :index), class: @nav_item_classes do%>
            <.nav_item icon="fas fa-info-circle" text="ABOUT" />
          <% end %>
        </div>
      </nav>
    </div>
    """
  end

  defp nav_item(assigns) do
    ~H"""
    <span class="flex justify-center items-center text-lg p-1"><i class={@icon}></i></span>
    <span><%= @text %></span>
    """
  end

  defp toggle_dropdown(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#nav-dropdown",
      in: {"ease-out duration-300", "opacity-0", "opacity-100"},
      out: {"ease-out duration-300", "opacity-100", "opacity-0"}
    )
  end

  def footer(assigns) do
    ~H"""
    <div class="my-4 text-gray-600 font-oswald font-bold space-y-1">
      <h1>2021 © TUNKSHIF</h1>
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
        <%= live_redirect @tag, to: Routes.tag_path(LiveBlogExWeb.Endpoint, :index, @tag) %>
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
    assigns =
      assigns
      |> assign(
        :post_link_classes,
        "transition ease-in-out duration-300 hover:text-dogerblue focus:text-dogerblue"
      )

    ~H"""
      <div class="box space-y-2">
        <h1 class="text-xl font-bold font-outfit text-gray-700">
          <%= live_redirect @frontmatter.title, to: Routes.post_path(LiveBlogExWeb.Endpoint, :index, @category, @slug), class: @post_link_classes %>
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
end
