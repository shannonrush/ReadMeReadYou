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
    it 'is not valid if content is greater than 10000 words' do
      submission.should be_valid
      content = ""
      10001.times {content << "word "}
      submission.update_attribute(:content,content)
      submission.content.split.size.should eql(10001)
      submission.should_not be_valid
    end
    it 'is valid if content is less than 10000 words' do
      submission.should be_valid
      content = ""
      9999.times {content << "word "}
      submission.update_attribute(:content,content)
      submission.content.split.size.should eql(9999)
      submission.should be_valid
    end
  end

  describe 'default_scope' do
    it 'returns sorted by created_at with latest first' do
      submission1 = FactoryGirl.create(:submission,created_at:"January 1, 1974")
      submission2 = FactoryGirl.create(:submission,created_at:"January 15, 1974")
      Submission.all.should eql([submission2,submission1])
    end
  end
  
  describe 'scope :not_in_queue' do
    it 'includes submission where queued is false' do
      submission.update_attribute(:queued,false)
      Submission.not_in_queue.should include(submission)
    end
    it 'does not include submission where queued is true' do
      submission.update_attribute(:queued,true)
      Submission.not_in_queue.should_not include(submission)
    end
  end

  describe 'scope :in_queue' do
    it 'excludes submission where queued is false' do
      submission.update_attribute(:queued,false)
      Submission.in_queue.should_not include(submission)
    end
    it 'includes submission where queued is true' do
      submission.update_attribute(:queued,true)
      Submission.in_queue.should include(submission)
    end
  end

  describe 'scope :needs_time_or_critiques' do
    it 'includes submissions less than a week old with less than 1 critique' do
      submission.update_attribute(:activated_at,Time.zone.now)
      submission.critiques.count.should eql(0)
      Submission.needs_time_or_critiques.should include(submission)
    end

    it 'includes submissions less than a week old with greater than 0 critiques' do
      submission.update_attribute(:activated_at,Time.zone.now)
      FactoryGirl.create(:critique,submission:submission)
      submission.critiques.count.should eql(1)
      Submission.needs_time_or_critiques.should include(submission)
    end
    
    it 'includes submissions greater than a week old with less than 1 critique' do
      submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      submission.critiques.count.should eql(0)
      Submission.needs_time_or_critiques.should include(submission)
    end

    it 'does not include submissions greater than a week oldwith more than 0 critiques' do
      submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      FactoryGirl.create(:critique,submission:submission)
      submission.critiques.count.should eql(1)
      Submission.needs_time_or_critiques.should_not include(submission)
    end
  end

  describe 'scope :active' do
    it 'includes submission in needs_time_or_critiques if not in queue' do
      Submission.needs_time_or_critiques.should include(submission)
      Submission.not_in_queue.should include(submission)
      Submission.active.should include(submission)
    end
    it 'excludes submission in needs_time_or_critiques if in queue' do
      Submission.needs_time_or_critiques.should include(submission)
      submission.update_attribute(:queued,true)
      Submission.not_in_queue.should_not include(submission)
      Submission.active.should_not include(submission)
    end
    it 'excludes submission not in needs_time_or_critiques if in queue' do
      submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      FactoryGirl.create(:critique,submission:submission)
      Submission.needs_time_or_critiques.should_not include(submission)
      submission.update_attribute(:queued,true)
      Submission.not_in_queue.should_not include(submission)
      Submission.active.should_not include(submission)
    end
    it 'excludes submission not in needs_time_or_critiques if not in queue' do
      submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      FactoryGirl.create(:critique,submission:submission)
      Submission.needs_time_or_critiques.should_not include(submission)
      Submission.not_in_queue.should include(submission)
      Submission.active.should_not include(submission)
    end
  end

  describe '#self.inactive' do
    it 'includes submission if it does not need time and does not need critique' do
      FactoryGirl.create(:critique,submission:submission)
      submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      Submission.inactive.should include(submission)
    end

    it 'excludes submission if it needs time and does not need critique' do
      FactoryGirl.create(:critique,submission:submission)
      Submission.inactive.should_not include(submission)
    end
    
    it 'excludes submission if it does need time and needs critiques' do
      submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      Submission.inactive.should_not include(submission)
    end
  end

  describe 'after_create :add_to_queue' do
    it 'sets queued if author has active submission' do
      new_submission = FactoryGirl.create(:submission,user:submission.user)
      new_submission.author_has_active_submission?.should be_true
      new_submission.queued?.should be_true
    end

    it 'does not set queued if author has no active submission' do
      5.times {FactoryGirl.create(:critique,submission:submission)}
      submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      new_submission = FactoryGirl.create(:submission,user:submission.user)
      new_submission.author_has_active_submission?.should be_false
      new_submission.queued?.should be_false
    end
  end

  describe 'after_create :alert_previous_critiquers' do 
    before(:each) do
      @prev_submission = FactoryGirl.create(:submission)
      @author = @prev_submission.user
      @prev_critique = FactoryGirl.create(:critique,submission:@prev_submission)
      Alert.destroy_all
    end

    it 'creates alert for all previous critiquers of author if author has no active submission' do
      5.times {FactoryGirl.create(:critique,submission:@prev_submission)}
      @prev_submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      Alert.destroy_all
      new_submission = FactoryGirl.create(:submission,user:@author)
      new_submission.author_has_active_submission?.should be_false
      @prev_submission.critiques.count.should eql(6)
      Alert.count.should eql(6)
      @prev_critique.user.alerts.count.should eql(1)
    end

    it 'does not create alert for all previous critiquers of author if author has active submission' do
      new_submission = FactoryGirl.create(:submission,user:@author)
      new_submission.author_has_active_submission?.should be_true
      Alert.count.should eql(0)
    end

    it 'creates alert about new author submission with submission link if not previous critiquer of title' do
      5.times {FactoryGirl.create(:critique,submission:@prev_submission)}
      @prev_submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      Alert.destroy_all
      new_submission = FactoryGirl.create(:submission,user:@author,title:"Different Title")
      @prev_critique.user.alerts.count.should eql(1)
      alert = @prev_critique.user.alerts.first
      alert.message.should match "#{@author.full_name} has a new submission" 
      alert.link.should match "/submissions/#{new_submission.id}"
    end

    it 'creates alert about new title submission with submission link if previous critiquer of title' do
      5.times {FactoryGirl.create(:critique,submission:@prev_submission)}
      @prev_submission.update_attribute(:activated_at,Time.zone.now - 8.days)
      Alert.destroy_all
      new_submission = FactoryGirl.create(:submission,user:@author,title:@prev_submission.title)
      @prev_critique.user.alerts.count.should eql(1)
      alert = @prev_critique.user.alerts.first
      alert.message.should match "#{new_submission.title} has a new submission" 
      alert.link.should match "/submissions/#{new_submission.id}"
    end
  end

  describe 'after_create :add_activated_at' do
    it 'updates activated_at to created_at if not in queue' do
      new_submission = FactoryGirl.create(:submission)
      new_submission.queued.should_not be_true
      new_submission.activated_at.should eql(new_submission.created_at)
    end

    it 'does not update activated_at if in queue' do
      new_submission = FactoryGirl.create(:submission,user:submission.user)
      new_submission.queued.should be_true
      new_submission.activated_at.should be_nil
    end
  end
  
  describe '#title_critiquers' do
    before(:each) do
      @prev_submission = FactoryGirl.create(:submission) 
      @author = @prev_submission.user
      @prev_critique = FactoryGirl.create(:critique,submission:@prev_submission)
    end

    it 'includes user who has previously critiqued title' do
      new_submission = FactoryGirl.create(:submission,user:@author,title:@prev_submission.title)
      @author.submissions.reload
      new_submission.title_critiquers.should include(@prev_critique.user)
    end

    it 'does not include user who has previously critiqued author submission with different title' do
      new_submission = FactoryGirl.create(:submission,user:@author,title:"Different Title")
      @author.submissions.reload
      new_submission.title_critiquers.should_not include(@prev_critique.user)
    end
  end

  describe '#author_critiquers' do
    it 'includes user who has previously critiqued submission by author' do
      prev_submission = FactoryGirl.create(:submission) 
      author = prev_submission.user
      prev_critique = FactoryGirl.create(:critique,submission:prev_submission)
      new_submission = FactoryGirl.create(:submission,user:author)
      author.submissions.reload
      new_submission.author_critiquers.should include(prev_critique.user)
    end
  end

  describe '#should_be_queued?' do
    it 'returns false if author has no previous submissions' do
      submission.user.submissions.count.should eql(1)
      submission.should_be_queued?.should be_false
    end
    
    it 'returns false if author has only critiqued submissions' do 
     submission.update_attribute(:activated_at,Time.zone.now-8.days)
     5.times {FactoryGirl.create(:critique,submission:submission)}
     Submission.active.should_not include(submission)
     submission.should_be_queued?.should be_false
    end

    it 'returns true if author has an active submission' do
      Submission.active.should include(submission)
      new = FactoryGirl.create(:submission,user:submission.user)
      new.should_be_queued?.should be_true
    end

    it 'returns true if author has only queued submissions' do
      submission.update_attributes(queued:true,activated_at:nil)
      Submission.in_queue.should include(submission)
      submission.user.submissions.count.should eql(1)
      new = FactoryGirl.create(:submission,user:submission.user)
      new.author_has_active_submission?.should be_false
      new.should_be_queued?.should be_true
    end

    it 'returns true if author has only queued and critiqued submissions' do
     new = FactoryGirl.create(:submission,user:submission.user)
     submission.update_attribute(:activated_at,Time.zone.now-8.days)
     5.times {FactoryGirl.create(:critique,submission:submission)}
     Submission.active.should_not include(submission)
     new.author_has_active_submission?.should be_false
     new.user.submissions.count.should eql(2)
     new.should_be_queued?.should be_true
    end
    
  end

  describe '#author_has_active_submission?' do
    it 'returns true if user has a submission in Submission.active' do
      new_submission = FactoryGirl.create(:submission,user:submission.user)
      Submission.active.should include(submission)
      new_submission.author_has_active_submission?.should be_true
    end
    it 'returns false if user does not have a submission in Submission.active' do
      new_submission = FactoryGirl.create(:submission)
      new_submission.author_has_active_submission?.should be_false
    end
    it 'returns false if user has only queued submissions' do
      queued = FactoryGirl.create(:submission,user:submission.user)
      Submission.in_queue.should include(queued)
      submission.update_attribute(:activated_at,Time.zone.now-8.days)
      5.times {FactoryGirl.create(:critique,submission:submission)}
      Submission.active.should_not include(submission)
      new = FactoryGirl.create(:submission,user:submission.user)
      new.author_has_active_submission?.should be_false
    end
  end

  describe 'self.activate_submissions' do
    before(:each) do
      @author = FactoryGirl.create(:user)
      @old_submission = FactoryGirl.create(:submission,user:@author,created_at:Time.zone.now-8.days)
      5.times {FactoryGirl.create(:critique,submission:@old_submission)}
      @queued_submission = FactoryGirl.create(:submission,user:@author,queued:true)
    end
    
    it 'should set author earliest queued to false if author has no active submission' do
      Submission.active.should_not include(@queued_submission)
      User.without_active_submission.should include(@author)
      @queued_submission.queued.should be_true
      Submission.activate_submissions
      @queued_submission.reload
      @queued_submission.queued.should be_false
    end

    it 'should not set any other than earliest queued to false if author has no active submission' do
      earliest_queued = FactoryGirl.create(:submission,user:@author,created_at:@queued_submission.created_at - 1.day,queued:true)
      earliest_queued.queued.should be_true
      Submission.activate_submissions
      earliest_queued.reload
      @queued_submission.reload
      earliest_queued.created_at.should be < @queued_submission.created_at
      earliest_queued.queued.should be_false
      @queued_submission.queued.should be_true
    end

    it 'should not set any queued to false if author has active submission' do
      @old_submission.update_attribute(:activated_at,Time.zone.now)
      Submission.active.should include(@old_submission)
      Submission.in_queue.should include(@queued_submission)
      Submission.activate_submissions
      @queued_submission.reload
      @queued_submission.queued.should be_true
    end

    it 'should update activated_at to current if removed from queue' do
      @queued_submission.activated_at.should be_nil 
      @queued_submission.queued.should be_true
      Submission.activate_submissions
      @queued_submission.reload
      Submission.not_in_queue.should include(@queued_submission)
      @queued_submission.activated_at.should_not be_nil
    end
    it 'should not update activated_at to current if not removed from queue' do
      @old_submission.update_attribute(:activated_at,Time.zone.now)
      Submission.active.should include(@old_submission)
      Submission.in_queue.should include(@queued_submission)
      Submission.activate_submissions
      @queued_submission.reload
      Submission.in_queue.should include(@queued_submission)
      @queued_submission.activated_at.should be_nil
    end
    it 'should alert previous critiquers if removed from queue' do
      Alert.destroy_all
      Submission.in_queue.should include(@queued_submission)
      Submission.activate_submissions
      @queued_submission.reload
      Submission.in_queue.should_not include(@queued_submission)
      @old_submission.critiques.count.should eql(5)
      Alert.count.should eql(5)
    end

    it 'should not alert previous critiquers if not removed from queue' do
      Alert.destroy_all
      @old_submission.update_attribute(:activated_at,Time.zone.now)
      Submission.active.should include(@old_submission)
      Submission.in_queue.should include(@queued_submission)
      Submission.activate_submissions
      @queued_submission.reload
      Submission.in_queue.should include(@queued_submission)
      @old_submission.critiques.count.should eql(5)
      Alert.count.should eql(0)
    end
  end

  describe 'self.first_queued_for_user(user)' do
    it 'returns the earliest submission in queue for user' do
      submission.update_attribute(:queued,true)
      submission2 = FactoryGirl.create(:submission,user:submission.user,queued:true)
      Submission.in_queue.should include(submission)
      Submission.in_queue.should include(submission2)
      submission.created_at.should be < submission2.created_at
      Submission.first_queued_for_user(submission.user).should eql(submission) 
    end
  end

  describe '#self.ordered_by(order_by)' do
    before (:each) do
      author1 = FactoryGirl.create(:user,last:"Aush")
      author2 = FactoryGirl.create(:user,last:"Zush")
      @submission1 = FactoryGirl.create(:submission,user:author1,content:"one two",created_at:Time.zone.now-2.days,title:"A Title",genre:"Action")
      @submission2 = FactoryGirl.create(:submission,user:author2,content:"one two three",created_at:Time.zone.now-1.day,title:"Z Title",genre:"Horror")
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

    it 'returns active sorted by activated_at with latest first when activated_at' do
      Submission.ordered_by("activated_at").first.should eql(@submission2)
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

    it 'includes version numbers' do
      Chapter.create(submission:submission,name:"1")
      Chapter.create(submission:submission,name:"2",version:2)
      submission.chapter_list.should eql("1, 2 (v2)")      
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


end
