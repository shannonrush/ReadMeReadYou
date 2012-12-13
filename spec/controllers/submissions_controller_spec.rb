require 'spec_helper'

describe SubmissionsController do
  let (:submission) {FactoryGirl.create(:submission)}
  let (:user) {FactoryGirl.create(:user, email:"sub@rmry.com")}
  describe '#check_logged_in' do
    it 'should redirect to sign in if no current user' do
      post :create
      response.should redirect_to(new_user_session_path)
    end
    it 'should not redirect to sign in if current user' do
      sign_in(submission.user)
      post :create
      response.should_not redirect_to(new_user_session_path)
    end
  end

  describe '#check_for_submission' do
    it 'should have submission not found flash notice if submission not found' do
      sign_in(submission.user)
      put :update,id:""
      flash[:notice].should eql("Submission not found, please try again")
    end
    it 'should not have submission not found flash notice if submission found' do
      sign_in(submission.user)
      put :update,id:submission.id
      flash[:notice].should_not eql("Submission not found, please try again")
    end
  end

  describe '#check_authorization_for_update' do
    it 'should have authorization failed flash notice if current_user is not submission user' do
      sign_in(user)
      put :update,id:submission.id
      flash[:notice].should eql("Authorization failed, please try again")
    end
    it 'should not have authorization failed flash notice if current_user is submission user' do
      sign_in(submission.user)
      put :update,id:submission.id
      flash[:notice].should_not eql("Authorization failed, please try again")
    end
  end

  describe '#check_authorization_for_create' do
    it 'should have authorization failed flash notice if current_user is not submission user' do
      sign_in(user)
      post :create,submission:{user_id:submission.user.id}
      flash[:notice].should eql("Authorization failed, please try again")
    end
    it 'should not have authorization failed flash notice if current_user is submission user' do
      sign_in(user)
      post :create,submission:{user_id:user.id}
      flash[:notice].should_not eql("Authorization failed, please try again")
    end
  end

  describe '#create' do
    it 'should create content from file' do
      sign_in(user)
      Submission.count.should eql(0)
      file = fixture_file_upload('/files/submission.txt', 'text/plain')
      post :create, file:file,submission:{user_id:user.id,title:"The Title",genre:"Horror"}
      submission = Submission.first
      submission.content.should_not be_nil
    end
    it 'should create a submission' do
      sign_in(user)
      Submission.count.should eql(0)
      file = fixture_file_upload('/files/submission.txt', 'text/plain')
      post :create, file:file,submission:{user_id:user.id,title:"The Title",genre:"Horror"}
      Submission.count.should eql(1) 
    end
    it 'should redirect to submission if valid' do
      sign_in(user)
      file = fixture_file_upload('/files/submission.txt', 'text/plain')
      post :create, file:file,submission:{user_id:user.id,title:"The Title",genre:"Horror"}
      response.should redirect_to(Submission.last)
    end
    it 'should render new if invalid' do
      sign_in(user)
      file = fixture_file_upload('/files/submission.txt', 'text/plain')
      post :create, file:file,submission:{user_id:user.id,title:"The Title"}
      response.should render_template("new")
    end
  end

  describe '#update' do
    it 'should update attributes' do
      sign_in(submission.user)
      submission.genre.should eql("Horror")
      put :update,id:submission.id,submission:{genre:"Fantasy"}
      submission.reload
      submission.genre.should eql("Fantasy")
    end
    it 'should redirect to submission if valid' do
      sign_in(submission.user)
      put :update,id:submission.id,submission:{genre:"Fantasy"}
      response.should redirect_to(submission) 
    end
    it 'should render edit if invalid' do
      sign_in(submission.user)
      put :update,id:submission.id,submission:{genre:""}
      response.should render_template("edit") 
    end
  end

end
