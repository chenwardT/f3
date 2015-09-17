module PaperTrailable
  extend ActiveSupport::Concern

  included do
    has_paper_trail on: [:update, :destroy], ignore: [:updated_at]
  end

  def set_event(method)
    self.paper_trail_event =  method.to_s.humanize(capitalize: false)
  end
end