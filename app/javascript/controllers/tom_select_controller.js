import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tom-select"
export default class extends Controller {
  connect() {
    // Skip if already initialized (prevents double initialization)
    if (this.element.tomselect) {
      console.log('TomSelect already initialized on this element')
      return
    }

    // Wait for TomSelect to be available (loaded from CDN)
    this.waitForTomSelect()
  }

  waitForTomSelect() {
    if (typeof TomSelect !== 'undefined') {
      this.setupTomSelect()
    } else {
      // TomSelect not loaded yet, wait and try again
      setTimeout(() => this.waitForTomSelect(), 50)
    }
  }

  setupTomSelect() {
    // Get CSRF token for AJAX requests
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    // Multi-select configuration with inline tag creation
    this.tomSelect = new TomSelect(this.element, {
      plugins: ['remove_button'],
      maxItems: null,              // Allow unlimited selections
      createOnBlur: true,          // Create tag when user clicks away
      placeholder: 'Select or type to create tags...',
      closeAfterSelect: false,     // Keep dropdown open after selecting
      hideSelected: true,          // Hide selected items from dropdown list

      // Customize the create option text
      render: {
        option_create: function(data, escape) {
          return '<div class="create">Add <strong>' + escape(data.input) + '</strong>&hellip;</div>';
        },
        no_results: function(data, escape) {
          return '<div class="no-results">No tags found. Type to create a new one.</div>';
        }
      },

      onInitialize: function() {
        const label = document.querySelector(`label[for="${this.input.id}"]`)
        if (label) {
          if (!label.id) label.id = `label-${this.input.id}`
          this.control_input.setAttribute('aria-labelledby', label.id)
        }
      },

      // Handle creating new tags via AJAX
      create: function(input, callback) {
        // Make AJAX request to create the tag
        fetch('/tags', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken,
            'Accept': 'application/json'
          },
          body: JSON.stringify({ tag: { name: input } })
        })
        .then(response => response.json())
        .then(data => {
          if (data.errors) {
            console.error('Error creating tag:', data.errors)
            callback(false) // Cancel creation
          } else {
            // Return the new tag data
            callback({ value: data.id, text: data.name })
          }
        })
        .catch(error => {
          console.error('Error creating tag:', error)
          callback(false) // Cancel creation
        })
      }
    })
  }

  disconnect() {
    // Destroy the TomSelect instance if it exists
    if (this.tomSelect) {
      this.tomSelect.destroy()
      this.tomSelect = null
    }

    // Also check if element has tomselect property and destroy it
    if (this.element.tomselect) {
      this.element.tomselect.destroy()
    }
  }
}

