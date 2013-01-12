class Analyzer
  require 'engtagger'

  def self.dictionary
    return IO.readlines("#{Rails.root}/data/cmudict")
  end
  
  def self.syllables
    return File.open("#{Rails.root}/data/syllables", "rb") {|f| Marshal.load(f)}
  end

  def self.tag_words(text,remove_ignored=false)
    tgr = EngTagger.new
    tagged_string = tgr.get_readable(text.clone)
    tagged = []
    tagged_string.split.each do |pair|
      parts = pair.split("/")
      unless remove_ignored && Analyzer.ignore_tag?(parts[1])
        tagged << [parts[0],parts[1]]
      end
    end
    return tagged
  end

  def self.chunk_sentence(sentence)
    tagged_words = Analyzer.tag_words(sentence,true)
    chunked = []
    last_i = tagged_words.count-1
    i=0
    while i <= last_i
      tagged = tagged_words[i]  
      tag = tagged[1]
      chunk = []
      if Analyzer.tag_is_determiner?(tag)
        chunk << "NP"
        i,noun_words = Analyzer.extract_noun_phrase
        chunk.concat(noun_words)
        chunked << chunk
      end
    end
    return chunked
  end

  def self.extract_noun_phrase(tagged_words, i)
    # extract (D) (AdjP+) N (PP+) (CP)
    noun_words = []
    tagged = tagged_words[i] rescue nil
    if tagged && Analyzer.tag_is_determiner?(tagged[1])
      noun_words << tagged[0]
      i+=1
      tagged = tagged_words[i] rescue nil
    end
    while tagged && Analyzer.tag_is_adjective?(tagged[1]) || Analyzer.tag_is_adverb?(tagged[1])
      i, ad_words = Analyzer.extract_ad_phrase(tagged_words, i)
      noun_words.concat(ad_words)
      tagged = tagged_words[i] rescue nil
    end
    if tagged && Analyzer.tag_is_noun?(tagged[1])
      noun_words << tagged[0]
      i+=1
      tagged = tagged_words[i] rescue nil
    else
      return i, noun_words
    end
    while tagged && Analyzer.tag_is_preposition?(tagged[1])
      noun_words << tagged[0]
      i,np_words = Analyzer.extract_noun_phrase(tagged_words,i)
      noun_words.concat(np_words)
      tagged = tagged_words[i] rescue nil
    end
   
    return i, noun_words
  end

  def self.extract_ad_phrase(tagged_words, i)
    # extract (Adv+){Adv/Adj}
    ad_words = []
    tagged = tagged_words[i] rescue nil
    while tagged && Analyzer.tag_is_adverb?(tagged[1])
      ad_words << tagged[0]
      i+=1
      tagged = tagged_words[i] rescue nil
    end
    if tagged && Analyzer.tag_is_adjective?(tagged[1])
      ad_words << tagged[0]
      i+=1
    end
    return i, ad_words
  end

  def self.ignore_tag?(tag)
    tag.start_with?('PP') || ['LRB','RRB','SYM','FW','LS'].include?(tag)
  end

  def self.tag_is_determiner?(tag)
    tag=='DET'
  end

  def self.tag_is_adjective?(tag)
    tag.start_with?('JJ')
  end

  def self.tag_is_adverb?(tag)
    tag.start_with?('R') || tag=='WRB'
  end


  def self.tag_is_preposition?(tag)
    tag=='IN' || tag=='TO'
  end

  def self.tag_is_noun?(tag)
    tag.start_with?('N') || tag=='EX'
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
    word = word.clone
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
      if Analyzer.syllable_guess(word.downcase) == syllables[word]
        total_correct += 1
      else
        puts word
      end
    end
    puts "PERCENT CORRECT: #{total_correct.to_f/total_guessed.to_f}"
  end
  

  def self.words_by_count(text)
    text = ContentFixer.remove_double_quotes(text)
    text = ContentFixer.remove_punctuation(text)
    words = text.split
    word_counts = Hash.new(0)
    words.each do |w|
      word_counts[w.downcase]+=1
    end
    return word_counts
  end

  def self.most_used_uncommon(text)
    scrubbed = ContentFixer.remove_punctuation(text)
    scrubbed = ContentFixer.remove_common(scrubbed)
    scrubbed = ContentFixer.remove_double_quotes(scrubbed)
    counts = Analyzer.words_by_count(scrubbed)
    return counts.sort_by{|k,v| v}.reverse
  end
  
  def self.complex_words_total(text)
    text = ContentFixer.remove_quotes(text)
    text = ContentFixer.remove_punctuation(text)
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
    text = ContentFixer.remove_punctuation(text)
    return text.split.size
  end

  def self.unique_word_count(text)
    text = ContentFixer.remove_punctuation(text)
    text = ContentFixer.remove_double_quotes(text)
    self.words_by_count(text).keys.count
  end

  def self.sentences(text)
    text.scan(/(\S.*?(\.{3}|!|\.|\?))/).collect{|arr|arr.first}
  end

  def self.sentence_count(text)
    Analyzer.sentences(text).count
  end

  def self.average_sentence_length(text)
    return Analyzer.word_count(text)/Analyzer.sentence_count(text)
  end

  def self.sentences_close_with_same_start_word(text)
    text = ContentFixer.remove_double_quotes(text)
    sentence_groups = Hash.new
    sentences = self.sentences(text)
    start_words = sentences.collect{|s|s.split.first}.uniq
    start_words.each do |word|
      sentence_groups[word] = []
      i = 0
      while i && i<= sentences.count-3
        # find next sentence index with start word
        i = sentences.index{|s|sentences.index(s) >= i && s.split.first==word}
        if i 
          # adds sentences while chain is unbroken
          current_array = [sentences[i]]
          while sentences[i+1] && Analyzer.any_sentence_starts_with_word?([sentences[i+1],sentences[i+2]].compact,word)
            current_array<<[sentences[i+1],sentences[i+2]].compact.flatten
            i+=2
          end
          sentence_groups[word] << current_array.join(" ") if current_array.count > 1
          i+=1
        end
      end
    end
    return sentence_groups.delete_if{|k,v|v.empty?}
  end

  def self.any_sentence_starts_with_word?(sentence_array, word)
    sentence_array.collect{|s|s.split.first}.include?(word)
  end

  def self.percentage_sentences_started_with(text)
    text = ContentFixer.remove_double_quotes(text)
    sentence_starts = Hash.new(0)
    sentences = Analyzer.sentences(text)
    sentences.each do |s|
      sentence_starts[s.split.first]+=1
    end
    sentence_starts = sentence_starts.sort_by{|k,v|v}.reverse
    highest = sentence_starts.first[1]
    return sentence_starts.collect{|array|[array[0],((array[1].to_f/sentences.count.to_f)*100).round] if array[1]==highest}.compact
  end

  def self.sentence_counts(text, id=0)
    file = File.open("#{Rails.root}/log/#{id}_sentences","w")
    sentence_counts = Hash.new(0)
    Analyzer.sentences(text).each do |s|
      sentence_counts[s.split.size]+=1
      file.puts "SENTENCE: #{s}"
    end
    file.close
    return sentence_counts
  end

  def self.total_syllables(text)
    text = ContentFixer.remove_quotes(text)
    text = ContentFixer.remove_punctuation(text)
    total = 0
    syllables = Analyzer.syllables
    text.split.each do |word|
      if syllables[word.upcase] > 0
        total += syllables[word.upcase]
      else
        total += Analyzer.syllable_guess(word)
      end
    end
    return total
  end

  def self.lexical_density(text)
    scrubbed = ContentFixer.remove_quotes(text)
    scrubbed = ContentFixer.remove_punctuation(scrubbed)
    word_counts = Analyzer.words_by_count(scrubbed)
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

  def self.repeated_word_groups(text, group_by)
    text = ContentFixer.remove_punctuation(text.clone.downcase)
    text = ContentFixer.remove_double_quotes(text)
    word_array = text.split
    i = 0
    repeats = Hash.new(0)
    while i <= word_array.count - group_by 
      current_group = word_array[i..i+(group_by-1)].join(" ")
      unless repeats.keys.include?(current_group)
        repeats[current_group] = text.scan(current_group).count
      end
      i+=1
    end
    repeats = repeats.delete_if{|k,v| v<3}
    return repeats.sort_by{|k,v|v}.reverse
  end
end
