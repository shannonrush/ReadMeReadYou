class CritiquesController < ApplicationController

  before_filter :check_logged_in
  before_filter :check_authorization, :only => :update

  def index
    order_by = params[:sort].present? ? params[:sort] : "created_at"
    @submission_id = params[:submission_id]
    if params[:submission_id].present?
      sub_critiques = Submission.find(params[:submission_id]).critiques
      @critiques = Critique.ordered_by(sub_critiques,order_by)
    else
      redirect_to current_user,notice:"Please try again"
    end
  end

  def create
    @critique = Critique.create(params[:critique])
    unless params[:file].nil?
      file_string = params[:file].read
      content = file_string.gsub(/\r\n/,"\n\n")
      @critique.update_attribute(:content,content)
    end
    if @critique.valid?
      redirect_to @critique.user, :notice => "Your critique has been sent!"
    else
      @critique = Submission.find(params[:critique][:submission_id])
      redirect_to @critique, :notice => "There was a problem with your critique file, please try again"
    end
  end

  def show
    @critique = Critique.find(params[:id]) rescue nil
    @comment = Comment.new
    unless @critique
      redirect_to current_user, notice:"Please try again"
    end
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
  
  def check_authorization
    @critique = Critique.find(params[:id])
    unless @critique.submission.user == current_user 
      redirect_to current_user, notice:"It seems like you ended up in the wrong place...Please try again!"
    end
  end
end
