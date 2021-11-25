import Zooming from "zooming";
import Prism from "prismjs";
import katex from "katex";
import renderMathInElement from "katex/contrib/auto-render";
import "./highlighting";
import "./tocbot";

let Hooks = {};

Hooks.MarkdownExt = {
  mounted() {
    // zoomable images
    let zooming = new Zooming({});
    zooming.listen(".img-zoomable");

    // code highlight
    Prism.highlightAllUnder(this.el);

    // math formula
    renderMathInElement(this.el, {
      delimiters: [
        { left: "$$", right: "$$", display: true },
        { left: "$", right: "$", display: false },
      ],
      throwOnError: false,
    });

    // table of contents
    tocbot.init({
      tocSelector: "#table-of-contents",
      contentSelector: "#markdown",
      headingSelector: "h1[id], h2[id]",
    });
  },
  updated() {
    tocbot.refresh();
  },
  destroyed() {
    tocbot.destroy();
  },
};

export default Hooks;
