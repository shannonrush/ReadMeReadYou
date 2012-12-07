class Submission < ActiveRecord::Base
  belongs_to :user
  has_many :chapters, :dependent => :destroy

  attr_accessible :content, :notes, :title, :user_id

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
