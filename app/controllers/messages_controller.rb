class MessagesController < ApplicationController
  
  autocomplete :user, [:first,:last], :extra_data => [:last], :display_value => :full_name
  
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
    message = Message.find(params[:id]) rescue nil
    message.update_attributes(params[:message])
    respond_to do |format|
      format.json {render :nothing => true}
      format.html {redirect_to message.to}
    end
  end
end

