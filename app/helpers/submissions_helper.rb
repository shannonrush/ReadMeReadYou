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
    return top_used_uncommon.collect {|array| "#{array[0]} (#{array[1]})"}.join(", ")
  end

  def repeated_word_groups(submission, group_by)
    repeated = Analyzer.repeated_word_groups(submission.processed,group_by)
    return repeated.collect {|array| "#{array[0]} (#{array[1]})"}.join(", ")
  end

  def sentence_count(submission)
    Analyzer.sentence_count(submission.processed)
  end

  def average_sentence_length(submission)
    Analyzer.average_sentence_length(submission.processed)
  end

  def sentences_close_with_same_start_word(submission)
    sentence_groups = Analyzer.sentences_close_with_same_start_word(submission.processed)
    return sentence_groups.values.join("\n\n")
  end

  def percentage_sentences_started_with(submission)
    most_started = Analyzer.percentage_sentences_started_with(submission.processed)
    return most_started.collect{|array|"#{array[1]}% of sentences start with the word '#{array[0]}'"}.join("\n")
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
