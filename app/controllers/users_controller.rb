class UsersController < ApplicationController

  before_filter :check_authorization, :only => [:edit, :update]

  def update
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user)
    else
      render :action => "edit"
    end
  end

  def show
    @user = User.find(params[:id])
  end

  protected

  def check_authorization
    authenticate_user! # if there is no current_user redirect to sign in
    @user = User.find(params[:id]) rescue nil
    redirect_to(edit_user_path(current_user)) unless @user && current_user == @user #redirect to current_user if not user
  end

end