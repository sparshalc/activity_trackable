import { Controller } from "@hotwired/stimulus"
import Notification from "@stimulus-components/notification"

// Connects to data-controller="notification"
export default class extends Notification {
  connect() {
    super.connect()
    console.log("Subscribed to notifications controller ;)")
  }
}