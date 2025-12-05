import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]

  connect() {
    this.hide()
  }

  toggle() {
    if (this.contentTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.contentTarget.classList.remove("hidden")
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = this.buttonTarget.dataset.hideText || "Hide"
    }
  }

  hide() {
    this.contentTarget.classList.add("hidden")
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = this.buttonTarget.dataset.showText || "Show"
    }
  }
}

