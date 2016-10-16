class Beef < ApplicationRecord
  validates :title, :description,  presence: true
end
