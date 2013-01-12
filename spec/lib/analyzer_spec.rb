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

  describe '#self.tag_words(text,remove_ignored=false)' do
    it 'returns an array of arrays, each with word from text in position 0 and pos in position 1' do
      text = "We saw the big, yellow dog."
      Analyzer.tag_words(text).should == [["We","PRP"],["saw","VBD"],["the","DET"],["big","JJ"],[",","PPC"],["yellow","JJ"],["dog","NN"],[".","PP"]]
    end
    it 'does not return ignored tags if remove_ignored is true' do
      text = "We saw the big, yellow dog."
      Analyzer.tag_words(text,true).should == [["We","PRP"],["saw","VBD"],["the","DET"],["big","JJ"],["yellow","JJ"],["dog","NN"]]
    end
  end

  describe '#self.chunk_sentence(sentence)' do
    it 'returns an array of arrays with position 0 chunk symbol and remaining content words' do 
      sentence = "The big, yellow dog went home."
      Analyzer.chunk_sentence(sentence,true).should == [["NP","The big yellow dog"],["VP","went"],["NP","home"]]
      sentence = "My dog also likes eating sausages."
      Analyzer.chunk_sentence(sentence).should == [["NP", "My dog"],["ADVP", "also"]]
    end
  end

  describe '#self.extract_noun_phrase(tagged_words, i)' do
    it 'returns the noun phrase beginning at i, returns the next position i and the phrase as an array of words' do
      sentence = "The big, yellow dog went home."
      tagged_words = Analyzer.tag_words(sentence,true)
      Analyzer.extract_noun_phrase(tagged_words,0).should == [4,"The","big","yellow","dog"]
    end
  end

  describe '#self.extract_ad_phrase(tagged_words, i)' do
    it 'returns the adverb or adjective phrase beginning at i, returns the next position i and the phrase as an array of words' do
      tagged_words = Analyzer.tag_words("The big, yellow dog went home.",true)
      Analyzer.extract_ad_phrase(tagged_words,1).should == [1,"big"]
    end
  end

  describe '#self.ignore_tag?(tag)' do
    it 'returns true for tag beginning with PP' do
      Analyzer.ignore_tag?('PP').should be_true
      Analyzer.ignore_tag?('PPR').should be_true
    end
    it 'returns true for LRB' do
      Analyzer.ignore_tag?('LRB').should be_true
    end
    it 'returns true for RRB' do
      Analyzer.ignore_tag?('RRB').should be_true
    end
    it 'returns true for SYM' do
      Analyzer.ignore_tag?('SYM').should be_true
    end
    it 'returns true for FW' do
      Analyzer.ignore_tag?('FW').should be_true
    end
    it 'returns true for LS' do
      Analyzer.ignore_tag?('LS').should be_true
    end
  end

  describe '#self.tag_is_determiner?(tag)' do
    it 'returns true if tag is DET' do
      Analyzer.tag_is_determiner?('DET').should be_true
    end
    it 'returns true if tag is PDT' do
      Analyzer.tag_is_determiner?('PDT').should be_true
    end
    it 'returns true if tag is PRP' do
      Analyzer.tag_is_determiner?('PRP').should be_true
    end
    it 'returns true if tag is PRPS' do
      Analyzer.tag_is_determiner?('PRPS').should be_true
    end
    it 'returns true if tag is WDT' do
      Analyzer.tag_is_determiner?('WDT').should be_true
    end
    it 'returns true if tag is WPS' do
      Analyzer.tag_is_determiner?('WPS').should be_true
    end
  end
 
  describe '#self.tag_is_adjective?(tag)' do
    it 'returns true if tag begins with JJ' do
      Analyzer.tag_is_adjective?('JJ').should be_true
      Analyzer.tag_is_adjective?('JJR').should be_true
    end
  end

  describe '#self.tag_is_adverb?(tag)' do
    it 'returns true if tag begins with R' do
      Analyzer.tag_is_adverb?('R').should be_true
      Analyzer.tag_is_adverb?('RBR').should be_true
    end
    it 'returns true if tag is WRB' do
      Analyzer.tag_is_adverb?('WRB').should be_true
    end
  end

  describe '#self.tag_is_preposition?(tag)' do
    it 'returns true if tag is IN' do
      Analyzer.tag_is_preposition?('IN').should be_true
    end
    it 'returns true if tag is TO' do
      Analyzer.tag_is_preposition?('TO').should be_true
    end
  end

  describe '#self.tag_is_noun?(tag)' do
    it 'returns true if tag begins with N' do
      Analyzer.tag_is_noun?('N').should be_true
      Analyzer.tag_is_noun?('NNP').should be_true
    end
    it 'returns true if tag is EX' do
      Analyzer.tag_is_noun?('EX').should be_true
    end
  end


  describe '#self.words_by_count(text)' do
    it 'returns a hash with unique words and counts' do
      text = "These words repeat words these"
      Analyzer.words_by_count(text).should == {"these"=>2,"words"=>2,"repeat"=>1}
    end
  end

  describe '#self.most_used_uncommon(text)' do
    it 'returns an array of word count arrays sorted with highest count first' do
      text = "There's something wrong, wrong, wrong something"
      Analyzer.most_used_uncommon(text).should == [["wrong",3],["something",2],["there's",1]]
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

  describe '#self.unique_word_count(text)' do
    it 'returns the number of unique words in text' do
      text = "one one one two three three"
      Analyzer.unique_word_count(text).should eql(3)
    end
  end

  describe '#self.sentences(text)' do
    it 'returns array of text split on periods, question marks, ellipses or exclamation points' do
      text  = "This is one sentence? This is another sentence! This is a third sentence. This is a fourth...This is a fifth."
      Analyzer.sentences(text).should eql(["This is one sentence?","This is another sentence!","This is a third sentence.","This is a fourth...","This is a fifth."])
    end
  end

  describe '#self.sentence_count(text)' do
    it 'returns the number of sentences in text' do
      text = "This is one sentence? This is another sentence! This is a third sentence. This is a fourth...This is a fifth."
      Analyzer.sentence_count(text).should eql(5)
    end
  end

  describe '#self.average_sentence_length(text)' do
    it 'returns the sum of sentence counts divided by number of sentences' do
      text = "This has four words. This sentence has five words. This is a sentence with six."
      Analyzer.average_sentence_length(text).should eql(5)
    end
  end

  describe "#self.sentences_close_with_same_start_word(text)" do
    it 'returns hash with keys of start words and values of array of groups of sentences that contain at least 2 same start words in every 3 sentences in group' do
      text = "She ran away. He sat there. She thanked him. Four little kittens. He wondered. Five dogs. He said. Six chickens. Wondered aloud. Clouds skated. He wondered again. Her skirt. He thought. He wondered for a third time."
      Analyzer.sentences_close_with_same_start_word(text).should == {"She"=>["She ran away. He sat there. She thanked him."],"He"=>["He wondered. Five dogs. He said.","He wondered again. Her skirt. He thought. He wondered for a third time."]}
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

  describe '#self.repeated_word_groups(text, count)' do
    it 'returns an array of arrays with word groups and value is repeating of all groups repeated more than twice' do
      text = "She said loudly, something she said loudly something else, something she said loudly"
      Analyzer.repeated_word_groups(text, 3).should == [["she said loudly",3]]
    end
  end

  describe '#self.percentage_sentences_started_with(text)' do
    it 'finds the word or words that most begin sentences and returns array of arrays with word and percentage' do
      text = "She said once. The cat ran. She wondered? The rat can. Four little kittens."
      Analyzer.percentage_sentences_started_with(text).should == [["She",40],["The",40]]
    end

  end

end
