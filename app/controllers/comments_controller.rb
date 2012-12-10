class CommentsController < ApplicationController
  def create
    @comment = Comment.create(params[:comment])
    notice =  @comment.valid? ? "Thank you for commenting!" : "Your comment was not saved, please try again"
      redirect_to @comment.critique, notice:notice
  end
end
