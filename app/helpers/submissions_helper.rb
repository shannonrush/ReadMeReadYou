module SubmissionsHelper
  def has_chapters?(submission)
    submission.chapter_list.present?
  end

  def has_notes?(submission)
    submission.notes.present?
  end

  def date_for_list(submission)
    submission.created_at.strftime("%D")
  end

end
