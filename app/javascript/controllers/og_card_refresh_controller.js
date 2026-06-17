import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.timer = setTimeout(() => this.refresh(), 2000)
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  refresh() {
    fetch(this.urlValue, {
      headers: { "Accept": "text/html" }
    })
      .then(r => r.text())
      .then(html => {
        const doc = new DOMParser().parseFromString(html, "text/html")
        const card = doc.getElementById(this.element.id)
        if (card) {
          this.element.outerHTML = card.outerHTML
        }
      })
      .catch(() => {})
  }
}