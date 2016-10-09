class Event < ActiveRecord::Base
  geocoded_by :location
  after_validation :geocode
  validates_presence_of :topic, :start_time, :end_time, :location, :content

  has_one :event_photo, dependent: :destroy
  accepts_nested_attributes_for :event_photo

  has_many :user_events
  has_many :members, through: :user_events, source: :user

  belongs_to :owner, class_name: "User", foreign_key: :user_id

  def editable_by?(user)
    user && user ==owner
  end

  def active?
    is_active
  end

  def to_active
    self.update_columns(is_active: true)
  end

  def to_close
    self.update_columns(is_active: false)
  end
end
