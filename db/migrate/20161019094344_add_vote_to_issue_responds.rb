class AddVoteToIssueResponds < ActiveRecord::Migration[5.0]
  def change
    add_column :issue_responds, :vote, :integer, default: 0
  end
end
