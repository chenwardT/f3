module ForumsHelper
  def subforum_links(forum, separator=', ')
    links = []

    forum.forums.each do |subforum|
      links.push('<a href="' + forum_path(subforum) + '">' + subforum.title + '</a>')
    end

    links.join(separator).html_safe
  end

  def display_last_post_with_topic(topic, post)
    topic_html = content_tag(:a, topic, href: topic_path(topic) + '?page=' + topic.num_pages.to_s + '#reply')
    author_html = content_tag(:a, post.user.username, href: user_path(post.user))
    date_html = content_tag(:small, post.created_at)
    br = tag(:br)

    "#{topic_html}#{br}
     by #{author_html}#{br}
     #{date_html}".html_safe
  end
end
