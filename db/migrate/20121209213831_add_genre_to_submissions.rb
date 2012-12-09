class AddGenreToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :genre, :string
  end
end
