import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Autogrow controller connected")
    this.resize()
  }

  resize() {
    this.element.style.height = "auto"

    let borderHeight = (this.element.offsetHeight - this.element.clientHeight)

    this.element.style.height = `${this.element.scrollHeight + borderHeight}px`
  }
}
