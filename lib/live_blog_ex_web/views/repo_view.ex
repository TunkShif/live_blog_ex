defmodule LiveBlogExWeb.RepoView do
  use LiveBlogExWeb, :view
  
  def render("update.json", _params) do
    %{msg: "update requested"}
  end
end
