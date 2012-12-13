class MessagesController < ApplicationController
  
  autocomplete :user, [:first,:last], :extra_data => [:last], :display_value => :full_name

  before_filter :check_authorization, :only => :update
  
  def create
    @message = Message.create(params[:message])
    if @message.valid?
      redirect_to @message.from,notice:"Your message has been sent!"
    else
      flash[:errors] = @message.errors.messages
      redirect_to user_path(@message.from,message:{subject:@message.subject,message:@message.message,to_id:@message.to_id})
    end
  end

  def update
    @message.update_attributes(params[:message])
    respond_to do |format|
      format.json {render :nothing => true}
      format.html {redirect_to @message.to}
    end
  end

  protected

  def check_authorization
    authenticate_user!
    @message = Message.find(params[:id]) rescue nil
    unless @message && current_user == @message.user
      redirect_to current_user,notice:"Please try again"
    end
  end

end

