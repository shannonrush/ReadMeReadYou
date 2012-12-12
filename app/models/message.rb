class Message < ActiveRecord::Base
  attr_accessible :deleted, :from_id, :message, :read, :subject, :to_id

  belongs_to :from, :class_name => "User", :foreign_key => "from_id"
  belongs_to :to, :class_name => "User", :foreign_key => "to_id"

  validates_presence_of :to
  validates_presence_of :subject
  validates_presence_of :message

  scope :undeleted, where("deleted IS NOT TRUE")
  scope :to_user, lambda {|user| where(to_id:user.id)}
  scope :from_user, lambda {|user| where(from_id:user.id)}
  default_scope order('created_at DESC')

end
