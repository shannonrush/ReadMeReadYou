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

  def self.lexical_density(text)
    word_counts = Analyzer.words_by_count(text)
    return ((word_counts.keys.count.to_f/word_counts.values.sum.to_f) * 100).round
  end

  def self.gunning_fog(text)
    complexity = (Analyzer.complex_words_total(text).to_f/Analyzer.word_count(text).to_f)*100
    component = Analyzer.average_sentence_length(text).to_f + complexity
    return (0.4*component).round(1)
  end


end
