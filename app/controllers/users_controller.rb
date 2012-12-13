class UsersController < ApplicationController

  before_filter :check_authorization, :only => [:edit, :update]
  before_filter :check_for_profile, :only => :show

  def update
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user)
    else
      render :action => "edit"
    end
  end

  def show
    @submissions = params[:submissions]=="all" ? @user.submissions : @user.submissions.limit(5)
    @critiques = params[:critiques]=="all" ? @user.critiques : @user.critiques.limit(5)
    @alerts = params[:alerts]=="all" ? Alert.uncleared_for_user(@user) : Alert.uncleared_for_user(@user).limit(5)
    @messages = params[:messages]=="all" ? Message.undeleted.to_user(@user) : Message.undeleted.to_user(@user).limit(5)
    @sent_messages = params[:sent_messages]=="all" ? Message.undeleted.from_user(@user) : Message.undeleted.from_user(@user).limit(5)
    @message = Message.new(params[:message])
    flash[:errors].each { |attr, message| @message.errors.add(attr, message) } if flash[:errors]
  end

  protected
  
  def check_authorization
    authenticate_user! # if there is no current_user redirect to sign in
    @user = User.find(params[:id]) rescue nil
    redirect_to current_user unless @user && current_user == @user #redirect to current_user if not user
  end


  def check_for_profile
    @user = User.find(params[:id]) rescue nil
    if @user
      if @user == current_user && @user.needs_profile_update?
      redirect_to edit_user_path(@user),notice:"Please complete your profile"
      end
    else
      redirect_to root_path,notice:"Please try again"
    end
  end

end
