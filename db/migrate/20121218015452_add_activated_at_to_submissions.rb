class AddActivatedAtToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :activated_at, :datetime
  end
end
