require 'spec_helper'

describe CritiquesController do
  let (:critique){FactoryGirl.create(:critique)}
  let (:user){FactoryGirl.create(:user,email:"crit@rmry.com")}
  let (:sub_user){FactoryGirl.create(:user,email:"subuser@rmry.com")}
  let (:submission){FactoryGirl.create(:submission,user:sub_user)}
  describe '#check_logged_in' do
    it 'should redirect to sign in if no current user' do
      put :update, id:critique
      response.should redirect_to(new_user_session_path)
    end
    it 'should not redirect to sign in if current user' do
      sign_in(critique.user)
      put :update, id:critique
      response.should_not redirect_to(new_user_session_path)
    end
  end
  describe '#check_for_critique' do
    it 'should redirect to current_user if critique not found' do
      sign_in(critique.submission.user)
      put :update, id:"", critique:{}
      response.should redirect_to(critique.submission.user)
    end
    it 'should not redirect to current_user if critique found' do
      sign_in(critique.submission.user)
      put :update, id:critique, critique:{}
      response.should_not redirect_to(critique.submission.user)
    end
  end
  describe '#check_for_submission' do
    it 'should redirect to current_user if submission not found' do
     sign_in(critique.submission.user)
     get :index
     response.should redirect_to(critique.submission.user)
    end
    it 'should not redirect to current_user if submission found' do
      sign_in(critique.submission.user)
      get:index, submission_id:critique.submission
      response.should_not redirect_to(critique.submission.user)
    end
  end
  describe '#check_authorization' do
    it 'should redirect to current_user if critique submission user is not current_user' do
      sign_in(user)
      put :update, id:critique
      response.should redirect_to(user)
    end
  end
  describe '#check_authorization_for_create' do
    it 'should redirect to current_user if critique user is not current_user' do
      sign_in(user)
      put :update, id:critique
      response.should redirect_to(user)
    end
  end
  describe '#create' do
    it 'should create content from file' do
      sign_in(user)
      Critique.count.should eql(0)
      file = fixture_file_upload('/files/submission.txt', 'text/plain')
      post :create, file:file,critique:{submission_id:submission.id,user_id:user.id}
      critique = Critique.first
      critique.content.should_not be_nil
    end
    it 'should create a critique from params' do
      sign_in(user)
      Critique.count.should eql(0)
      file = fixture_file_upload('/files/submission.txt', 'text/plain')
      post :create, file:file,critique:{submission_id:submission.id,user_id:user.id}
      Critique.count.should eql(1)
    end
    it 'should redirect to critique user with valid notice if valid' do
      sign_in(user)
      file = fixture_file_upload('/files/submission.txt', 'text/plain')
      post :create, file:file,critique:{submission_id:submission.id,user_id:user.id}
      flash[:notice].should eql("Your critique has been sent!")
      response.should redirect_to(user)
    end
    it 'should redirect to submission with invalid notice if invalid' do
      sign_in(user)
      post :create, critique:{submission_id:submission.id,user_id:user.id}
      flash[:notice].should eql("There was a problem with your critique file, please try again")
      response.should redirect_to(submission)
    end

    describe '#update' do
      it 'should update attributes' do
        sign_in(critique.submission.user)
        critique.rating.should be_nil
        put :update,id:critique.id,critique:{rating:1}
        critique.reload
        critique.rating.should eql(1)
      end
      it 'should have valid notice if valid' do
        sign_in(critique.submission.user)
        put :update,id:critique.id,critique:{rating:1}
        flash[:notice].should eql("Thank you for rating your critique!") 
      end
      it 'should have invalid notice if invalid' do
        sign_in(critique.submission.user)
        put :update,id:critique.id,critique:{rating:""}
        flash[:notice].should eql("Please select rating") 
      end
      it 'should redirect to critique' do
        sign_in(critique.submission.user)
        put :update,id:critique.id,critique:{rating:1}
        response.should redirect_to(critique) 
      end
      
    end
  end
end
