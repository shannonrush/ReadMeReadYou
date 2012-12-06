class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :user_id
      t.string :title
      t.text :content
      t.text :notes

      t.timestamps
    end
  end
end
