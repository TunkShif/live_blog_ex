defmodule LiveBlogExWeb.PageController do
  use LiveBlogExWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
