module IssuesHelper
  def sanitize_text(html_code)
    truncate(sanitize(html_code), length: 50)
  end
end
