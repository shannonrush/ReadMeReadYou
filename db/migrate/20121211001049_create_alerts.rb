class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.integer :user_id
      t.string :message
      t.boolean :cleared

      t.timestamps
    end
  end
end
