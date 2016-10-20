class IssueRespondVote < ApplicationRecord
  belongs_to :user
  belongs_to :issue_respond
  validates_uniqueness_of :user_id, :scope => :issue_respond_id
end
