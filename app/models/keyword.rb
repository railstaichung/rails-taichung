class Keyword < ApplicationRecord
  belongs_to :keywordable, polymorphic: true
end
