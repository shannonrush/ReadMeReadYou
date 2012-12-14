class Chapter < ActiveRecord::Base
  belongs_to :submission

  attr_accessible :name, :submission_id, :submission
end
