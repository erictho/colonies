class Studio < ApplicationRecord
  has_many :stays, dependent: :destroy
end
