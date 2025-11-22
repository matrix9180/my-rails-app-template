module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when "notice", "success"
      "alert-success"
    when "alert", "error"
      "alert-error"
    when "warning"
      "alert-warning"
    when "info"
      "alert-info"
    else
      "alert"
    end
  end

  def flash_icon_path(type)
    case type.to_s
    when "notice", "success"
      # Checkmark in a circle
      "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
    when "alert", "error"
      # X in a circle
      "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
    when "warning"
      # Triangle with exclamation mark
      "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
    when "info"
      # Circle with "i" information symbol
      "M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z"
    else
      # Default: Checkmark in a circle
      "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
    end
  end
end
