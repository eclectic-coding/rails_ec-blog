import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    this.tomSelect = new TomSelect(this.element, {
      plugins: ['remove_button'],
      maxItems: null,
      createOnBlur: true,
      placeholder: 'Select or type to create tags...',
      closeAfterSelect: false,
      hideSelected: true,

      render: {
        option_create(data, escape) {
          return '<div class="create">Add <strong>' + escape(data.input) + '</strong>&hellip;</div>'
        },
        no_results() {
          return '<div class="no-results">No tags found. Type to create a new one.</div>'
        }
      },

      create(input, callback) {
        fetch('/tags', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken,
            'Accept': 'application/json'
          },
          body: JSON.stringify({ tag: { name: input } })
        })
          .then(r => r.json())
          .then(data => {
            if (data.errors) {
              callback(false)
            } else {
              callback({ value: data.id, text: data.name })
            }
          })
          .catch(() => callback(false))
      }
    })
  }

  disconnect() {
    this.tomSelect?.destroy()
  }
}