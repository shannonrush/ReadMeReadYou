require 'spec_helper'

describe Analyzer do
  describe '#self.dictionary' do
    it 'returns the cmudict' do
      Analyzer.dictionary.first.should match "!EXCLAMATION-POINT  EH2 K S K L AH0 M EY1 SH AH0 N P OY2 N T\n"
    end
  end

  describe '#self.syllables' do
    it 'returns the syllable hash' do
      Analyzer.syllables["FOREST"].should eql(2)
    end
  end
  
  describe '#words_by_count(text)' do
    it 'returns a hash with unique words and counts' do
      text = "These words repeat words these"
      Analyzer.words_by_count(text).should == {"these"=>2,"words"=>2,"repeat"=>1}
    end
  end
  
  describe '#self.complex_words_total(text)' do
    it 'does not count hyphenated words' do
      text = "harbinger-of-death"
      Analyzer.complex_words_total(text).should eql(0)
      text = "harbinger of death"
      Analyzer.complex_words_total(text).should eql(1)
    end

    it 'does not count word if common suffix adds third syllable' do
      text = "arrested"
      Analyzer.syllables["ARRESTED"].should eql(3)
      Analyzer.complex_words_total(text).should eql(0)
    end

    it 'does not count a word with three syllables if not in dictionary' do
      text = "bananarama"
      Analyzer.syllables.keys.should_not include("BANANARAMA")
      Analyzer.complex_words_total(text).should eql(0)
    end

    it 'does count word with three syllables if in dictionary' do
      text = "shanahan"
      Analyzer.syllables.keys.should include("SHANAHAN")
      Analyzer.complex_words_total(text).should eql(1)
    end
  end

  describe '#self.word_count(text)' do
    it 'returns the number of words in text' do
      text = "one two three"
      Analyzer.word_count(text).should eql(3)
    end
  end

  describe '#self.sentences(text)' do
    it 'returns array of text split on periods, question marks, ellipses or exclamation points' do
      text  = "This is one sentence? This is another sentence! This is a third sentence. This is a fourth...This is a fifth"
      Analyzer.sentences(text).should eql(["This is one sentence","This is another sentence","This is a third sentence","This is a fourth","This is a fifth"])
    end
  end

  describe '#self.sentence_count(text)' do
    it 'returns the number of sentences in text' do
      text = "This is one sentence? This is another sentence! This is a third sentence. This is a fourth...This is a fifth"
      Analyzer.sentence_count(text).should eql(5)
    end
  end

  describe '#self.average_sentence_length(text)' do
    it 'returns the sum of sentence counts divided by number of sentences' do
      text = "This has four words. This sentence has five words. This is a sentence with six."
      Analyzer.average_sentence_length(text).should eql(5)
    end
  end

  describe '#self.sentence_counts(text, id=0)' do
    it 'returns a hash with sentence lengths and counts' do
      text = "This has four words. This is a sentence with six. This sentence has five words."
      Analyzer.sentence_counts(text).should =={4=>1,5=>1,6=>1} 
    end
  end

  describe '#self.total_syllables(text)' do
    it 'returns total syllables for text' do
      text = "The rabbit terrified ridiculous cats"
      Analyzer.total_syllables(text).should eql(11)
    end
  end

  describe '#self.syllable_guess(word)' do
    it 'returns a syllable guess for word' do
      Analyzer.syllable_guess("a").should eql(1)
      Analyzer.syllable_guess("the").should eql(1)
      Analyzer.syllable_guess("rabbit").should eql(2)
      Analyzer.syllable_guess("terrified").should eql(3)
      Analyzer.syllable_guess("ridiculous").should eql(4)
    end
  end

  describe '#self.lexical_density(text)' do
    it 'returns the number of unique words divided by the number of words in text' do
      text = "These words repeat words these"
      Analyzer.lexical_density(text).should eql(60)
    end
  end

end
