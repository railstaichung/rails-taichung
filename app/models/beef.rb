class Beef < ApplicationRecord
  validates :title, :description,  presence: true

  acts_as_taggable # Alias of acts_as_taggable_on :tags
  acts_as_taggable_on :skills, :interests
end
