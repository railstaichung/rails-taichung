class EventPhoto < ActiveRecord::Base
  belongs_to :EventPhoto

  mount_uploader :image, ImageUploader
end
