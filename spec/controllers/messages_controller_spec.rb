require 'spec_helper'

describe MessagesController do
  let(:message){FactoryGirl.create(:message)}
  let(:user){FactoryGirl.create(:user)}
  describe '#check_logged_in' do
    it 'should redirect to sign in if no current user' do
      post :create
      response.should redirect_to(new_user_session_path)
    end
    it 'should not redirect to sign in if current user' do
      sign_in(message.from)
      post :create
      response.should_not redirect_to(new_user_session_path)
    end
  end
  describe '#check_for_message' do
    it 'should have message not found flash notice if message not found' do
      sign_in(user)
      put :update,id:""
      flash[:notice].should eql("Message not found, please try again")
    end
    it 'should not have message not found flash notice if message found' do
      sign_in(user)
      put :update,id:message.id
      flash[:notice].should_not eql("Message not found, please try again")
    end
  end
  describe '#check_authorization_for_update' do
    it 'should have authorization failed flash notice if current_user is not message receiver' do
      sign_in(user)
      put :update,id:message.id
      flash[:notice].should eql("Authorization failed, please try again")
    end
    it 'should not have authorization failed flash notice if current_user is message receiver' do
      sign_in(message.to)
      put :update,id:message.id
      flash[:notice].should_not eql("Authorization failed, please try again")
    end
  end
  describe '#check_authorization_for_create' do
    it 'should have authorization failed flash notice if current_user is not message sender' do
      sign_in(user)
      post :create,message:{}
      flash[:notice].should eql("Authorization failed, please try again")
    end
    it 'should not have authorization failed flash notice if current_user is message sender' do
      sign_in(user)
      post :create,message:{from_id:user.id,to_id:message.from.id,message:"Message",subject:"subject"}
      flash[:notice].should_not eql("Authorization failed, please try again")
    end
  end
  
  describe '#create' do
    it 'should create message from params' do
      sign_in(user)
      Message.count.should eql(0)
      post :create,message:{from_id:user.id,to_id:user.id,message:"Message",subject:"subject"}
      Message.count.should eql(1)
    end
    it 'should have valid notice if message valid' do
      sign_in(user)
      post :create,message:{from_id:user.id,to_id:user.id,message:"Message",subject:"subject"}
      flash[:notice].should eql("Your message has been sent!")
    end
    it 'should have flash errors if message invalid' do
      sign_in(user)
      post :create,message:{from_id:user.id,to_id:user.id,message:"Message",subject:""}
      flash[:errors].should eql({:subject=>["can't be blank"]})
    end
  end

  describe '#update'
end
