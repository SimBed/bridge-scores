class Player < ApplicationRecord
  has_many :rel_player_matches, dependent: :destroy
  has_many :matches, through: :rel_player_matches
  validates :name, presence: true, length: { maximum: 20 }
  validates :alias, presence: true, length: { maximum: 20 }, uniqueness: { case_sensitive: false }
  scope :order_by_name, -> { order(name: :asc) }

  
  def self.match_history(sort_column, sort_direction)
    sql = "SELECT players.id, players.name, players.alias, COUNT(matches.date) as matches, MAX(matches.date), MIN(matches.date)
           FROM players 
           INNER JOIN rel_player_matches on players.id = rel_player_matches.player_id
           INNER JOIN matches on rel_player_matches.match_id = matches.id
           GROUP BY players.id
           ORDER BY #{sort_column} #{sort_direction};"
    ActiveRecord::Base.connection.exec_query(sql)
  end

  def leagues
    League.joins("INNER JOIN matches on leagues.id = matches.league_id
         INNER JOIN rel_player_matches on matches.id = rel_player_matches.match_id
         INNER JOIN players on rel_player_matches.player_id=players.id")
          .where("players.id=#{id}").distinct
  end

  def league_matches(league)
    matches.where("league_id=#{league.id}")
  end

  def score(league)
    score = 0
    rels_to_league = rel_player_matches.joins('INNER JOIN matches on rel_player_matches.match_id=matches.id')
                                       .where("league_id=#{league.id}").includes(:match)
    rels_to_league.each do |r|
      score += r.match.score * (r.seat == 'north' || r.seat == 'south' ? 1 : -1)
      # score += Match.find(r.match_id).score * (r.seat == 'north' || r.seat == 'south' ? 1 : -1)
    end
    score.round(2)
  end

  def position(league, text = false)
    player_score = score(league)
    league_scores = league.scores
    player_position = league_scores.index(player_score) + 1
    if text
      "#{player_position} #{'=' * (league_scores.count(player_score) - 1)}"
    # player_position.to_s + ' ' + '=' * (league_scores.count(player_score) - 1)
    else
      player_position
    end
  end

  def match_score(match)
    r = RelPlayerMatch.find_by(match_id: match.id, player_id: id)
    match.score * (r.seat == 'north' || r.seat == 'south' ? 1 : -1)
  end

  def partner(match)
    partner_code = { north: 'south', south: 'north', east: 'west', west: 'east' }
    r = RelPlayerMatch.find_by(match_id: match.id, player_id: id)
    partner_id = RelPlayerMatch.find_by(match_id: match.id, seat: partner_code[r.seat.to_sym]).player_id
    Player.find(partner_id).alias
  end

  def opponents(match)
    match.players.difference([name, Player.find_by(alias: partner(match)).name])
  end

  # return the seat of the player for the given match
  def seat(match)
    RelPlayerMatch.find_by(match_id: match.id, player_id: id)&.seat&.capitalize&.at(0)
  end
end
