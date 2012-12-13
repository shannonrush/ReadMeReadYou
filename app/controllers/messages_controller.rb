class MessagesController < ApplicationController
  
  autocomplete :user, [:first,:last], :extra_data => [:last], :display_value => :full_name

  before_filter :check_logged_in
  before_filter :check_for_message, :only => :update
  before_filter :check_authorization_for_update, :only => :update
  before_filter :check_authorization_for_create, :only => :create

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

  def check_logged_in
    authenticate_user!
  end

  def check_for_message
    @message = Message.find(params[:id]) rescue nil
    unless @message      
      redirect_to current_user,notice:"Message not found, please try again"
    end
  end

  def check_authorization_for_update
    unless current_user == @message.to
      redirect_to current_user,notice:"Authorization failed, please try again"
    end
  end

  def check_authorization_for_create
    user = User.find(params[:message][:from_id]) rescue nil
    unless current_user == user
      redirect_to current_user,notice:"Authorization failed, please try again"
    end
  end
 
end
