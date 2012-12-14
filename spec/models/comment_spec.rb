require 'spec_helper'

describe Comment do
  let (:comment) {FactoryGirl.create(:comment)}
  let (:critique) {FactoryGirl.create(:critique_no_after_create)}

  describe 'validations' do
    it 'should require content to be valid' do
      comment.should be_valid
      comment.update_attribute(:content,nil)
      comment.should_not be_valid
    end
    it 'should require critique to be valid' do
      comment.should be_valid
      comment.update_attribute(:critique,nil)
      comment.should_not be_valid
    end
  end

  describe 'after_create :alerts_for_new_comment' do
    it 'should generate alerts with critique link' do
      Alert.count.should eql(0)
      new_comment = Comment.create(critique:critique,content:"New Comment")
      Alert.count.should eql(1)
      Alert.first.link.should eql("/critiques/#{critique.id}")
    end
    
    it 'should generate an alert for critiquer with correct message' do
      Alert.for_user(critique.user).count.should eql(0) 
      new_comment = Comment.create(critique:critique,content:"New Comment")
      alerts = Alert.for_user(critique.user) 
      alerts.count.should eql(1)
      title = critique.submission.title_with_chapters
      alerts.first.message.should eql("Your critique on #{title} has a new comment")
    end

    it 'should generate an alert for other commenters with correct message' do
      new_critique = FactoryGirl.create(:critique)
      first_commenter = FactoryGirl.create(:user,email:"firstc@rmry.com")
      first_comment = Comment.create(critique:new_critique,user:first_commenter,content:"First Comment")
      Alert.count.should eql(1)
      new_user = FactoryGirl.create(:user,email:"newu@rmry.com")
      new_comment = Comment.create(critique:new_critique,user:new_user,content:"New Comment")
      Alert.count.should eql(3)
      alerts = Alert.for_user(first_commenter)
      alerts.count.should eql(1)
      title = new_critique.submission.title_with_chapters
      alerts.first.message.should eql("The critique on #{title} has a new comment")
    end

    it 'should not generate an alert for commenter' do
      new_critique = FactoryGirl.create(:critique)
      first_commenter = FactoryGirl.create(:user,email:"firstc@rmry.com")
      first_comment = Comment.create(critique:new_critique,user:first_commenter,content:"First Comment")
      Alert.count.should eql(1)
      new_user = FactoryGirl.create(:user,email:"newu@rmry.com")
      new_comment = Comment.create(critique:new_critique,user:new_user,content:"New Comment")
      Alert.count.should eql(3)
      Alert.for_user(new_user).count.should eql(0)
    end
  end
end
