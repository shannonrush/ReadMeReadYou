class Chapter < ActiveRecord::Base
  belongs_to :submission

  attr_accessible :name, :submission_id, :submission, :version

  after_create :add_version

  def name_with_version
    self.version? ? "#{self.name} (v#{self.version})" : self.name
  end

  protected

  def add_version
    title = self.submission.title
    author = self.submission.user
    other_subs_for_title = author.submissions.where(title:title) - [self.submission]
    prev_versions_of_chapter = other_subs_for_title.collect {|s| s.chapters.where(name:self.name)}.flatten
    if prev_versions_of_chapter.any?
      versions = prev_versions_of_chapter.collect {|c| c.version}.compact.sort
      version = versions.any? ? versions.last + 1 : 2
      self.update_attribute(:version,version)
    end
  end
end
