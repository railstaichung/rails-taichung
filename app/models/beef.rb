class Beef < ApplicationRecord

  validates :title, :description, presence: true
  has_many :keywords, as: :keywordable
  belongs_to :event
  belongs_to :user

  acts_as_taggable # Alias of acts_as_taggable_on :tags
  acts_as_taggable_on :skills, :interests

end
