class Field < ApplicationRecord
  has_many :results
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, inclusion: { in: 1..24 }, uniqueness: true
end
