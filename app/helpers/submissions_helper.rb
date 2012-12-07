module SubmissionsHelper
  def has_chapters?(submission)
    submission.chapter_list.present?
  end

  def has_notes?(submission)
    submission.notes.present?
  end
end
