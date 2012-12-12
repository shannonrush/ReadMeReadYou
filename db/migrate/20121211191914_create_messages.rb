class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :from_id
      t.integer :to_id
      t.boolean :read
      t.boolean :deleted
      t.text :message
      t.string :subject

      t.timestamps
    end
  end
end
