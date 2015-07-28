module TopicsHelper
  def new_since_last_view_text(topic)
    if user_signed_in?
      topic_view = topic.view_for(current_user)
      forum_view = topic.forum.view_for(current_user)

      if forum_view
        if topic_view.nil? && topic.created_at > forum_view.past_viewed_at
          content_tag :sup, 'New'
        end
      end
    end
  end
end
