class CommentsController < ApplicationController

  before_filter :check_authorization, :only => :create

  def create
    @comment = Comment.create(params[:comment])
    notice =  @comment.valid? ? "Thank you for commenting!" : "Your comment was not saved, please try again"
      redirect_to @comment.critique, notice:notice
  end

  protected

  def check_authorization
    authenticate_user!
    user = User.find(params[:comment][:user_id])
    unless user == current_user
      redirect_to root_path,notice:"Please try again"
    end
  end
end
