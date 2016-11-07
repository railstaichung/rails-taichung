class AddInfoToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :info, :string
  end
end
