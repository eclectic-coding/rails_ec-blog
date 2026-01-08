// Use the global `hljs` provided by the classic script tag

if (typeof window !== 'undefined' && window.hljs) {
  const hljs = window.hljs;

  hljs.configure({
    languages: ['javascript', 'ruby', 'erb', 'css', 'html'],
  })

  document.addEventListener('turbo:load', () => {
    const codeBlocks = document.querySelectorAll('pre code');
    if (codeBlocks.length > 0) {
      codeBlocks.forEach((block) => {
        hljs.highlightElement(block);
      })
    }
  });
}
