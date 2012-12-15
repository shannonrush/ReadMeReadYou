require 'spec_helper'

describe ContentFixer do
  describe '#self.fix(file)' do
    it 'returns the text from the file with \r\n replaced with \n\n' do
      extend ActionDispatch::TestProcess
      file = fixture_file_upload('/files/content_fixer_test.txt', 'text/plain')
      ContentFixer.fix(file).should match "\xEF\xBB\xBFone\n\n\n\n\n\ntwo"
    end
  end
end
