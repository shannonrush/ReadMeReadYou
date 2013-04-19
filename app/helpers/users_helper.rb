module UsersHelper
  def genres_written(user)
    if user.submissions.any?
      user.submissions.collect{|s|s.genre}.uniq.join(", ") 
    else
      return "None Yet"
    end
  end

  def average_rating(user)
    ratings = user.critiques.collect(&:rating).compact
    if ratings.any?
      return ratings.sum/ratings.length
    else
      return "N/A"
    end
  end

  def number_rated(user)
    user.critiques.collect(&:rating).compact.count
  end

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
      index = [Submission.in_queue & submission.user.submissions].flatten.sort_by(&:created_at).index(submission) + 1
      return "Queued ##{index}"
    else
      return "critiqued"
    end
  end

  def submission_date(submission)
    if Submission.in_queue.include?(submission)
      submission.created_at.strftime("%D")
    else
      submission.activated_at.strftime("%D")
    end
  end
end
