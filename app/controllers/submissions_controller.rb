class SubmissionsController < ApplicationController

  before_filter :check_logged_in
  before_filter :check_authorization, :only => [:edit, :update]

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.create(params[:submission])
    if params[:file].nil?
      return render :action => "new"
    else
      file_string = params[:file].read
      content = file_string.gsub(/\r\n/,"\n\n")
      @submission.update_attribute(:content,content)
    end
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

  def update
    if @submission.update_attributes(params[:submission])
      @submission.create_chapters(params[:chapters])
      redirect_to submission_path(@submission), :notice => "Submission updated!"
    else
      render :action => "edit"
    end
  end

  protected

  def check_logged_in
    authenticate_user!
  end

  def check_authorization
    @submission = Submission.find(params[:id])
    unless @submission.user == current_user 
      redirect_to user_path(current_user), :notice => "It seems like you ended up in the wrong place...Please try again!"
    end
  end
end
