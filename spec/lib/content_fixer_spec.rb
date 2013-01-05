require 'spec_helper'

describe ContentFixer do
  describe '#self.fix(file)' do
    it 'returns the text from the file with \r\n replaced with \n\n and smart quotes replaced with straight quotes' do
      extend ActionDispatch::TestProcess
      file = fixture_file_upload('/files/content_fixer_test.txt', 'text/plain')
      ContentFixer.fix(file).should match "\xEF\xBB\xBF&quot;one&quot;\n\n\n\n\n\n&#39;two&#39;"
    end
  end

  describe '#self.quotes_to_symbols(content)' do
    it 'should replace &quot; with "' do
      content = '&quot;something&quot;'
      ContentFixer.quotes_to_symbols(content).should match '"something"'
    end
    it "should replace &#39; with '" do
      content = "&#39;something&#39;"
      ContentFixer.quotes_to_symbols(content).should match "'something'"
    end
  end

  describe '#self.quotes_to_code(content)' do
    it 'should replace " with &quot;' do
      content = '"something"'
      ContentFixer.quotes_to_code(content).should match '&quot;something&quot;'
    end
    it "should replace ' with &#39;" do
      content = "'something'"
      ContentFixer.quotes_to_code(content).should match '&#39;something&#39;'
    end
  end

  describe '#self.process_for_analysis(content)' do
    it 'removes all underscores' do
      content = "_There_ he _is_!"
      ContentFixer.process_for_analysis(content).should match "There he is!"
    end

    it 'strips periods from common abbreviations' do
      content = "Mr. Man, meet Mrs. Lady and Ms. Girl."
      ContentFixer.process_for_analysis(content).should match "Mr Man, meet Mrs Lady and Ms Girl."
    end
  end

  describe '#self.remove_quotes(content)' do
    it 'should remove double quotes' do
      content = '"This is quoted"'
      ContentFixer.remove_quotes(content).should match "This is quoted"
    end

    it 'should remove single quotes' do
      content = "'This is quoted'"
      ContentFixer.remove_quotes(content).should match "This is quoted"
    end
  end

  describe '#self.remove_double_quotes(content)' do
    it 'should remove double quotes' do
      content = '"This is quoted"'
      ContentFixer.remove_quotes(content).should match "This is quoted"
    end
  end

  describe '#self.remove_punctuation' do
    it 'should remove numbers' do
      content = "This has 01234567890 numbers"
      ContentFixer.remove_punctuation(content).should match "This has  numbers"
    end

    it 'should remove .,?!*' do
      content = "This. has, some? punctuation!*"
      ContentFixer.remove_punctuation(content).should match "This has some punctuation"
    end

    it 'should replace / with space' do
      content = "This is and/or something"
      ContentFixer.remove_punctuation(content).should match "This is and or something"
    end
  end

  describe '#self.remove_common(content)' do
    it 'should remove common words' do
      content = "The spotted owl and the cat"
      ContentFixer.remove_common(content).should match "spotted owl cat"
    end
  end
end
