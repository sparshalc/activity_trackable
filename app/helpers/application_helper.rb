module ApplicationHelper
  include Pagy::Frontend
  def activity_icon_bg_class(action)
    case action
    when "login"
      "bg-green-100"
    when "logout"
      "bg-red-100"
    when "give_recognition", "receive_recognition"
      "bg-yellow-100"
    when "profile_update"
      "bg-blue-100"
    when "company_joined"
      "bg-purple-100"
    when "company_left"
      "bg-orange-100"
    when "role_assigned", "role_removed", "role_switch"
      "bg-indigo-100"
    when "admin_action"
      "bg-pink-100"
    else
      "bg-slate-100"
    end
  end

  def activity_icon_svg(action)
    icon_class = case action
    when "login"
      "text-green-600"
    when "logout"
      "text-red-600"
    when "give_recognition", "receive_recognition"
      "text-yellow-600"
    when "profile_update"
      "text-blue-600"
    when "company_joined"
      "text-purple-600"
    when "company_left"
      "text-orange-600"
    when "role_assigned", "role_removed", "role_switch"
      "text-indigo-600"
    when "admin_action"
      "text-pink-600"
    else
      "text-slate-600"
    end

    svg_path = case action
    when "login"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>'
    when "logout"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>'
    when "give_recognition", "receive_recognition"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"></path>'
    when "profile_update"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>'
    when "company_joined"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>'
    when "company_left"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>'
    when "role_assigned", "role_removed", "role_switch"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>'
    when "admin_action"
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>'
    else
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>'
    end

    raw(%Q(
      <svg class="w-5 h-5 #{icon_class}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        #{svg_path}
      </svg>
    ))
  end

  def time_duration_in_words(seconds)
    return "0 seconds" if seconds.nil? || seconds == 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    remaining_seconds = seconds % 60

    parts = []
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0
    parts << "#{remaining_seconds}s" if remaining_seconds > 0 && hours == 0

    parts.join(" ")
  end

  def parse_user_agent(user_agent)
    return "Unknown" if user_agent.blank?

    # Simple user agent parsing - you might want to use a gem like 'browser' for more sophisticated parsing
    case user_agent
    when /Firefox/
      "Firefox"
    when /Chrome/
      "Chrome"
    when /Safari/
      "Safari"
    when /Edge/
      "Edge"
    when /Opera/
      "Opera"
    else
      "Unknown Browser"
    end
  end

  def truncate_url(url)
    return "" if url.blank?

    begin
      uri = URI.parse(url)
      domain = uri.host || url
      path = uri.path

      if path.present? && path != "/"
        "#{domain}#{path.length > 20 ? path[0..20] + "..." : path}"
      else
        domain
      end
    rescue URI::InvalidURIError
      url.length > 30 ? url[0..30] + "..." : url
    end
  end
end
