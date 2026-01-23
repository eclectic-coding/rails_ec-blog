import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() {
    console.log("Flash controller connected")
    this.element.querySelectorAll('.toast').forEach(toastEl => {
      const toast = new bootstrap.Toast(toastEl)
      toast.show()
      // Remove the toast element from the DOM after it has been hidden to prevent accumulation
      toastEl.addEventListener('hidden.bs.toast', () => {
        toastEl.remove()
      })
    })
  }
}
