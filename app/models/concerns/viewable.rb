require 'active_support/concern'

module Viewable
  extend ActiveSupport::Concern

  included do
    has_many :views, :as => :viewable, :dependent => :destroy
  end

  def view_for(user)
    views.find_by(user_id: user.id)
  end

  def register_view_by(user)
    return unless user
    view = views.find_or_create_by(user_id: user.id)
    view.increment!('count')  # user-specific views
    increment!(:views_count)  # global views

    if view.current_viewed_at.nil?
      view.past_viewed_at = view.current_viewed_at = Time.now
    end

    if view.current_viewed_at < 15.minutes.ago
      view.past_viewed_at = view.current_viewed_at
      view.current_viewed_at = Time.now
      view.save
    end
  end
end