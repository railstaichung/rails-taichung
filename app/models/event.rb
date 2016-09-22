class Event < ActiveRecord::Base
  validates :topic, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :location, presence: true
  validates :content, presence: true

  has_many :user_events
  has_many :user, through: :user_events
end
