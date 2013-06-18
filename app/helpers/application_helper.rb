module ApplicationHelper

  # returns the page title on a per-page basis
  #
  # param string The title of the page to add to the base title
  def full_title(page_title)
    base_title = "Sample App"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end