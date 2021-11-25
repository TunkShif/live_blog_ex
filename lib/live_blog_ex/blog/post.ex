defmodule LiveBlogEx.Blog.Post do
  defstruct slug: nil, frontmatter: nil, category: nil, content: nil

  alias LiveBlogEx.Helpers.Markdown

  def all() do
    for category <- File.ls!(post_path()),
        file <- Path.join(post_path(), category) |> File.ls!() do
      get(category, Path.basename(file, ".md"))
    end
    |> Enum.reject(&is_draft?/1)
    |> Enum.sort_by(& &1.frontmatter.date, {:desc, Date})
  end

  def get(category, slug) do
    {frontmatter, content} =
      Path.join([post_path(), category, slug <> ".md"])
      |> File.stream!()
      |> parse()

    %__MODULE__{
      frontmatter: frontmatter,
      category: category,
      content: content,
      slug: slug
    }
  end

  def render(%__MODULE__{} = post) do
    post
    |> Map.update!(:content, &Enum.join/1)
    |> Map.update!(:content, &Markdown.as_html/1)
  end

  defp post_path, do: Application.app_dir(:live_blog_ex, "priv/content/posts")

  defp parse(stream) do
    stream = stream |> Stream.chunk_by(&(&1 == "---\n"))

    {
      stream |> parse_frontmatter,
      stream |> parse_content
    }
  end

  defp parse_frontmatter(stream) do
    stream
    |> Stream.drop(1)
    |> Stream.take(1)
    |> Enum.join()
    |> YamlElixir.read_from_string!()
    |> Map.update!("date", &Date.from_iso8601!/1)
    |> Map.new(fn {key, val} -> {String.to_atom(key), val} end)
  end

  defp parse_content(stream) do
    stream |> Stream.drop(3)
  end

  def is_draft?(%__MODULE__{frontmatter: frontmatter}) do
    Map.get(frontmatter, :draft) == true
  end
end
