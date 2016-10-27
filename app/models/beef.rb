class Beef < ApplicationRecord
  validates :title, :description, presence: true
  has_many :keywords, as: :keywordable
end
