module ForumsHelper
  def subforum_links(forum, separator=', ')
    links = []

    forum.forums.each do |subforum|
      link_html = content_tag(:a, subforum.title, href: forum_path(subforum))
      links.push(link_html)
    end

    links.join(separator).html_safe
  end

  # TODO: This could only take a topic and get the post from it.
  def display_last_post_with_topic(topic, post)
    topic_html = content_tag(:a, topic, href: topic_path(topic) + '?page=' + topic.num_pages.to_s + '#reply')
    author_html = content_tag(:a, post.user.username, href: user_path(post.user))
    date_html = content_tag(:small, post.created_at)
    br = tag(:br)

    "#{topic_html}#{br}
     by #{author_html}#{br}
     #{date_html}".html_safe
  end

  def display_last_post(topic)
    author_html = content_tag(:a, topic.last_post.user, href: user_path(topic.last_post.user))
    date_html = content_tag(:small, topic.last_post.created_at)
    br = tag(:br)

    "#{author_html}#{br}
     #{date_html}".html_safe
  end

  def display_topic(topic)
    title_html = content_tag(:a, topic, href: topic_path(topic))
    author_html = content_tag(:a, topic.user, href: user_path(topic.user))
    small_html = content_tag(:small, "Started by #{author_html}, #{topic.created_at.to_s}".html_safe)
    br = tag(:br)

    "#{title_html}#{br}
     #{small_html}".html_safe
  end
end
