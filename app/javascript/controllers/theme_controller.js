import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Check if user has a saved theme preference
    const savedTheme = this.element.dataset.savedTheme
    
    // If no saved theme (empty string or null), use system preference
    if (!savedTheme || savedTheme === '') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      if (prefersDark) {
        this.element.setAttribute('data-theme', 'dark')
      } else {
        this.element.setAttribute('data-theme', 'light')
      }
      
      // Listen for system theme changes (only if user hasn't set a custom theme)
      this.systemThemeListener = (e) => {
        // Check again if user has set a theme (might have changed)
        const currentSavedTheme = this.element.dataset.savedTheme
        if (!currentSavedTheme || currentSavedTheme === '') {
          if (e.matches) {
            this.element.setAttribute('data-theme', 'dark')
          } else {
            this.element.setAttribute('data-theme', 'light')
          }
        }
      }
      
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', this.systemThemeListener)
    }
  }

  disconnect() {
    // Clean up event listener if it was added
    if (this.systemThemeListener) {
      window.matchMedia('(prefers-color-scheme: dark)').removeEventListener('change', this.systemThemeListener)
    }
  }
}
