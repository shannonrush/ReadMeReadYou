class CommentsController < ApplicationController

  before_filter :check_authorization, :only => :create

  def create
    @comment = Comment.create(params[:comment])
    notice =  @comment.valid? ? "Thank you for commenting!" : "Your comment was not saved, please try again"
    if @comment.critique
      redirect_to @comment.critique, notice:notice
    else
      redirect_to current_user,notice:notice
    end
  end

  protected

  def check_authorization
    authenticate_user!
    user = User.find(params[:comment][:user_id]) rescue nil
    unless user == current_user
      redirect_to current_user
    end
  end
end
