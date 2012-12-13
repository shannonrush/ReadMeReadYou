require 'spec_helper'

describe AlertsController do
  let (:alert){FactoryGirl.create(:alert)}
  let (:user){FactoryGirl.create(:user)}

  describe '#check_logged_in' do
    it 'should redirect to sign in if no current user' do
      put :update, id:alert
      response.should redirect_to(new_user_session_path)
    end
    it 'should not redirect to sign in if current user' do
      sign_in(alert.user)
      put :update, id:alert
      response.should_not redirect_to(new_user_session_path)
    end
  end
  describe '#check_for_alert' do
    it 'should redirect to current_user if alert not found' do
      sign_in(alert.user)
      put :update, id:""
      response.should redirect_to(alert.user)
    end
  end
  describe '#check_authorization' do
    it 'should redirect to current_user if alert user is not current_user' do
      sign_in(user)
      put :update, id:alert
      response.should redirect_to(user)
    end
  end
  describe '#update' do
    it 'should update attributes' do
      sign_in(alert.user)
      alert.cleared.should be_false
      put :update, id:alert, alert:{cleared:true}
      alert.reload
      alert.cleared.should be_true
    end
    it 'should redirect to alert user with correct notice' do
      sign_in(alert.user)
      put :update, id:alert
      response.should redirect_to(alert.user)
      flash[:notice].should eql("Alert deleted")
    end
  end
end
