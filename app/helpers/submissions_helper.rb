module SubmissionsHelper
 
  def content_for_edit(submission)
    ContentFixer.quotes_to_symbols(submission.content)
  end

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

  def unique_word_count(submission)
    Analyzer.unique_word_count(submission.processed)
  end

  def most_used_uncommon(submission, count)
    top_used_uncommon = Analyzer.most_used_uncommon(submission.processed)[0..count-1]
    string = ""
    top_used_uncommon.each do |array|
      string << "#{array[0]} (#{array[1]}), "
    end
    return string.rstrip.chop
  end

  def repeated_word_groups(submission, group_by)
    repeated = Analyzer.repeated_word_groups(submission.processed,group_by)
    string = ""
    repeated.each do |array|
      string << "#{array[0]} (#{array[1]}), "
    end
    return string.rstrip.chop
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
