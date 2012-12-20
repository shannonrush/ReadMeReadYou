module UsersHelper
  def new_message_visibility(message)
    message.errors.any? ? "shown" : "hidden"
  end

  def date_for_inbox(message)
    message.created_at.strftime("%m/%d/%y")
  end

  def subject_link_weight(message)
    message.read? ? "" : "bolder_link"
  end

  def submission_status(submission)
    if Submission.active.include?(submission)
      return "active"
    elsif Submission.in_queue.include?(submission)
      index = [Submission.in_queue & submission.user.submissions].flatten.index(submission) + 1
      return "Queued ##{index}"
    else
      return "critiqued"
    end
  end
end
