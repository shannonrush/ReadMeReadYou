require 'spec_helper'

describe UsersController do
  let(:user) {FactoryGirl.create(:user)}
  let(:other_user) {FactoryGirl.create(:user, email: "shannonmrush@gmail.com")}
  describe '#check_authorization' do
    it 'should redirect to sign in if no current user' do
      get :edit, id:user
      response.should redirect_to(new_user_session_path)
    end 
    it 'should redirect to current user edit path if trying to edit another user' do
      sign_in(user)
      get :edit, id:other_user
      response.should redirect_to(edit_user_path(user))
    end
    it 'should not redirect if current user is user' do
      sign_in(user)
      get :edit, id:user
      response.should_not be_redirect
      response.should be_successful
    end
  end
  describe '#update' do
    it 'should redirect user to user path upon update' do
      sign_in(user)
      put :update, {id:user.id}
      response.should redirect_to(user_path(user))
    end
  end

end
