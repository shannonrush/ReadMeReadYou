class SubmissionsController < ApplicationController

  before_filter :check_authorization

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.create(params[:submission])
    file_string = params[:file].read
    content = file_string.gsub(/\r\n/,"\n\n")
    @submission.update_attribute(:content,content)
    if @submission.valid?
      @submission.create_chapters(params[:chapters])
      redirect_to submission_path(@submission)
    else
      render :action => "new"
    end
  end

  def show
    @submission = Submission.find(params[:id])
    @critique = Critique.new
  end

  def edit
    @submission = Submission.find(params[:id])
  end

  protected

  def check_authorization
    authenticate_user!
  end

end
