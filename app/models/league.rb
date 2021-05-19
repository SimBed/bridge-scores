class League < ApplicationRecord
  has_many :matches, dependent: :destroy
  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { case_sensitive: false }

  def players
    Player.joins("INNER JOIN rel_player_matches on players.id = rel_player_matches.player_id
       INNER JOIN matches on rel_player_matches.match_id = matches.id
       INNER JOIN leagues on matches.league_id=leagues.id")
          .where("leagues.id=#{id}").distinct
  end

  def scores
    scores = []
    players.each do |p|
      scores << p.score(self)
    end
    # alternative to scores.reverse!
    # scores.sort_by! { |i| -i }
    scores.sort_by(&:-@)
  end
end
