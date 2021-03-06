class Player < ApplicationRecord
  has_many :rel_player_matches, dependent: :destroy
  has_many :matches, through: :rel_player_matches
  validates :name,  presence: true, length: { maximum: 20 }
  validates :alias,  presence: true, length: { maximum: 20 }, uniqueness: { case_sensitive: false }

  def score
    score = 0
    rel_player_matches.each do |r|
      score = (score + r.result)
    end
    score.round(2)
  end

  def position
    scores = []
    Player.all.each do |p|
      scores << p.score
    end
    # alternative to reverse
    scores.sort_by { |i| -i }.index(self.score) + 1
  end

  def match_result(match)
    RelPlayerMatch.find_by(match_id: match.id, player_id: self.id).result
  end
end
