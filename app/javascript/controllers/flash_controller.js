import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.showToasts()

    // Bind event handlers to maintain context
    this.boundHandleTurboSubmit = this.handleTurboSubmit.bind(this)
    this.boundHandleTurboRender = this.handleTurboRender.bind(this)
    this.boundHandleBeforeCache = this.handleBeforeCache.bind(this)

    // Listen for Turbo events to show flash messages
    document.addEventListener('turbo:submit-end', this.boundHandleTurboSubmit)
    document.addEventListener('turbo:render', this.boundHandleTurboRender)
    document.addEventListener('turbo:frame-render', this.boundHandleTurboRender)
    document.addEventListener('turbo:before-cache', this.boundHandleBeforeCache)
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener('turbo:submit-end', this.boundHandleTurboSubmit)
    document.removeEventListener('turbo:render', this.boundHandleTurboRender)
    document.removeEventListener('turbo:frame-render', this.boundHandleTurboRender)
    document.removeEventListener('turbo:before-cache', this.boundHandleBeforeCache)
  }

  showToasts() {
    const toasts = this.element.querySelectorAll('.toast')

    toasts.forEach(toastEl => {
      // Skip if already initialized or showing
      if (toastEl.dataset.bsInitialized === 'true') {
        return
      }

      // Mark as initialized before showing
      toastEl.dataset.bsInitialized = 'true'

      // Use window.bootstrap which is set in application.js
      if (window.bootstrap && window.bootstrap.Toast) {
        const toast = new window.bootstrap.Toast(toastEl)
        toast.show()

        // Remove the toast element from the DOM after it has been hidden to prevent accumulation
        toastEl.addEventListener('hidden.bs.toast', () => {
          toastEl.remove()
        })
      } else {
        console.error("Bootstrap Toast not available. Make sure Bootstrap is loaded in application.js")
      }
    })
  }

  handleTurboSubmit() {
    // After a Turbo form submission, check for new flash messages
    // Use setTimeout to ensure DOM has fully updated
    setTimeout(() => {
      this.showToasts()
    }, 100)
  }

  handleTurboRender() {
    // After a Turbo render (navigation or frame update), check for new flash messages
    setTimeout(() => {
      this.showToasts()
    }, 100)
  }

  handleBeforeCache() {
    // Remove all toasts before Turbo caches the page
    // This prevents old toasts from reappearing when navigating back
    this.element.querySelectorAll('.toast').forEach(toast => {
      toast.remove()
    })
  }
}
