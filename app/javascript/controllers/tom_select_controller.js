import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tom-select"
export default class extends Controller {
  connect() {
    // Tom-select CDN version exposes TomSelect globally
    // Wait for the library to be available
    if (typeof TomSelect === 'undefined') {
      console.error('TomSelect is not loaded')
      return
    }

    // Basic multi-select configuration for dropdown with multiple selections
    this.tomSelect = new TomSelect(this.element, {
      plugins: ['remove_button'],
      maxItems: null,              // Allow unlimited selections
      create: false,               // Don't allow creating new tags
      placeholder: 'Select tags...',
      closeAfterSelect: false,     // Keep dropdown open after selecting
      hideSelected: true           // Hide selected items from dropdown list
    })
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }
}

