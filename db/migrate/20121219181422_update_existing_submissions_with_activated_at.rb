class UpdateExistingSubmissionsWithActivatedAt < ActiveRecord::Migration
  def up
    Submission.all.each {|s| s.update_attribute(:activated_at,s.created_at)}
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
