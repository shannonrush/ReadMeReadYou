require 'spec_helper'

describe ContentFixer do
  describe '#self.fix(file)' do
    it 'returns the text from the file with \r\n replaced with \n\n and smart quotes replaced with straight quotes' do
      extend ActionDispatch::TestProcess
      file = fixture_file_upload('/files/content_fixer_test.txt', 'text/plain')
      ContentFixer.fix(file).should match "\xEF\xBB\xBF&quot;one&quot;\n\n\n\n\n\n&#39;two&#39;"
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

    it 'strips single and double quotes' do
      content = "\"This is a 'sentence'\""
      ContentFixer.process_for_analysis(content).should match "This is a sentence"
    end
  end

  describe '#self.scrub(content)' do
    it 'should remove double quotes' do
      content = '"This is quoted"'
      ContentFixer.scrub(content).should match "This is quoted"
    end

    it 'should remove single quotes' do
      content = "'This is quoted'"
      ContentFixer.scrub(content).should match "This is quoted"
    end

    it 'should remove numbers' do
      content = "This has 01234567890 numbers"
      ContentFixer.scrub(content).should match "This has  numbers"
    end

    it 'should remove .,?!*' do
      content = "This. has, some? punctuation!*"
      ContentFixer.scrub(content).should match "This has some punctuation"
    end

    it 'should replace / with space' do
      content = "This is and/or something"
      ContentFixer.scrub(content).should match "This is and or something"
    end

  end
end
