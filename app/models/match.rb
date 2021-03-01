class Match < ApplicationRecord
  has_many :rel_player_matches, dependent: :destroy
  has_many :players, through: :rel_player_matches
  validates :date, presence: true
  validates :score, presence: true, numericality: true
end
