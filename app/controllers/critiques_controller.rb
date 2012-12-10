class CritiquesController < ApplicationController

  before_filter :check_logged_in
  
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
      @submission = Submission.find(params[:critique][:submission_id])
      redirect_to @submission, :notice => "There was a problem with your critique file, please try again"
    end
  end

  def show
    @critique = Critique.find(params[:id])
    @comment = Comment.new
  end

  protected

  def check_logged_in
    authenticate_user!
  end
end
