module SubmissionsHelper
  def has_chapters?(submission)
    submission.chapter_list.present?
  end

  def has_other_chapters?(submission)
    other_chapters(submission).any?
  end

  def other_chapters(submission)
    other_subs = Submission.where(title:submission.title,user_id:submission.user.id,queued:false) - [submission] 
    return other_subs.collect{|s|s.chapters}.flatten
  end

  def has_notes?(submission)
    submission.notes.present?
  end

  def has_critiques?(submission)
    submission.critiques.present?
  end

end
