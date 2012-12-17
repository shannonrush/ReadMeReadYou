class AddQueuedToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :queued, :boolean
  end
end
