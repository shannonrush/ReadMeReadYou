class UsersController < ApplicationController

  before_filter :check_logged_in
  before_filter :check_for_user, :only => [:show,:update]
  before_filter :check_for_profile, :only => :show
  before_filter :check_authorization, :only => [:edit, :update]

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
  
  def check_logged_in
    authenticate_user!
  end

  def check_for_user
    @user = User.find(params[:id]) rescue nil
    unless @user
      redirect_to current_user, notice:"User not found, please try again"
    end
  end

  def check_for_profile
    if @user == current_user && @user.needs_profile_update?
      redirect_to edit_user_path(@user),notice:"Please complete your profile"
    end
  end

  def check_authorization
    unless current_user == @user
      redirect_to edit_user_path(current_user)
    end
  end

  
end
