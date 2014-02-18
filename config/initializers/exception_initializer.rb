module ExceptionNotifierHelper

  def render_section(section)
    RAILS_DEFAULT_LOGGER.info("rendering section #{section.inspect}")
    summary = render_overridable(section).strip
    unless summary.blank?
      title = render_overridable(:title, :locals => { :title => section }).strip
      "#{title}\n\n#{ title != 'Redmine' ? summary : summary.gsub(/^/, "  ")}\n\n"
    end
  end
end

ExceptionNotifier.sections.unshift("redmine")
