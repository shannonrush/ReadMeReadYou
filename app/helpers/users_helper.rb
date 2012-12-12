module UsersHelper
  def new_message_visibility(message)
    message.errors.any? ? "shown" : "hidden"
  end

  def date_for_inbox(message)
    message.created_at.strftime("%m/%d/%y %l:%M%p")
  end

  def subject_link_weight(message)
    message.read? ? "" : "bolder_link"
  end
end
