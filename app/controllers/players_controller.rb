class PlayersController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :admin_user, only: %i[ new create edit update destroy]
  before_action :set_player, only: %i[ show edit update destroy ]

  def index
    # @players = Player.order_by_name
    if Player.column_names.include?(sort_column)
      @players = Player.order(sort_column + " " + sort_direction)
    else
      @players = Player.all.to_a.sort_by { |p| p.matches.count }
      @players.reverse! if sort_direction == 'desc'
    end
  end

  def show
    # @matches = @player.matches.order_by_date
    case sort_column

    when 'date'
    # if Player.column_names.include?(sort_column)
    @matches = @player.matches.order(sort_column + " " + sort_direction)
  when 'score'
    @matches = @player.matches.to_a.sort_by { |m| m.score }
    @matches.reverse! if sort_direction == 'desc'
  else
    @matches = @player.matches.order_by_date
  end
end

  def new
    @player = Player.new
  end

  def edit
  end

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
        redirect_to players_path, notice: "Player was successfully updated."
        else
        render :edit, status: :unprocessable_entity
      end
  end

  def destroy
    @player.destroy
    redirect_to players_path, notice: "Player was successfully removed."
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

    def sort_column
      # Sanitizing the search options, so only items specified in the list can get through
      %w[name alias matches date score league].include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
       #additional code provides robust sanitisation of what goes into the order clause
       %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
