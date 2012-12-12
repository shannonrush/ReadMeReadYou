class Message < ActiveRecord::Base
  attr_accessible :from, :to, :deleted, :from_id, :message, :read, :subject, :to_id

  belongs_to :from, :class_name => "User", :foreign_key => "from_id"
  belongs_to :to, :class_name => "User", :foreign_key => "to_id"

  validates_presence_of :to
  validates_presence_of :subject
  validates_presence_of :message

  after_create :send_notification

  scope :undeleted, where("deleted IS NOT TRUE")
  scope :to_user, lambda {|user| where(to_id:user.id)}
  scope :from_user, lambda {|user| where(from_id:user.id)}
  default_scope order('created_at DESC')

  protected

  def send_notification
    MessagesMailer.notification(self).deliver
  end
end
