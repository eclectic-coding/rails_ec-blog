/* eslint-disable no-unused-vars */
// Methods in this controller are referenced declaratively via `data-action` in the ERB view
import { Controller } from "@hotwired/stimulus"

class FilePreviewController extends Controller {
  static targets = ["image", "popup", "caption", "modalImage", "modalCaption"]
  static values = { caption: String }

  // Called when the file input changes
  preview(event) {
    const input = event.target
    const file = input.files && input.files[0]
    if (!file) return

    if (!file.type.startsWith('image/')) return

    const reader = new FileReader()
    reader.onload = () => {
      this.showPreview(reader.result, file.name)
    }
    reader.readAsDataURL(file)
  }

  showPreview(src, filename = '') {
    if (this.hasImageTarget) {
      const img = this.imageTarget
      img.src = src
      img.classList.remove('d-none')
    }

    if (this.hasPopupTarget) {
      const popup = this.popupTarget
      popup.src = src
    }

    // set caption (prefer configured captionValue, fallback to filename)
    const captionText = this.captionValue && this.captionValue.length ? this.captionValue : (filename || '')
    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = captionText
      this.captionTarget.classList.remove('visually-hidden')
    }

    // also populate modal targets if present
    if (this.hasModalImageTarget) {
      this.modalImageTarget.src = src
    }
    if (this.hasModalCaptionTarget) {
      this.modalCaptionTarget.textContent = captionText
    }
  }

  showHover() {
    if (!this.hasPopupTarget) return

    const popup = this.popupTarget
    // ensure popup has an src; if not, try to use image src
    if (!popup.src && this.hasImageTarget) {
      popup.src = this.imageTarget.src || ''
    }

    // determine whether to flip above if there's not enough space below
    try {
      const thumbRect = (this.hasImageTarget) ? this.imageTarget.getBoundingClientRect() : this.element.getBoundingClientRect()
      const spaceBelow = window.innerHeight - thumbRect.bottom
      const estimatedPopupHeight = Math.min(480, window.innerHeight * 0.6) // conservative estimate

      if (spaceBelow < estimatedPopupHeight + 20) {
        popup.classList.add('above')
      } else {
        popup.classList.remove('above')
      }
    } catch (e) {
      // ignore measurement errors
      popup.classList.remove('above')
    }

    popup.style.display = 'block'
    if (this.hasCaptionTarget) {
      this.captionTarget.classList.remove('visually-hidden')
    }

    this.element.setAttribute('aria-expanded', 'true')
  }

  hideHover() {
    if (!this.hasPopupTarget) return
    const popup = this.popupTarget
    popup.style.display = 'none'
    popup.classList.remove('above')
    if (this.hasCaptionTarget) {
      this.captionTarget.classList.add('visually-hidden')
    }
    this.element.setAttribute('aria-expanded', 'false')
  }

  openModal(event) {
    // If the click was triggered by the remove button, it has data-turbo-method etc. Let Turbo handle it.
    if (event && event.target && event.target.closest && event.target.closest('.remove-image-btn')) {
      return
    }
    event && event.preventDefault()
    // populate modal image and caption from popup or image
    const src = (this.hasPopupTarget && this.popupTarget.src) ? this.popupTarget.src : (this.hasImageTarget ? this.imageTarget.src : '')
    const captionText = this.captionValue && this.captionValue.length ? this.captionValue : (this.hasCaptionTarget ? this.captionTarget.textContent : '')

    if (this.hasModalImageTarget) {
      this.modalImageTarget.src = src
    }
    if (this.hasModalCaptionTarget) {
      this.modalCaptionTarget.textContent = captionText
    }

    // Show bootstrap modal if available
    const modalEl = document.getElementById('articleImageModal')
    if (modalEl && window.bootstrap && window.bootstrap.Modal) {
      const modal = new window.bootstrap.Modal(modalEl)
      modal.show()
    } else if (modalEl) {
      // fallback: make modal visible by toggling classes
      modalEl.classList.add('show')
      modalEl.style.display = 'block'
      modalEl.removeAttribute('aria-hidden')
    }
  }

  onKeydown(event) {
    // Enter or Space should open modal
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      this.openModal(event)
    }
  }
}

export default FilePreviewController

