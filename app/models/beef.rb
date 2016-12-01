class Beef < ApplicationRecord
  paginates_per 10
  validates :title, :description, presence: true
  has_many :keywords, as: :keywordable
  belongs_to :user
  belongs_to :event

  acts_as_taggable # Alias of acts_as_taggable_on :tags
  acts_as_taggable_on :skills, :interests

end
