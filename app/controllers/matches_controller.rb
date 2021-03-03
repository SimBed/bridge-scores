class MatchesController < ApplicationController
  before_action :set_match, only: %i[ show edit update destroy ]

  # /matches
  def index
    @matches = Match.all
  end

  # /matches/1
  def show
  end

  # matches/new
  def new
    @match = Match.new
    @players = Player.distinct.pluck(:alias)
  end

  # /matches/1/edit
  def edit
    @players = Player.distinct.pluck(:alias)
    # to populate the form
    @player_N=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[0].try(:alias)
    @player_S=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[1].try(:alias)
    @player_E=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[2].try(:alias)
    @player_W=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[3].try(:alias)
  end

  # POST /matches
  def create
    @match = Match.new(match_params)
      if @match.save
        hash = {north: 1, south: 1, east: -1, west: -1}
        hash.each do |key, val|
           @match.rel_player_matches.build(player_id: Player.find_by(alias: params[:match][key]).id, result: (params[:match][:score].to_f * val).round(2)).save
        end
        redirect_to matches_path, notice: "Match was successfully created."
      else
        @players = Player.distinct.pluck(:alias)
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /matches/1
  def update
      if @match.update(match_params)
        @match.rel_player_matches[0].update(player_id: Player.find_by(alias: params[:match][:north]).id, result: (params[:match][:score].to_f * 1).round(2))
        @match.rel_player_matches[1].update(player_id: Player.find_by(alias: params[:match][:south]).id, result: (params[:match][:score].to_f * 1).round(2))
        @match.rel_player_matches[2].update(player_id: Player.find_by(alias: params[:match][:east]).id, result: (params[:match][:score].to_f * -1).round(2))
        @match.rel_player_matches[3].update(player_id: Player.find_by(alias: params[:match][:west]).id, result: (params[:match][:score].to_f * -1).round(2))
        redirect_to matches_path, notice: "Match was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
  end

  # DELETE /matches/1
  def destroy
    @match.destroy
    redirect_to matches_path, notice: "Match was successfully destroyed."
  end

  private
    def set_match
      @match = Match.find(params[:id])
    end

    def match_params
      params.require(:match).permit(:date, :score)
    end

    def player_match_rel_params
      params.require(:match).permit(:north, :south, :east, :west)
    end
end
