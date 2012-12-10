module CritiquesHelper
  def comment_date(comment)
    comment.created_at.strftime("%A, %B %e, %Y at %l:%M %p")
  end

  def date_for_list(critique)
    critique.created_at.strftime("%D")
  end

  def rating_for(critique)
    critique.rating.present? ? critique.rating : "unrated"
  end

end
