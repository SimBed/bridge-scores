class PlayersController < ApplicationController
  before_action :admin_user, only: %i[ new create edit update destroy]
  before_action :set_player, only: %i[ show edit update destroy ]

  def index
    @players = Player.order_by_name
  end

  def show
    @matches = @player.matches.order_by_date
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
end
