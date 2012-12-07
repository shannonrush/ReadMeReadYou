class CritiquesController < ApplicationController
  def create
    @critique = Critique.create(params[:critique])
    file_string = params[:file].read
    content = file_string.gsub(/\r\n/,"\n\n")
    @critique.update_attribute(:content,content)
    if @critique.valid?
      redirect_to user_path(@critique.user), :notice => "Your critique has been sent!"
    else
      render :action => "submissions/show"
    end
  end
end
