import { Controller } from "@hotwired/stimulus"
import { highlightAll } from "lexxy"
// Or if you installed via a javascript bundler:
// import { highlightAll } from "@37signals/lexxy"

export default class extends Controller {
  connect() {
    highlightAll()
  }
}