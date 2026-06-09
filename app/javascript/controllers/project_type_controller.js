import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rubygemGroup", "typeSelect"]

  connect() {
    this.toggle()
  }

  toggle() {
    this.rubygemGroupTarget.hidden = this.typeSelectTarget.value !== "rubygem"
  }
}