class Event < ActiveRecord::Base
  validates :topic, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :location, presence: true
  validates :content, presence: true

  has_many :user_events
  has_many :members, throught: :user_events, source: :user

  belongs_to :owner, class_name: "User", foreign_key: :user_id
end
