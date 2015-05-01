class Category < ActiveRecord::Base
  has_many :forums

  def to_s
    title
  end
end
