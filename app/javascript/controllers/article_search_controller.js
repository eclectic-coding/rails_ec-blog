import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  search() {
    clearTimeout(this.debounceTimer)
    const length = this.inputTarget.value.length
    if (length >= 4 || length === 0) {
      this.debounceTimer = setTimeout(() => this.element.requestSubmit(), 300)
    }
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
  }
}