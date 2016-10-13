class Issue < ActiveRecord::Base
  belongs_to :owner, class_name: "User", foreign_key: :user_id
  include AASM
  aasm :column => 'issue_state' do
    state :open, initial: true
    state :closed

    event :close_issue do
      transitions from: :open, to: :closed
    end
  end
end
