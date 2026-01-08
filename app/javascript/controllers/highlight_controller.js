import { Controller } from "@hotwired/stimulus"

// Controller to load highlight.js and initialize page-only syntax highlighting
export default class extends Controller {
  static values = { theme: String }

  connect() {
    const theme = this.themeValue || 'tokyo-night-dark'
    const cssHref = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/${theme}.min.css`

    // Inject CSS if not already loaded
    if (!document.querySelector(`link[href="${cssHref}"]`)) {
      const link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = cssHref
      document.head.appendChild(link)
    }

    const loadAndInit = () => {
      // Determine module URL from data attribute (fingerprint-safe) or fall back to the dev asset path.
      const moduleUrl = this.data.get('moduleUrl') || '/assets/syntax_highlight.js'
      import(moduleUrl).catch(() => {
        if (window.hljs) this.highlightAll()
      })
    }

    if (window.hljs) {
      loadAndInit()
    } else {
      // Inject UMD highlight.js script and call loadAndInit on load
      const existing = document.querySelector('script[data-hljs-loader]')
      if (existing) {
        // If another loader script is present, wait for it to load
        existing.addEventListener('load', loadAndInit)
      } else {
        const script = document.createElement('script')
        script.setAttribute('data-hljs-loader', 'true')
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js'
        script.onload = loadAndInit
        document.head.appendChild(script)
      }
    }
  }

  highlightAll() {
    const codeBlocks = this.element.querySelectorAll('pre code')
    if (codeBlocks.length > 0) {
      codeBlocks.forEach((block) => {
        window.hljs.highlightElement(block)
      })
    }
  }
}
