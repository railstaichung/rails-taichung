class Event < ActiveRecord::Base
  has_many :user_events
  has_many :user, through: :user_events
end
