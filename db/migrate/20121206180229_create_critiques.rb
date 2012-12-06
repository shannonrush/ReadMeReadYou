class CreateCritiques < ActiveRecord::Migration
  def change
    create_table :critiques do |t|
      t.integer :user_id
      t.integer :submission_id
      t.text :content
      t.integer :rating

      t.timestamps
    end
  end
end
