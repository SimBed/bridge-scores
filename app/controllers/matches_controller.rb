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
    @player_options = Player.all.map{ |p| [ p.alias, p.id ] }
    # default dropdown selections
    @player_N = Player.limit(4)[0].id
    @player_S = Player.limit(4)[1].id
    @player_E = Player.limit(4)[2].id
    @player_W = Player.limit(4)[3].id
  end

  # /matches/1/edit
  def edit
    @player_options = Player.all.map{ |p| [ p.alias, p.id  ] }
    # to populate the form
    @player_N=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[0].id
    @player_S=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[1].id
    @player_E=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[2].id
    @player_W=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:@match.id,player_id:p.id).result == @match.score ? 0 : 1 }[3].id
  end

  # POST /matches
  def create
    @match = Match.new(match_params)
      if @match.save
        score_Converter = {north: 1, south: 1, east: -1, west: -1}.each do |key, val|
           @match.rel_player_matches.build(player_id: params[:match][key], result: (params[:match][:score].to_f * val).round(2)).save
        end
        redirect_to matches_path, notice: "Match was successfully created."
      else
        @player_options = Player.all.map{ |p| [ p.id, p.alias ] }
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /matches/1
  def update
      if @match.update(match_params)
        @match.rel_player_matches[0].update(player_id: params[:match][:north], result: (params[:match][:score].to_f * 1).round(2))
        @match.rel_player_matches[1].update(player_id: params[:match][:south], result: (params[:match][:score].to_f * 1).round(2))
        @match.rel_player_matches[2].update(player_id: params[:match][:east], result: (params[:match][:score].to_f * -1).round(2))
        @match.rel_player_matches[3].update(player_id: params[:match][:west], result: (params[:match][:score].to_f * -1).round(2))
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

end
