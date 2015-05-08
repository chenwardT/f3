module ForumsHelper
  def subforum_links(forum, separator=', ')
    links = []

    forum.forums.each do |subforum|
      links.push('<a href="' + forum_path(subforum) + '">' + subforum.title + '</a>')
    end

    links.join(separator).html_safe
  end
end
