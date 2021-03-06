class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]

  # /players
  def index
    # position is an instance method of class Player defined in player.rb
    # doesn't seem to be a way to sort by position at the database level (without including score as a column in the database)
    @players = Player.all.to_a.sort_by(&:position)
  end

  # /players/1
  def show
    @matches = @player.matches
  end

  # /players/new
  def new
    @player = Player.new
  end

  # /players/1/edit
  def edit
  end

  # POST /players
  def create
    @player = Player.new(player_params)

      if @player.save
        redirect_to players_path, notice: "Player #{@player.name} was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /players/1
  def update
      if @player.update(player_params)
        redirect_to players_path, notice: "Player was successfully updated."
        else
        render :edit, status: :unprocessable_entity
      end
  end

  # DELETE /players/1
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
end
