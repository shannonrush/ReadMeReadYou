require 'spec_helper'

describe Submission do
  let (:submission) {FactoryGirl.create(:submission)}

  describe 'validations' do
    it 'requires genre to be valid' do
      submission.should be_valid
      submission.update_attribute(:genre,nil)
      submission.should_not be_valid
    end
    it 'requires title to be valid' do
      submission.should be_valid
      submission.update_attribute(:title,nil)
      submission.should_not be_valid
    end
    it 'requires content to be valid' do
      submission.should be_valid
      submission.update_attribute(:content,nil)
      submission.should_not be_valid
    end
    it 'requires user to be valid' do
      submission.should be_valid
      submission.update_attribute(:user,nil)
      submission.should_not be_valid
    end
  end

  describe 'default_scope' do
    it 'returns sorted by created_at with latest first' do
      submission1 = FactoryGirl.create(:submission,created_at:"January 1, 1974")
      submission2 = FactoryGirl.create(:submission,created_at:"January 15, 1974")
      Submission.all.should eql([submission2,submission1])
    end
  end

  describe 'scope :active' do
    it 'includes submissions less than a week old with less than 5 critiques' do
      submission.update_attribute(:created_at,Time.zone.now)
      submission.critiques.count.should eql(0)
      Submission.active.should include(submission)
    end

    it 'includes submissions less than a week old with greater than 4 critiques' do
      submission.update_attribute(:created_at,Time.zone.now)
      5.times {FactoryGirl.create(:critique,submission:submission)}
      submission.critiques.count.should eql(5)
      Submission.active.should include(submission)
    end
    
    it 'includes submissions greater than a week old with less than 5 critiques' do
      submission.update_attribute(:created_at,Time.zone.now - 8.days)
      submission.critiques.count.should eql(0)
      Submission.active.should include(submission)
    end

    it 'does not include submissions greater than a week oldwith more than 5 critiques' do
      submission.update_attribute(:created_at,Time.zone.now - 8.days)
      5.times {FactoryGirl.create(:critique,submission:submission)}
      submission.critiques.count.should eql(5)
      Submission.active.should_not include(submission)
    end
  end

  describe '#self.ordered_by(order_by)' do
    before (:each) do
      author1 = FactoryGirl.create(:user,last:"Aush")
      author2 = FactoryGirl.create(:user,last:"Zush")
      @submission1 = FactoryGirl.create(:submission,user:author1,content:"one two",created_at:"January 1, 1974",title:"A Title",genre:"Action")
      @submission2 = FactoryGirl.create(:submission,user:author2,content:"one two three",created_at:"January 15, 1974",title:"Z Title",genre:"Horror")
    end

    it 'returns active sorted by author last A-Z when author' do
      Submission.ordered_by("author").should eql([@submission1,@submission2])
    end

    it 'returns active sorted by word count 0-inf when word_count' do
      Submission.ordered_by("word_count").should eql([@submission1,@submission2])
    end

    it 'returns active sorted by critique count 0-inf when critique_count' do
      FactoryGirl.create(:critique,submission:@submission1)
      @submission1.critiques.count.should eql(1)
      @submission2.critiques.count.should eql(0)
      Submission.ordered_by("critique_count").should eql([@submission1,@submission2])
    end

    it 'returns active sorted by created_at with latest first when created_at' do
      Submission.ordered_by("created_at").first.should eql(@submission2)
    end

    it 'returns active sorted by title A-Z when title' do
      Submission.ordered_by("title").should eql([@submission1,@submission2])
    end

    it 'returns active sorted by genre A-Z when genre' do
      Submission.ordered_by("genre").should eql([@submission1,@submission2])
    end
  end

  describe '#title_with_chapters' do
    it 'returns title and Ch. + chapter names comma delimited' do
      Chapter.create(submission:submission,name:"1")
      Chapter.create(submission:submission,name:"2")
      submission.title_with_chapters.should match "Ch. 1, 2"
    end
  end

  describe '#chapter list' do
    it 'returns comma delimited chapter list' do
      Chapter.create(submission:submission,name:"1")
      Chapter.create(submission:submission,name:"2")
      submission.chapter_list.should match "1, 2"      
    end
  end

  describe '#create_chapters(chapter_list)' do
    it 'takes comma delimited chapter string and creates Chapter for each' do
      Chapter.count.should eql(0)
      submission.create_chapters("3, 4")
      Chapter.count.should eql(2)
      submission.chapters.count.should eql(2)
    end
  end

  describe '#word_count' do
    it 'returns the number of words in content' do
      submission.update_attribute(:content, "one two three")
      submission.word_count.should eql(3)
    end
  end

end
