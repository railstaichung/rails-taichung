class AddUniqueIndexToIssueRespondVotes < ActiveRecord::Migration[5.0]
  def change
    add_index :issue_respond_votes, [:issue_respond_id, :user_id], :unique => true
  end
end
