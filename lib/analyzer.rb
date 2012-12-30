class Analyzer
  
  def self.dictionary
    return IO.readlines("#{Rails.root}/data/cmudict")
  end

  def self.create_syllable_hash_data
    syllables = Hash.new(0)
    self.dictionary.each do |line|
      word, pron = line.split(/\s+/, 2)
      syl = pron.gsub(/[^\d]/, '').length
      syllables[word] = syl
    end
    File.open("#{Rails.root}/data/syllables", "wb") {|f| Marshal.dump(syllables, f)}
  end

  def self.syllable_guess(word)
    word.sub!(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '')
    word.sub!(/^y/, '')
    total = word.scan(/[aeiouy]{1,2}/).size
    return total > 0 ? total : 1
  end

  def self.guesser_tester
    total_guessed = 0
    total_correct = 0
    syllables = Analyzer.syllables
    syllables.keys.each do |word|
      total_guessed += 1
      if Analyzer.syllable_guess(word.clone.downcase) == syllables[word]
        total_correct += 1
      else
        puts word
      end
    end
    puts "PERCENT CORRECT: #{total_correct.to_f/total_guessed.to_f}"
  end
  
  def self.syllables
    return File.open("#{Rails.root}/data/syllables", "rb") {|f| Marshal.load(f)}
  end

  def self.words_by_count(text)
    scrubbed = ContentFixer.scrub(text)
    words = scrubbed.split
    word_counts = Hash.new(0)
    words.each do |w|
      word_counts[w.downcase]+=1
  end
    return word_counts
  end
  
  def self.complex_words_total(text)
    words = text.split
    complex = 0
    syllables = Analyzer.syllables
    words.each do |w|
      unless w.include?("-")
        ["ing","ed","es","ly"].each do |suffix|
           w.chomp!(suffix) if w.ends_with?(suffix)
        end
        if syllables[w.upcase] > 2
          complex += 1
        end
      end
    end
    return complex
  end

  def self.word_count(text)
    text.split.size
  end

  def self.sentences(text)
    text.split(/\?\s|!\s|\.\s|\.\.\./)
  end

  def self.sentence_count(text)
    Analyzer.sentences(text).size   
  end

  def self.average_sentence_length(text)
    return Analyzer.word_count(text)/Analyzer.sentence_count(text)
  end

  def self.sentence_counts(text, id=0)
    file = File.open("#{Rails.root}/log/#{id}_sentences","w")
    sentence_counts = Hash.new(0)
    Analyzer.sentences(text).each do |s|
      sentence_counts[s.split.size]+=1
      file.puts "SENTENCE: #{s}"
    end
    file.close
    return Hash[sentence_counts.sort]
  end

  def self.total_syllables(text)
    total = 0
    syllables = Analyzer.syllables
    text.split.each do |word|
      if syllables[word.upcase] > 0
        total += syllables[word.upcase]
      else
        total += Analyzer.syllable_guess(word.clone)
      end
    end
    return total
  end


  def self.lexical_density(text)
    word_counts = Analyzer.words_by_count(text)
    return ((word_counts.keys.count.to_f/word_counts.values.sum.to_f) * 100).round
  end

  def self.gunning_fog(text)
    complexity = (Analyzer.complex_words_total(text).to_f/Analyzer.word_count(text).to_f)*100
    component = Analyzer.average_sentence_length(text).to_f + complexity
    return (0.4*component).round(1)
  end

  def self.flesch_kincaid(text)
    sentence_component = 1.015 * Analyzer.average_sentence_length(text).to_f
    average_syllables = Analyzer.total_syllables(text).to_f/Analyzer.word_count(text).to_f
    syllable_component = 84.6 * average_syllables
    return (206.835 - sentence_component - syllable_component).round(2)
  end

  def self.flesch_kincaid_grade(text)
    sentence_component = 0.39 * average_sentence_length(text).to_f
    average_syllables = Analyzer.total_syllables(text).to_f/Analyzer.word_count(text).to_f
    syllable_component = 11.8 * average_syllables
    return (sentence_component + syllable_component - 15.59).round(1)
  end
end
