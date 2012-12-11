class AddLinkToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :link, :string
  end
end
