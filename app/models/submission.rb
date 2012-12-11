class Submission < ActiveRecord::Base
  belongs_to :user
  has_many :chapters, :dependent => :destroy
  has_many :critiques

  attr_accessible :content, :notes, :title, :user_id, :genre

  Submission::GENRES = ["Action","Crime","Fantasy","Historical","Horror","Mystery","Romance","SciFi","Western"];

  validates_presence_of :genre, :message => "must be selected"
  validates_presence_of :title
  validates_presence_of :content, :message => "file must be chosen"

  default_scope order('created_at DESC')

  # submission is active if it is less than a week old or it has less than 5 critiques

  scope :active, joins("LEFT OUTER JOIN critiques ON critiques.submission_id = submissions.id").group("submissions.id").having("count(critiques.id)<5 OR submissions.created_at > ?", Time.zone.now-1.week)

  def self.ordered_by(order_by)
    if order_by == "author"
      return Submission.active.sort {|a,b| a.user.last <=> b.user.last}
    elsif order_by == "word_count"
      return Submission.active.sort {|a,b| b.word_count <=> a.word_count}
    elsif order_by == "critique_count"
      return Submission.active.sort {|a,b| b.critiques.count <=> a.critiques.count}
    else
      return Submission.active.order(order_by)
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
    self.chapters.collect {|c| c.name}.join(", ")
  end

  def create_chapters(chapter_list)
    self.chapters.destroy_all
    unless chapter_list.blank?
      names = chapter_list.split(',')
      names.each {|n| Chapter.create(name:n, submission_id:self.id)}
    end
  end

  def word_count
    self.content.split.size
  end

end
