import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["radio"]
  static values = { url: String }

  connect() {
    // Get the root HTML element
    this.htmlElement = document.documentElement
  }

  selectTheme(event) {
    const theme = event.target.value
    
    // Immediately update the theme on the HTML element
    this.htmlElement.setAttribute('data-theme', theme)
    
    // Update saved theme data attribute so theme controller knows user has a preference
    this.htmlElement.setAttribute('data-saved-theme', theme)
    
    // Save preference to backend asynchronously
    this.saveTheme(theme)
  }

  async saveTheme(theme) {
    const formData = new FormData()
    formData.append('user[theme]', theme)

    try {
      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })

      if (!response.ok) {
        console.error('Failed to save theme preference')
      }
    } catch (error) {
      console.error('Error saving theme preference:', error)
    }
  }
}

