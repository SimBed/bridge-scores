class Match < ApplicationRecord
  has_many :rel_player_matches, dependent: :destroy
  has_many :players, through: :rel_player_matches
  belongs_to :league
  validates :date, presence: true
  validates :score, presence: true, numericality: true
  # belongs_to already triggers validation error if associated record is not present
  # (but present is not the same as present and not nil as I discovered during tests)
  validates :league_id, presence: true
  scope :order_by_date, -> { order(date: :desc) }

  # return the name of the player who sat in the given seat for the match
  def player(seat)
    # the & before the method checks for nil before calling the method (returning nil if nil)
    # find_by returns nil rather than error if no match
    Player.find_by(id: RelPlayerMatch.find_by(match_id: id, seat: seat)&.player_id)&.name.presence || '----'
  end
end
