class SubmissionsController < ApplicationController

  before_filter :check_logged_in
  before_filter :check_for_submission, :only => [:show,:update]
  before_filter :check_authorization_for_update, :only => [:edit, :update]
  before_filter :check_authorization_for_create, :only => :create

  def index
    order_by = params[:sort].present? ? params[:sort] : "created_at"
    @submissions = Submission.ordered_by(order_by)
  end

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.create(params[:submission])
    unless params[:file].nil?
      content = ContentFixer.fix(params[:file])
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

  def check_for_submission
    @submission = Submission.find(params[:id]) rescue nil
    unless @submission
      redirect_to current_user, :notice => "Submission not found, please try again"
    end
  end

  def check_authorization_for_update
    unless @submission.user == current_user 
      redirect_to current_user, :notice => "Authorization failed, please try again"
    end
  end

  def check_authorization_for_create
    user = User.find(params[:submission][:user_id]) rescue nil
    unless user == current_user 
      redirect_to current_user, :notice => "Authorization failed, please try again"
    end
  end

end
