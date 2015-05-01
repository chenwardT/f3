class Forum < ActiveRecord::Base
  belongs_to :category

  has_many :topics

  def to_s
    title
  end
end
