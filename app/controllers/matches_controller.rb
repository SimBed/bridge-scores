class MatchesController < ApplicationController
  before_action :set_match, only: %i[ show edit update destroy ]

  # /matches
  def index
    @matches = Match.all.order_by_date
  end

  # /matches/1
  def show
  end

  # matches/new
  def new
    @match = Match.new
    @player_options = Player.all.map{ |p| [ p.alias, p.id ] }
    @league_options = League.all.map{ |l| [ l.name, l.id ] }
    # default dropdown selections
    # the & before the method checks for nil before calling the method (returning nil if nil)
    # protects against failure if there are less than 4 players for example if one has been deleted
    @player_N = Player.limit(4)[0]&.id
    @player_S = Player.limit(4)[1]&.id
    @player_E = Player.limit(4)[2]&.id
    @player_W = Player.limit(4)[3]&.id
  end

  # /matches/1/edit
  def edit
    @player_options = Player.all.map{ |p| [p.alias, p.id] } + [['player removed', 'x']]
    @league_options = League.all.map{ |l| [ l.name, l.id ] }
    # to populate the form
    @player_N = @match.rel_player_matches.find_by(seat: 'north')&.player_id || 'x'
    @player_S = @match.rel_player_matches.find_by(seat: 'south')&.player_id || 'x'
    @player_E = @match.rel_player_matches.find_by(seat: 'east')&.player_id || 'x'
    @player_W = @match.rel_player_matches.find_by(seat: 'west')&.player_id || 'x'

    # @player_N=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id: @match.id, player_id: p.id).result == @match.score ? 0 : 1 }[0].id
    # @player_S=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id: @match.id, player_id: p.id).result == @match.score ? 0 : 1 }[1].id
    # @player_E=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id: @match.id, player_id: p.id).result == @match.score ? 0 : 1 }[2].id
    # @player_W=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id: @match.id, player_id: p.id).result == @match.score ? 0 : 1 }[3].id
  end

  # POST /matches
  def create
    @match = Match.new(match_params)
      if @match.save
        %w[north south east west].each do |seat|
           @match.rel_player_matches.build(player_id: params[:match][seat.to_sym], seat: seat).save
        end
        redirect_to matches_path, notice: "Match was successfully created."
      else
        @player_options = Player.all.map{ |p| [ p.id, p.alias ] }
        @league_options = League.all.map{ |l| [ l.name, l.id ] }
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /matches/1
  def update
      if @match.update(match_params)
        %w[north south east west].each do |seat|
          if @match.rel_player_matches.find_by(seat: seat)
            @match.rel_player_matches.find_by(seat: seat).update(player_id: params[:match][seat.to_sym])
          elsif params[:match][seat.to_sym] != 'x'
            @match.rel_player_matches.build(player_id: params[:match][seat.to_sym], seat: seat).save
          end
        end
          redirect_to matches_path, notice: "Match was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
  end

  # DELETE /matches/1
  def destroy
    @match.destroy
    redirect_to matches_path, notice: "Match was successfully deleted."
  end

  private
    def set_match
      @match = Match.find(params[:id])
    end

    def match_params
      params.require(:match).permit(:date, :score, :league_id)
    end

end
