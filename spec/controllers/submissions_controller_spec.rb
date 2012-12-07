require 'spec_helper'

describe SubmissionsController do
  let (:submission) {FactoryGirl.create(:submission)}
  let (:user) {FactoryGirl.create(:user, email:"subuser@test.com")}
  describe '#check_logged_in' do
    it 'should redirect to sign in if no current user' do
      get :edit, id:submission.id
      response.should redirect_to(new_user_session_path)
    end 
  end
  describe '#check_authorization' do
    it 'should redirect to current user path if current user is not submission user' do
      sign_in(user)
      get :edit, id:submission.id
      response.should redirect_to(user_path(user))
    end
    it 'should not redirect if current user is submission user' do
      sign_in(submission.user)
      get :edit, id:submission.id
      response.should_not be_redirect
      response.should be_successful
    end
  end
end
