class Submission < ActiveRecord::Base
  belongs_to :user
  has_many :chapters, :dependent => :destroy

  attr_accessible :content, :notes, :title, :user_id, :genre

  Submission::GENRES = ["Action","Crime","Fantasy","Historical","Horror","Mystery","Romance","SciFi","Western"];

  validates_presence_of :genre, :message => "must be selected"
  validates_presence_of :title
  validates_presence_of :content, :message => "file must be chosen"

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

end
