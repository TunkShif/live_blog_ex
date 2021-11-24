defmodule LiveBlogEx.Helpers.Markdown do
  @code_block_prefix "language-"
  @title_tags ["h1", "h2"]

  def as_html(source) do
    {:ok, ast, []} = EarmarkParser.as_ast(source, code_class_prefix: @code_block_prefix)

    ast
    |> Earmark.Transform.map_ast(&image_transformer/1)
    |> Earmark.Transform.map_ast(&title_transformer/1)
    |> Earmark.transform()
  end

  defp image_transformer({"p", _, [{"img", _, _, _}], _}) do
    {"figure", [], [], %{}}
  end

  defp image_transformer({"img", attrs, _, _}) do
    {"img", [{"class", "img-zoomable"} | attrs], [], %{}}
  end

  defp image_transformer(node), do: node

  defp title_transformer({tag, attrs, children, _} = node) when tag in @title_tags do
    title = node |> Earmark.Transform.transform() |> Floki.parse_fragment!() |> Floki.text()
    {tag, [{"id", Slug.slugify(title)} | attrs], children, %{}}
  end

  defp title_transformer(node), do: node
end
