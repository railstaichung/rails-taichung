class AddIsActiveToEvent < ActiveRecord::Migration
  def change
    add_column :events, :is_active, :boolean, default: true
  end
end
