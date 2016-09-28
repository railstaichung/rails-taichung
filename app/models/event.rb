class Event < ActiveRecord::Base
  validates_presence_of :topic, :start_time, :end_time, :location, :content

  has_many :user_events
  has_many :members, through: :user_events, source: :user

  belongs_to :owner, class_name: "User", foreign_key: :user_id
end
