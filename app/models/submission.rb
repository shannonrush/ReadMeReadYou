class Submission < ActiveRecord::Base
  belongs_to :user
  has_many :chapters

  attr_accessible :content, :notes, :title, :user_id
end
