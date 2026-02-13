import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="infinite-scroll"
export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = {
    url: String
  }

  connect() {
    this.loading = false
    this.loadedPages = new Set()
    this.createObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  paginationTargetConnected() {
    // When a new pagination target is added to the DOM, observe it
    this.loading = false

    // Small delay to ensure DOM is fully updated and to prevent immediate trigger
    setTimeout(() => {
      this.observePagination()
    }, 100)
  }

  paginationTargetDisconnected() {
    // When pagination target is removed, stop observing
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  createObserver() {
    // Options for the observer
    const options = {
      root: null, // viewport
      rootMargin: "100px", // Start loading 100px before the element is visible
      threshold: 0
    }

    // Create the observer
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loading) {
          this.loadMore()
        }
      })
    }, options)

    // Observe the initial pagination element if it exists
    if (this.hasPaginationTarget) {
      this.observePagination()
    }
  }

  observePagination() {
    if (!this.observer || !this.hasPaginationTarget) {
      return
    }

    // Get the URL from the pagination element if it has the data attribute
    const paginationElement = this.paginationTarget
    if (paginationElement.dataset.infiniteScrollUrlValue) {
      this.urlValue = paginationElement.dataset.infiniteScrollUrlValue
    }

    // Only observe if we have a valid URL and not already loading
    if (this.urlValue && this.urlValue !== "" && !this.loading) {
      this.observer.observe(paginationElement)
    }
  }

  loadMore() {
    const nextPageUrl = this.urlValue

    // Prevent multiple simultaneous requests
    if (this.loading || !nextPageUrl || nextPageUrl === "") {
      return
    }

    // Check if we've already loaded this page
    if (this.loadedPages.has(nextPageUrl)) {
      return
    }

    // IMMEDIATELY unobserve and set loading flag
    if (this.observer && this.hasPaginationTarget) {
      this.observer.unobserve(this.paginationTarget)
    }

    // Mark this page as being loaded
    this.loadedPages.add(nextPageUrl)

    // Set loading flag
    this.loading = true

    // Fetch the next page
    fetch(nextPageUrl, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }
        return response.text()
      })
      .then(html => {
        // Use Turbo to process the stream
        Turbo.renderStreamMessage(html)
        // Note: loading flag is reset in paginationTargetConnected()
      })
      .catch(error => {
        console.error("Error loading more articles:", error)
        this.loadedPages.delete(nextPageUrl) // Remove from set on error
        this.loading = false
        // Re-observe on error
        if (this.hasPaginationTarget) {
          this.observePagination()
        }
      })
  }
}

