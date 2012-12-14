require 'spec_helper'

describe CritiquesHelper do
  let (:comment) {FactoryGirl.create(:comment)}
  describe '#comment_date' do
    it 'should return comment created at as Day, Month Date, Year at Time am/pm' do
      comment.created_at = "January 15, 1974 at 12:00pm"
      helper.comment_date(comment).should eql("Tuesday, January 15, 1974 at 12:00 PM")
    end
  end
end
