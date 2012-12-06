class Comment < ActiveRecord::Base
  belongs_to :critique
  belongs_to :user

  attr_accessible :content, :critique_id, :user_id
end
