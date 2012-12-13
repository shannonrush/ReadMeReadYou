class CritiquesController < ApplicationController

  before_filter :check_logged_in
  before_filter :check_for_critique, :only => [:show, :update]
  before_filter :check_for_submission, :only => :index
  before_filter :check_for_submission_for_create, :only => :create
  before_filter :check_authorization, :only => :update
  before_filter :check_authorization_for_create, :only => :create

  def index
    order_by = params[:sort].present? ? params[:sort] : "created_at"
    @critiques = Critique.ordered_by(@submission.critiques,order_by)
  end

  def create
    @critique = Critique.create(params[:critique])
    unless params[:file].nil?
      content = ContentFixer.fix(params[:file])
      @critique.update_attribute(:content,content)
    end
    if @critique.valid?
      redirect_to @critique.user, :notice => "Your critique has been sent!"
    else
      redirect_to @submission, :notice => "There was a problem with your critique file, please try again"
    end
  end

  def show
    @comment = Comment.new
  end

  def update
    if params[:critique][:rating].present?
      @critique.update_attributes(params[:critique])
      notice = "Thank you for rating your critique!"
    else
      notice = "Please select rating"
    end
    redirect_to @critique, notice:notice
  end

  protected

  def check_logged_in
    authenticate_user!
  end
  
  def check_for_critique
    @critique = Critique.find(params[:id]) rescue nil
    unless @critique
      redirect_to current_user, notice:"Please try again"
    end
  end

  def check_for_submission
    @submission = Submission.find(params[:submission_id]) rescue nil
    unless @submission
      redirect_to current_user, notice:"Please try again"
    end
  end

  def check_for_submission_for_create
    @submission = Submission.find(params[:critique][:submission_id]) rescue nil
    unless @submission
      redirect_to current_user, notice:"Please try again"
    end
  end
  def check_authorization
    unless @critique.submission.user == current_user 
      redirect_to current_user, notice:"Please try again!"
    end
  end

  def check_authorization_for_create
    user = User.find(params[:critique][:user_id]) rescue nil
    unless user == current_user
      redirect_to current_user, notice:"Please try again!"
    end
  end
end
