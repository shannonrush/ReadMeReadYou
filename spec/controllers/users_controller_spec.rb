require 'spec_helper'

describe UsersController do
  let (:user) {FactoryGirl.create(:user, email:"u@rmry.com")}
  let (:other_user) {FactoryGirl.create(:user, email:"rou@rmry.com")}

  describe '#check_logged_in' do
    it 'should redirect to sign in if no current user' do
      put :update, id:user
      response.should redirect_to(new_user_session_path)
    end
    it 'should not redirect to sign in if current user' do
      sign_in(user)
      put :update, id:user
      response.should_not redirect_to(new_user_session_path)
    end
  end

  describe '#check_for_user' do
    it 'should redirect to current_user if user not found' do
      sign_in(user)
      put :update, id:""
      response.should redirect_to(user)
    end
    it 'should not redirect to current_user if user found' do
      sign_in(user)
      put :update, id:other_user.id
      response.should_not redirect_to(user)
    end
  end
  describe '#check_for_profile' do
    it 'should redirect to edit user if current_user is user and user profile is incomplete' do
      user.update_attribute(:first,nil)
      sign_in(user)
      get :show, id:user.id
      response.should redirect_to(edit_user_path(user))
    end
    it 'should not redirect to edit user if current_user is user and user profile is complete' do
      sign_in(user)
      get :show, id:user.id
      response.should_not redirect_to(edit_user_path(user))
    end
  end
  
  describe '#check_authorization' do
    it 'should redirect to edit user if current_user is not user' do
      sign_in(user)      
      get :edit,id:other_user.id
      response.should redirect_to(edit_user_path(user))
    end
    it 'should not redirect to edit user if current_user is user' do
      sign_in(user)      
      put :update,id:user.id
      response.should_not redirect_to(edit_user_path(user))
    end
  end
end
