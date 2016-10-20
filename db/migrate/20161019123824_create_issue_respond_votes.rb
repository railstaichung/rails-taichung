class CreateIssueRespondVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :issue_respond_votes do |t|
      t.integer :issue_respond_id
      t.integer :user_id
      t.integer :vote_num

      t.timestamps
    end
  end
end
