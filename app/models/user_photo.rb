class UserPhoto < ActiveRecord::Base
  belongs_to :UserPhoto
  mount_uploader :image, ImageUploader
end
