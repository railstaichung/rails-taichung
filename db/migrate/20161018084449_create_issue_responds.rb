class CreateIssueResponds < ActiveRecord::Migration[5.0]
  def change
    create_table :issue_responds do |t|
      t.integer :issue_id
      t.integer :user_id
      t.text :content

      t.timestamps
    end
  end
end
