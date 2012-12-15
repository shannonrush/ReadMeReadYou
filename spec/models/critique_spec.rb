require 'spec_helper'

describe Critique do
  let (:critique) {FactoryGirl.create(:critique)}

  describe 'validations' do
    it 'should require content to be valid' do
      critique.should be_valid
      critique.update_attribute(:content,nil)
      critique.should_not be_valid
    end
  end

  describe 'after_create :send_notification' do
    it 'should send an email to author' do
      ActionMailer::Base.deliveries = []
      User.any_instance.stub(:send_welcome)
      user = FactoryGirl.create(:user)
      submission = FactoryGirl.create(:submission,user:user)
      new_critique = FactoryGirl.create(:critique,submission:submission)
      ActionMailer::Base.deliveries.count.should eql(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match new_critique.submission.user.email
    end
  end

  describe 'after_create :alert_for_new_critique' do
    it 'should generate one alert for author with critique link and correct message' do
      Alert.count.should eql(0)
      User.any_instance.stub(:send_welcome)
      user = FactoryGirl.create(:user)
      submission = FactoryGirl.create(:submission,user:user)
      critiquer = FactoryGirl.create(:user)
      new_critique = FactoryGirl.create(:critique,user:critiquer,submission:submission)
      Alert.count.should eql(1)
      alert = Alert.first
      alert.user.should eql(new_critique.submission.user)
      alert.link.should match "/critiques/#{new_critique.id}"
      title = new_critique.submission.title_with_chapters
      alert.message.should match "#{title} has a new critique!"
    end
  end

  describe 'after_update :report_if_abusive_rating' do
    before(:each) do
      ActionMailer::Base.deliveries = []
      User.any_instance.stub(:send_welcome)
      critiquer = FactoryGirl.create(:user)
      Critique.any_instance.stub(:send_notification)
      Critique.any_instance.stub(:alert_for_new_critique)
      @new_critique= FactoryGirl.create(:critique,user:critiquer)
    end

    it 'should send an email to support if rating -1' do
      @new_critique.update_attribute(:rating,-1)
      ActionMailer::Base.deliveries.count.should eql(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match "support@readmereadyou.com"
    end

    it 'should not send an email if rating not -1' do
      @new_critique.update_attribute(:rating,10)
      ActionMailer::Base.deliveries.count.should eql(0)
    end
  end

  describe 'after_update :alert_for_rating' do
    before(:each) do
      User.any_instance.stub(:send_welcome)
      critiquer = FactoryGirl.create(:user)
      Critique.any_instance.stub(:send_notification)
      Critique.any_instance.stub(:alert_for_new_critique)
      @new_critique = FactoryGirl.create(:critique,user:critiquer)
    end
    it 'should generate one alert if rating updated' do
      Alert.count.should eql(0)
      @new_critique.update_attribute(:rating,10)
      Alert.count.should eql(1)
    end

    it 'should generate one alert for critiquer with critique link and correct message' do
      Alert.count.should eql(0)
      @new_critique.update_attribute(:rating,10)
      Alert.count.should eql(1)
      alert = Alert.first
      alert.user.should eql(@new_critique.user)
      alert.link.should match "/critiques/#{@new_critique.id}"
      title = @new_critique.submission.title_with_chapters
      alert.message.should match "Your critique for #{title} has been rated"
    end
  end
  
  describe 'default_scope' do
    it 'should sort by created_at with latest first' do
      earliest = FactoryGirl.create(:critique,content:"content",created_at:"January 1, 1974")
      latest = FactoryGirl.create(:critique,content:"content",created_at:"January 15, 1974")
      Critique.all.should eql([latest,earliest])
    end
  end

  describe 'self.ordered_by' do
    before(:each) do 
      user1 = FactoryGirl.create(:user,first:"Shannon",last:"Aush")
      user2 = FactoryGirl.create(:user,first:"Shannon",last:"Zush")
      submission1 = FactoryGirl.create(:submission,title:"A Title",user:user1)
      submission2 = FactoryGirl.create(:submission,title:"Z Title",user:user2)
      @critique1 = Critique.create(content:"content",submission:submission1,user:user1,rating:0)
      @critique2 = Critique.create(content:"content",submission:submission2,user:user2,rating:10)
    end
    
    it 'should sort by submission title as A-Z if submission_title' do
      Critique.ordered_by(Critique.all,"submission_title").should eql([@critique1,@critique2])
    end

    it 'should sort by critiquer last name as A-Z if critiquer' do
      Critique.ordered_by(Critique.all,"critiquer").should eql([@critique1,@critique2])
    end
    it 'should sort by rating with lowest first if rating' do
      Critique.ordered_by(Critique.all,"rating").should eql([@critique1,@critique2])
    end
    it 'should sort by created_at with latest first if created_at' do
      Critique.ordered_by(Critique.all,"created_at").should eql([@critique1,@critique2])
    end
  end

end
