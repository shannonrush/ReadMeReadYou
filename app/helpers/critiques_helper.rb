module CritiquesHelper
  def comment_date(comment)
    comment.created_at.strftime("%A, %B %e at %l:%M %p")
  end
end
