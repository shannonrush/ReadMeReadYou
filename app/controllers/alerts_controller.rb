class AlertsController < ApplicationController

  before_filter :check_logged_in, :check_for_alert, :check_authorization

  def update
    @alert.update_attributes(params[:alert])
    redirect_to @alert.user,notice:"Alert deleted"
  end

  protected

  def check_logged_in
    authenticate_user!
  end

  def check_for_alert
    @alert = Alert.find(params[:id]) rescue nil
    unless @alert
      redirect_to current_user
    end
  end

  def check_authorization
    if  @alert.user != current_user
      redirect_to current_user
    end
  end

end
