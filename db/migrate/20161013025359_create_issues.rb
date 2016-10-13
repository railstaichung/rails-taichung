class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :user_id
      t.string :title
      t.text :content
      t.string :issue_state

      t.timestamps null: false
    end
  end
end
