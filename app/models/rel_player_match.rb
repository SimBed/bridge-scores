class RelPlayerMatch < ApplicationRecord
  belongs_to :player
  belongs_to :match
  validates :player_id, presence: true
  validates :match_id, presence: true
  validates :result, presence: true
end
