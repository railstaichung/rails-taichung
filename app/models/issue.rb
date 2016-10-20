class Issue < ActiveRecord::Base
  paginates_per 10
  validates_presence_of :title, :content
  belongs_to :owner, class_name: "User", foreign_key: :user_id
  has_many :responds, class_name: "IssueRespond", foreign_key: :issue_id, dependent: :destroy

  def control_by?(user)
     user && user == owner 
  end

  include AASM
  aasm :column => 'issue_state' do
    state :open, initial: true
    state :close

    event :close_issue do
      transitions from: :open, to: :close
    end
    event :reopen_issue do
      transitions from: :close, to: :open
    end
  end
end
