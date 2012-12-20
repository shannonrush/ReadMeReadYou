require 'spec_helper'

describe Chapter do
  let (:submission) {FactoryGirl.create(:submission)}
  describe 'after_create :add_version' do
    before (:each) do
      @sub2 = FactoryGirl.create(:submission,title:submission.title,user:submission.user)
    end

    it 'does not add version if no previous chapter for submission title with same name' do
      @sub2.chapters.count.should eql(0)
      @sub2.create_chapters("2")
      @sub2.chapters.count.should eql(1)
      @sub2.chapters.reload
      @sub2.chapters.first.version.should be_nil
    end
    
    it 'does not add version if previous chapter of another submission title for user with same chapter name' do
      submission.create_chapters("2")
      submission.chapters.reload
      new_sub = FactoryGirl.create(:submission, user:submission.user,title:"Other")
      new_sub.create_chapters("2")
      new_sub.chapters.reload
      new_sub.chapters.first.version.should be_nil
    end

    it 'adds version 2 if previous chapter of submission with same name with no version' do
      submission.create_chapters("2")
      submission.chapters.reload
      @sub2.create_chapters("2")
      @sub2.chapters.reload
      @sub2.chapters.count.should eql(1)
      chapter = @sub2.chapters.first
      chapter.name.should match "2"
      chapter.version.should eql(2)
    end

    it 'adds sequential version number if existing chapter for submission with same name' do
      submission.create_chapters("2")
      submission.chapters.reload
      @sub2.create_chapters("2, 3")
      @sub2.chapters.reload
      @sub2.chapters.count.should eql(2)
      chapter = @sub2.chapters.where(name:"2").first
      chapter.name.should match "2"
      chapter.version.should eql(2)
      sub3 = FactoryGirl.create(:submission,title:submission.title,user:submission.user)
      sub3.create_chapters("2")
      sub3.chapters.reload
      sub3.chapters.count.should eql(1)
      chapter = sub3.chapters.first
      chapter.name.should match "2"
      chapter.version.should eql(3)
    end
  end

  describe '#name_with_version' do
    it 'returns name if version nil' do
      chapter = Chapter.create(submission:submission,name:"2")
      chapter.version.should be_nil
      chapter.name_with_version.should match "2"
    end

    it 'returns name with version in parens if version' do
      chapter = Chapter.create(submission:submission,name:"2",version:2)
      chapter.version.should eql(2)
      chapter.name_with_version.should eql("2 (v2)")
    end
  end

end
