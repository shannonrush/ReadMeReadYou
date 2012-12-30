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

  def word_count(submission)
    Analyzer.word_count(submission.processed)
  end

  def sentence_count(submission)
    Analyzer.sentence_count(submission.processed)
  end

  def average_sentence_length(submission)
    Analyzer.average_sentence_length(submission.processed)
  end

  def lexical_density(submission)
    Analyzer.lexical_density(submission.processed)
  end

  def gunning_fog(submission)
    Analyzer.gunning_fog(submission.processed)
  end

  def flesch_kincaid(submission)
    Analyzer.flesch_kincaid(submission.processed)
  end

  def flesch_kincaid_grade(submission)
    Analyzer.flesch_kincaid_grade(submission.processed)
  end
end
