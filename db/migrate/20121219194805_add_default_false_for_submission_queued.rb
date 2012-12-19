class AddDefaultFalseForSubmissionQueued < ActiveRecord::Migration
  def up
    change_column :submissions, :queued, :boolean, :default => false
  end


  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
