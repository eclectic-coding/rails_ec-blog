/* eslint-disable no-unused-vars */
// Methods in this controller are referenced declaratively via `data-action` in the ERB view
import { Controller } from "@hotwired/stimulus"

class FilePreviewController extends Controller {
  static targets = ["image", "modalImage", "modalCaption"]
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

    // set caption (prefer configured captionValue, fallback to filename)
    const captionText = this.captionValue && this.captionValue.length ? this.captionValue : (filename || '')

    // also populate modal targets if present
    if (this.hasModalImageTarget) {
      this.modalImageTarget.src = src
    }
    if (this.hasModalCaptionTarget) {
      this.modalCaptionTarget.textContent = captionText
    }
  }

  openModal(event) {
    // If the click was triggered by the remove button, let Turbo handle it
    if (event && event.target && event.target.closest && event.target.closest('.remove-image-btn')) {
      return
    }
    event && event.preventDefault()

    // populate modal image and caption from thumbnail image target
    const src = (this.hasImageTarget && this.imageTarget.src) ? this.imageTarget.src : ''
    const captionText = this.captionValue && this.captionValue.length ? this.captionValue : ''

    if (this.hasModalImageTarget) {
      this.modalImageTarget.src = src
    }
    if (this.hasModalCaptionTarget) {
      this.modalCaptionTarget.textContent = captionText
    }

    // Show bootstrap modal if available
    const modalEl = document.getElementById('articleImageModal')
    const removeBtn = this.element.querySelector('.remove-image-btn')

    if (modalEl && window.bootstrap && window.bootstrap.Modal) {
      const modal = new window.bootstrap.Modal(modalEl)

      // Hide remove button while modal is open
      const onShown = () => {
        if (removeBtn) removeBtn.style.visibility = 'hidden'
      }
      const onHidden = () => {
        if (removeBtn) removeBtn.style.visibility = ''
        // cleanup listeners
        modalEl.removeEventListener('shown.bs.modal', onShown)
        modalEl.removeEventListener('hidden.bs.modal', onHidden)
      }

      modalEl.addEventListener('shown.bs.modal', onShown)
      modalEl.addEventListener('hidden.bs.modal', onHidden)

      modal.show()
    } else if (modalEl) {
      // fallback: make modal visible by toggling classes and also hide remove button
      if (removeBtn) removeBtn.style.visibility = 'hidden'
      modalEl.classList.add('show')
      modalEl.style.display = 'block'
      modalEl.removeAttribute('aria-hidden')

      // when user closes (via close button) restore remove button; listen for click on backdrop close or close button
      const closeHandler = (e) => {
        if (removeBtn) removeBtn.style.visibility = ''
        modalEl.classList.remove('show')
        modalEl.style.display = 'none'
        modalEl.setAttribute('aria-hidden', 'true')
        modalEl.removeEventListener('click', closeHandler)
      }
      // attach once; closing via backdrop or close button should bubble to modal for our simple fallback
      modalEl.addEventListener('click', closeHandler)
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

