class AlertsController < ApplicationController

  before_filter :check_authorization, :only => :update

  def update
    @elert.update_attributes(params[:alert])
    redirect_to @alert.user,notice:"Alert deleted"
  end

  protected

  def check_authorization
    @alert = Alert.find(params[:id]) rescue nil
    if @alert.nil? || @alert.user != current_user
      redirect_to alert.user
    end
  end

end
