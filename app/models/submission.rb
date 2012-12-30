class Submission < ActiveRecord::Base
  belongs_to :user
  has_many :chapters, :dependent => :destroy
  has_many :critiques

  attr_accessor :processed, :word_counts
  attr_accessible :content, :notes, :title, :user_id, :genre, :activated_at, :queued

  Submission::GENRES = ["Action","Crime","Fantasy","Historical","Horror","Mystery","Romance","SciFi","Western"]

  validates_presence_of :genre, :message => "must be selected"
  validates_presence_of :title
  validates_presence_of :content, :message => "file must be chosen"
  validates_presence_of :user
  validates :content, :length => {
           :maximum   => 10000,
           :tokenizer => lambda { |str| str.split },
           :too_long => "is too long, maximum is 10000 words"
  }
  
  default_scope order('created_at DESC')

  scope :not_in_queue, where(queued:false)
  scope :in_queue, where(queued:true)
  scope :needs_time_or_critiques, joins("LEFT OUTER JOIN critiques ON critiques.submission_id = submissions.id").group("submissions.id").having("count(critiques.id)<5 OR submissions.activated_at > ?", Time.zone.now-1.week)

  scope :active, needs_time_or_critiques.not_in_queue

  after_create :add_to_queue, :if => :should_be_queued?
  after_create :alert_previous_critiquers, :unless => :queued?
  after_create :add_activated_at, :unless => :queued?

  def self.inactive
    Submission.all - Submission.active
  end
  
  def self.ordered_by(order_by)
    if order_by == "author"
      return Submission.active.sort {|a,b| a.user.last <=> b.user.last}
    elsif order_by == "word_count"
      return Submission.active.sort {|a,b| a.content.split.size <=> b.content.split.size}
    elsif order_by == "critique_count"
      return Submission.active.sort {|a,b| b.critiques.count <=> a.critiques.count}
    elsif order_by == "title"
      return Submission.active.sort {|a,b| a.title <=> b.title}
    elsif order_by == "genre"
      return Submission.active.sort {|a,b| a.genre <=> b.genre}
    elsif order_by == "activated_at"
      return Submission.active.order("activated_at")
    else
      return Submission.active.shuffle
    end
  end

  def title_with_chapters
    title = self.title.truncate(40)
    unless self.chapter_list.blank?
      title << " Ch. #{self.chapter_list.truncate(30)}"
    end
    return title
  end

  def chapter_list
    self.chapters.collect {|c| c.name_with_version}.join(", ")
  end

  def create_chapters(chapter_list)
    self.chapters.destroy_all
    unless chapter_list.blank?
      names = chapter_list.split(',')
      names.each { |n| Chapter.create(name:n, submission_id:self.id)}
    end
  end


  def title_critiquers
    # returns unique list of users previously critiquing title
    prev_subs_with_title = self.user.submissions.collect {|s| s if s.title == self.title}.compact
    prev_subs_critiques = prev_subs_with_title.collect {|s| s.critiques}.flatten
    return prev_subs_critiques.collect {|c| c.user}.uniq
  end

  def author_critiquers
    # returns unique list of users previous critiquing author
    prev_subs = self.user.submissions
    prev_critiques = prev_subs.collect {|s| s.critiques}.flatten
    return prev_critiques.collect {|c| c.user}.uniq
  end

  def should_be_queued?
    self.author_has_active_submission? || User.has_queued_submissions.include?(self.user)   
  end
  
  def author_has_active_submission?
    [Submission.active & self.user.submissions-[self]].flatten.any?
  end

  def self.activate_submissions
    User.needs_submission_activated.each do |u|
      submission = self.first_queued_for_user(u)
      submission.update_attributes(queued:false,activated_at:Time.zone.now)
      submission.alert_previous_critiquers
    end
  end

  def self.first_queued_for_user(user)
    user.submissions.where(queued:true).sort_by(&:created_at).first 
  end
  
  def alert_previous_critiquers
    self.user.submissions.reload
    title_critiquers = self.title_critiquers
    author_critiquers = self.author_critiquers - title_critiquers

    title_critiquers.each {|c| alert_title_critiquer(c.id)}
    author_critiquers.each {|c| alert_author_critiquer(c.id)}
  end

  protected

  def add_to_queue
    self.update_attribute(:queued,true)
  end

  def alert_title_critiquer(critiquer_id)
    Alert.generate(critiquer_id,"#{self.title} has a new submission","/submissions/#{self.id}") 
  end

  def alert_author_critiquer(critiquer_id)
    Alert.generate(critiquer_id,"#{self.user.full_name} has a new submission","/submissions/#{self.id}")
  end

  def add_activated_at
    self.update_attribute(:activated_at,self.created_at)
  end

end
