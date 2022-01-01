import Zooming from 'zooming'
import Prism from 'prismjs'
import katex from 'katex'
import renderMathInElement from 'katex/contrib/auto-render'

export default () => ({
  async init() {
    await import('./highlighting')
    await import('./tocbot')

    this.$nextTick(() => {
      let zooming = new Zooming({})
      zooming.listen('.img-zoomable')

      // code highlight
      Prism.highlightAllUnder(this.$el)

      // math formula
      renderMathInElement(this.$el, {
        delimiters: [
          { left: '$$', right: '$$', display: true },
          { left: '$', right: '$', display: false }
        ],
        throwOnError: false
      })

      // table of contents
      tocbot.init({
        tocSelector: '.table-of-contents',
        contentSelector: '#markdown',
        headingSelector: 'h1[id], h2[id]'
      })
    })
  }
})
