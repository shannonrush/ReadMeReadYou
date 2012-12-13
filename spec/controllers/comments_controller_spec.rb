require 'spec_helper'

describe CommentsController do
  let (:user) {FactoryGirl.create(:user, email:"user@rmry.com")}
  let (:comment_user) {FactoryGirl.create(:user, email:"comment_user@rmry.com")}
  let (:critique) {FactoryGirl.create(:critique)}

  describe '#check_authorization' do
    it 'should redirect to sign in if no current user' do
      post :create
      response.should redirect_to(new_user_session_path)
    end
    it 'should not redirect to sign in if current user' do
      sign_in(user)
      put :create
      response.should_not redirect_to(new_user_session_path)
    end
    it 'should redirect if user in comment params is not current_user' do
      sign_in(user)
      put :create,comment:{user_id:comment_user.id}
      response.should redirect_to(user)
    end
    it 'should not redirect to user if comment params user and current user are the same' do
      sign_in(user)
      put :create,comment:{user_id:user.id,critique_id:critique.id}
      response.should_not redirect_to(user)
    end
  end
  describe '#create' do
    it 'should create a comment from params' do
      sign_in(comment_user)
      Comment.count.should eql(0)
      put :create,comment:{user_id:comment_user.id,critique_id:critique.id,content:"Comment"}
      Comment.count.should eql(1)
    end
    it 'should redirect to comment critique if comment.critique' do
      sign_in(comment_user)
      put :create,comment:{user_id:comment_user.id,critique_id:critique.id,content:"Comment"}
      response.should redirect_to(Comment.first.critique)
    end
    it 'should redirect to current user if not comment.critique' do
      sign_in(comment_user)
      put :create,comment:{user_id:comment_user.id,content:"Comment"}
      response.should redirect_to(comment_user)
    end
    it 'should have valid notice if valid' do
      sign_in(comment_user)
      put :create,comment:{user_id:comment_user.id,critique_id:critique.id,content:"Comment"}
      flash[:notice].should eql("Thank you for commenting!") 
    end
    it 'should have invalid notice if invalid' do
      sign_in(comment_user)
      put :create,comment:{user_id:comment_user.id,critique_id:critique.id,content:""}
      flash[:notice].should eql("Your comment was not saved, please try again") 
    end
  end

end
