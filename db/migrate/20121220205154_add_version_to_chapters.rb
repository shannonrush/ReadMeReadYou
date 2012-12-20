class AddVersionToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :version, :integer
  end
end
