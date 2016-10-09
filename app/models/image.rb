class Image < ActiveRecord::Base
  mount_uploader :url, UserimageUploader
  belongs_to :user

end
