import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sun", "moon"]

  connect() {
    this.applyTheme(localStorage.getItem("theme") || "light")
  }

  toggle() {
    const current = document.documentElement.getAttribute("data-bs-theme") || "light"
    this.applyTheme(current === "dark" ? "light" : "dark")
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-bs-theme", theme)
    localStorage.setItem("theme", theme)
    if (this.hasSunTarget) this.sunTarget.classList.toggle("d-none", theme !== "dark")
    if (this.hasMoonTarget) this.moonTarget.classList.toggle("d-none", theme !== "light")
  }
}