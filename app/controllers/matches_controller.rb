class MatchesController < ApplicationController
  helper_method :sort_column, :sort_direction

  # %i[ ] # Non-interpolated Array of symbols, separated by whitespace (see ruby docs on literals)
  # equiv to [:edit, :update, :destroy]
  before_action :admin_user, only: %i[edit update destroy]
  before_action :set_match, only: %i[show edit update destroy]
  before_action :set_options, only: %i[new edit]

  # /matches
  def index
    # @matches = Match.all.order_by_date
    # sort_column and sort_direction are methods (defined below) that sanaitize the params
    @matches = Match.order("#{sort_column(nil)} #{sort_direction}")
  end

  # /matches/1
  def show; end

  # matches/new
  def new
    @match = Match.new
    # default dropdown selections
    # the & before the method checks for nil before calling the method (returning nil if nil)
    # protects against failure if there are less than 4 players for example if one has been deleted
    @player_n = Player.limit(4)[0]&.id
    @player_s = Player.limit(4)[1]&.id
    @player_e = Player.limit(4)[2]&.id
    @player_w = Player.limit(4)[3]&.id
  end

  # /matches/1/edit
  def edit
    @player_options += [['player removed', 'x']]
    # to populate the form
    @player_n = find_player('north')
    @player_s = find_player('south')
    @player_e = find_player('east')
    @player_w = find_player('west')
  end

  # POST /matches
  def create
    @match = Match.new(match_params)
    if @match.save
      %w[north south east west].each do |seat|
        rel_build(seat)
      end
      redirect_to matches_path, notice: 'Match was successfully created.'
    else
      set_options
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /matches/1
  def update
    if @match.update(match_params)
      %w[north south east west].each do |seat|
        rel_update(seat)
      end
      redirect_to matches_path, notice: 'Match was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /matches/1
  def destroy
    @match.destroy
    redirect_to matches_path, notice: 'Match was successfully deleted.'
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def set_options
    @player_options = Player.all.map { |p| [p.alias, p.id] }
    @league_options = League.all.map { |l| [l.name, l.id] }
  end

  def match_params
    params.require(:match).permit(:date, :score, :league_id)
  end

  def sort_column(_view)
    # in this context view won't be used hence the underscore (as advised by Rubocop)
    # Sanitizing the search options, so only items specified in the list can get through
    %w[date score league_id].include?(params[:sort]) ? params[:sort] : 'date'
  end

  def rel_update(seat)
    rel = @match.rel_player_matches.find_by(seat: seat)
    return rel.update(player_id: params[:match][seat.to_sym]) if rel

    rel_build(seat) unless params[:match][seat.to_sym] == 'x'
  end

  def rel_build(seat)
    @match.rel_player_matches.build(player_id: params[:match][seat.to_sym],
                                    seat: seat).save
  end

  def find_player(seat)
    @match.rel_player_matches.find_by(seat: seat)&.player_id || 'x'
    # @player_N=@match.players.to_a.sort_by{ |p| RelPlayerMatch.find_by(match_id:
    #         @match.id, player_id: p.id).result == @match.score ? 0 : 1 }[0].id
  end
end
