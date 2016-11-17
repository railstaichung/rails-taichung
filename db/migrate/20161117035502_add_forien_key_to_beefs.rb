class AddForienKeyToBeefs < ActiveRecord::Migration[5.0]
  def change
    add_column :beefs, :user_id, :integer
    add_column :beefs, :event_id, :integer
    add_column :beefs, :photo, :string
  end
end
