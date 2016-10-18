class PhotoUploader < CarrierWave::Uploader::Base

# encoding: utf-8

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :qiniu
  self.qiniu_can_overwrite = true
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  version :small do
    process :crop
      version :banner do
        resize_to_fill(1080, 540)
      end
    resize_to_fill(300, 150)
  end

  version :large do
    resize_to_limit(1080, 540)
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(1080, 540)
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop!(x, y, w, h)
      end
    end
  end


  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
