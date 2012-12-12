module UsersHelper
  def new_message_visibility(message)
    message.errors.any? ? "shown" : "hidden"
  end
end
