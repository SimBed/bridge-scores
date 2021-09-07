class PlayersController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :admin_user, only: %i[new create edit update destroy]
  before_action :set_player, only: %i[show edit update destroy]

  def index
    # @players = Player.order_by_name
    @players = if Player.column_names.include?(sort_column('index'))
                 Player.order("#{sort_column('index')} #{sort_direction}")
               else
                 Player.left_joins(:matches).group(:id).order("count(matches.id) #{sort_direction}")
               end
    ajax_respond
  end

  def show
    # Some columns to sort by are database table columns, some are methods.
    # The table columns can be ordered at database level. The methods require
    # the data to be extracted to a Ruby array and sorted from there.
    case sort_column('show')
    when 'date', 'league_id'
      # if Player.column_names.include?(sort_column)
      @matches = @player.matches.order("#{sort_column('show')} #{sort_direction(direction: 'desc')}")
    when 'match_score', 'seat', 'partner'
      @matches = @player.matches.to_a.sort_by { |m| @player.send(sort_column('show'), m) }
      @matches.reverse! if sort_direction == 'desc'
    end
    ajax_respond
  end

  def new
    @player = Player.new
  end

  def edit; end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to players_path, notice: "Player #{@player.name} was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      redirect_to players_path, notice: 'Player was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
    redirect_to players_path, notice: 'Player was successfully removed.'
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    # take the params hash, which might look like
    # params{controller: something, somehash{...}, {player{name: name, alias: alias, something: something}}
    # and return player{name: name, alias: alias}
    params.require(:player).permit(:name, :alias)
  end

  def sort_column(view)
    # Sanitizing the search options, so only items specified in the list can get through
    case view
    when 'index'
      %w[name alias matches].include?(params[:sort]) ? params[:sort] : 'name'
    when 'show'
      %w[date match_score seat partner league_id].include?(params[:sort]) ? params[:sort] : 'date'
    end
  end

  def ajax_respond
    respond_to do |format|
      format.html
      format.js
    end
  end
end
