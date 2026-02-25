import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = [
    "signedId",
    "preview",
    "filename",
    "chooseButton",
    "uploadInput",
    "uploadProgress",
    "uploadProgressContainer"
  ]

  static values = {
    directUploadUrl: String
  }

  connect() {
    // Hidden signed-ID field starts disabled so an empty value is never submitted
    if (this.hasSignedIdTarget) {
      this.signedIdTarget.disabled = true
    }
  }

  // ── Modal ────────────────────────────────────────────────────────────────

  openModal(event) {
    event && event.preventDefault()

    // Lazily load the image library turbo-frame on first open
    const frame = document.getElementById("image-library-frame")
    if (frame && !frame.hasAttribute("src")) {
      frame.src = frame.dataset.librarySrc
    }

    const modalEl = document.getElementById("imagePickerModal")
    if (modalEl && window.bootstrap) {
      window.bootstrap.Modal.getOrCreateInstance(modalEl).show()
    }
  }

  closeModal() {
    const modalEl = document.getElementById("imagePickerModal")
    if (modalEl && window.bootstrap) {
      const modal = window.bootstrap.Modal.getInstance(modalEl)
      if (modal) modal.hide()
    }
  }

  // ── Library selection ────────────────────────────────────────────────────

  selectExisting(event) {
    const tile = event.currentTarget
    const signedId = tile.dataset.blobSignedId
    const filename = tile.dataset.blobFilename
    const img = tile.querySelector("img")
    const imgSrc = img ? img.src : null

    this.applySelection(signedId, filename, imgSrc)
    this.closeModal()
  }

  tileKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.selectExisting(event)
    }
  }

  // ── Direct upload ────────────────────────────────────────────────────────

  uploadNew(event) {
    const file = event.target.files && event.target.files[0]
    if (!file) return

    const uploadUrl = this.directUploadUrlValue
    if (!uploadUrl) {
      console.error("image-picker: directUploadUrl value not configured")
      return
    }

    const upload = new DirectUpload(file, uploadUrl, this)
    this.showProgress()

    upload.create((error, blob) => {
      this.hideProgress()

      // Reset file input so the same file can be chosen again later
      if (this.hasUploadInputTarget) {
        this.uploadInputTarget.value = ""
      }

      if (error) {
        console.error("DirectUpload error:", error)
        alert("Upload failed. Please try again.")
        return
      }

      // Build a local preview while the server-side variant is generated
      const reader = new FileReader()
      reader.onload = (e) => {
        if (this.hasPreviewTarget) {
          this.previewTarget.src = e.target.result
          this.previewTarget.classList.remove("d-none")
        }
      }
      reader.readAsDataURL(file)

      this.applySelection(blob.signed_id, blob.filename, null)
      this.closeModal()
    })
  }

  // DirectUpload delegate — wires upload progress to the progress bar
  directUploadWillStoreFileWithXHR(xhr) {
    xhr.upload.addEventListener("progress", (e) => {
      if (!e.lengthComputable) return
      const pct = Math.round((e.loaded / e.total) * 100)
      if (this.hasUploadProgressTarget) {
        this.uploadProgressTarget.style.width = `${pct}%`
        this.uploadProgressTarget.setAttribute("aria-valuenow", pct)
      }
    })
  }

  // ── Remove existing image ────────────────────────────────────────────────

  async removeImage(event) {
    event && event.preventDefault()
    const btn = event.currentTarget
    const url = btn.dataset.removeUrl
    if (!url) return

    if (btn.dataset.confirm && !window.confirm(btn.dataset.confirm)) return

    const token = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const resp = await fetch(url, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": token || "",
          "Accept": "text/vnd.turbo-stream.html, text/html"
        },
        credentials: "same-origin"
      })

      if (resp.ok) {
        const contentType = resp.headers.get("Content-Type") || ""
        if (!contentType.startsWith("text/vnd.turbo-stream.html")) {
          window.location.href = resp.redirected ? resp.url : window.location.href
          return
        }
        const text = await resp.text()
        if (window.Turbo?.renderStreamMessage) {
          window.Turbo.renderStreamMessage(text)
        } else {
          window.location.reload()
        }
        this.resetSelection()
      } else {
        alert("Failed to remove image. Please try again.")
      }
    } catch (e) {
      console.error("Error removing image:", e)
      alert("Error removing image.")
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  applySelection(signedId, filename, imgSrc) {
    if (this.hasSignedIdTarget) {
      this.signedIdTarget.value = signedId
      this.signedIdTarget.disabled = false
    }
    if (this.hasFilenameTarget) {
      this.filenameTarget.value = filename || ""
    }
    if (imgSrc && this.hasPreviewTarget) {
      this.previewTarget.src = imgSrc
      this.previewTarget.classList.remove("d-none")
    }
    if (this.hasChooseButtonTarget) {
      this.chooseButtonTarget.textContent = "Change Image"
    }
  }

  resetSelection() {
    if (this.hasSignedIdTarget) {
      this.signedIdTarget.value = ""
      this.signedIdTarget.disabled = true
    }
    if (this.hasFilenameTarget) {
      this.filenameTarget.value = "No image selected"
    }
    if (this.hasChooseButtonTarget) {
      this.chooseButtonTarget.textContent = "Choose Image"
    }
  }

  showProgress() {
    if (this.hasUploadProgressContainerTarget) {
      this.uploadProgressContainerTarget.classList.remove("d-none")
    }
  }

  hideProgress() {
    if (this.hasUploadProgressContainerTarget) {
      this.uploadProgressContainerTarget.classList.add("d-none")
    }
    if (this.hasUploadProgressTarget) {
      this.uploadProgressTarget.style.width = "0%"
      this.uploadProgressTarget.setAttribute("aria-valuenow", 0)
    }
  }
}

