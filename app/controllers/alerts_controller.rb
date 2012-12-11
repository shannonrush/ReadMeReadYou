class AlertsController < ApplicationController

  def update
    alert = Alert.find(params[:id])
    alert.update_attributes(params[:alert])
    redirect_to alert.user,notice:"Alert deleted"
  end

end
