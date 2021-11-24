import Zooming from "zooming";
import Prism from "prismjs";
import katex from "katex";
import renderMathInElement from "katex/contrib/auto-render";
import "./highlighting";

let Hooks = {};

Hooks.MarkdownExt = {
  mounted() {
    const zooming = new Zooming({});
    zooming.listen(".img-zoomable");

    Prism.highlightAllUnder(this.el);

    renderMathInElement(this.el, {
      delimiters: [
        { left: "$$", right: "$$", display: true },
        { left: "$", right: "$", display: false },
      ],
      throwOnError: false,
    });
  },
};

Hooks.ToC = {
  observer: new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      const id = entry.target.getAttribute("id");
      if (entry.isIntersecting) {
        document
          .querySelector(`#table-of-contents a[href="#${id}"]`)
          .parentElement.classList.add("toc-item-active");
      } else {
        document
          .querySelector(`#table-of-contents a[href="#${id}"]`)
          .parentElement.classList.remove("toc-item-active");
      }
    });
  }),
  mounted() {
    document
      .querySelectorAll("h1[id], h2[id]")
      .forEach((element) => this.observer.observe(element));
  },
  destroyed() {
    this.observer.disconnect();
  },
};

export default Hooks;
