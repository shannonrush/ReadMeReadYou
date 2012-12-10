module ApplicationHelper
  def viewer_is_user?(user)
    user_signed_in? && current_user == user
  end
  
  def date_for_list(element)
    element.created_at.strftime("%D")
  end

  def rating_for(critique)
    critique.rating.present? ? critique.rating : "unrated"
  end
end
