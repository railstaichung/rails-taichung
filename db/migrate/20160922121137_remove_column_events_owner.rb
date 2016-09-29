class RemoveColumnEventsOwner < ActiveRecord::Migration
  def change
    remove_column :events, :owner, :string
  end
end
