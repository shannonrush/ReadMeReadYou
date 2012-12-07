module ApplicationHelper
  def viewer_is_user?(user)
    user_signed_in? && current_user == user
  end
end
