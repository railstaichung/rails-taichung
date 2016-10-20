class IssueRespond < ApplicationRecord
  belongs_to :issue
  belongs_to :user
  has_many :votes, class_name: "IssueRespondVote", foreign_key: :issue_respond_id, dependent: :destroy
  validates_presence_of :content
end
