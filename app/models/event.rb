class Event < ActiveRecord::Base
  geocoded_by :location
  after_validation :geocode
  validates_presence_of :topic, :start_time, :end_time, :location, :content

  has_many :keywords, as: :keywordable

  has_many :user_events
  has_many :members, through: :user_events, source: :user
  has_many :beefs

  belongs_to :owner, class_name: 'User', foreign_key: :user_id

  mount_uploader :photo, PhotoUploader

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_photo

  def crop_photo
    photo.recreate_versions! if crop_x.present?
  end

  def editable_by?(user)
    user && user == owner
  end

  def active?
    is_active
  end

  def to_active
    update_columns(is_active: true)
  end

  def to_close
    update_columns(is_active: false)
  end
end
