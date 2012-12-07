class SubmissionsController < ApplicationController

  before_filter :check_authorization

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.create(params[:submission])
    if @submission.valid?
      @submission.create_chapters(params[:chapters])
      redirect_to submission_path(@submission)
    else
      render :action => "new"
    end
  end

  def show
    @submission = Submission.find(params[:id])
  end

  def edit
    @submission = Submission.find(params[:id])
  end

  protected

  def check_authorization
    authenticate_user!
  end

end
