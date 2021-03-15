class Match < ApplicationRecord
  has_many :rel_player_matches, dependent: :destroy
  has_many :players, through: :rel_player_matches
  validates :date, presence: true
  validates :score, presence: true, numericality: true
  scope :order_by_date, -> { order(date: :desc) }

  # return the name of the player who sat in the given seat for the match
  def player(seat)
    # the & before the method checks for nil before calling the method (returning nil if nil)
    # find_by returns nil rather than error if no match
    Player.find_by(id: RelPlayerMatch.find_by(match_id: self.id, seat: seat)&.player_id)&.name.presence || '----'
  end
end
