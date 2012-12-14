module CritiquesHelper
  def comment_date(comment)
    comment.created_at.strftime("%A, %B %e, %Y at %l:%M %p")
  end
end
