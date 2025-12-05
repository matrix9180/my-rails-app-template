import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "codeList"]
  static values = { 
    text: String,
    successMessage: { type: String, default: "Copied!" }
  }

  async copy() {
    let textToCopy = this.textValue

    // If no text value is set, try to get it from the source target
    if (!textToCopy && this.hasSourceTarget) {
      textToCopy = this.sourceTarget.textContent.trim()
    }

    // If we have a code list target, collect all codes from list items
    if (!textToCopy && this.hasCodeListTarget) {
      const codes = Array.from(this.codeListTarget.querySelectorAll('li'))
        .map(li => li.textContent.trim())
        .filter(code => code.length > 0)
        .join('\n')
      textToCopy = codes
    }

    if (!textToCopy) {
      console.error("No text to copy")
      return
    }

    try {
      await navigator.clipboard.writeText(textToCopy)
      this.showSuccess()
    } catch (err) {
      console.error("Failed to copy text: ", err)
      // Fallback for older browsers
      this.fallbackCopyTextToClipboard(textToCopy)
    }
  }

  fallbackCopyTextToClipboard(text) {
    const textArea = document.createElement("textarea")
    textArea.value = text
    textArea.style.top = "0"
    textArea.style.left = "0"
    textArea.style.position = "fixed"
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      const successful = document.execCommand('copy')
      if (successful) {
        this.showSuccess()
      } else {
        console.error("Fallback: Copy command failed")
      }
    } catch (err) {
      console.error("Fallback: Unable to copy", err)
    }

    document.body.removeChild(textArea)
  }

  showSuccess() {
    // Create a flash notice that matches the app's flash message style
    const flashContainer = document.querySelector('.fixed.top-16 .pointer-events-auto.space-y-2')
    if (!flashContainer) return

    const notice = document.createElement('div')
    notice.setAttribute('role', 'alert')
    notice.className = 'alert alert-success shadow-lg'
    notice.setAttribute('data-controller', 'flash')
    notice.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>Recovery codes copied to clipboard</span>
      <button type="button" class="btn btn-sm btn-ghost" data-action="click->flash#close">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    `

    flashContainer.appendChild(notice)

    // Auto-remove after 5 seconds
    setTimeout(() => {
      if (notice.parentNode) {
        notice.remove()
      }
    }, 5000)
  }
}

