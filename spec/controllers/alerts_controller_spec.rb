require 'spec_helper'

describe AlertsController do
  describe '#check_authorization' do
    it 'should redirect to sign in if no current user' 
    it 'should redirect to current_user if alert not found'
    it 'should redirect to current_user if alert user is not current_user'
  end
  describe '#update' do
    it 'should update attributes'
    it 'should redirect to alert user with correct notice'
  end
end
