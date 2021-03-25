class LeaguesController < ApplicationController
  before_action :set_league, only: %i[ show edit update destroy ]

  def index
    @leagues = League.all
  end

  def show
    #@players = Player.all.to_a.sort_by(&:position)
    @players = League.find(params[:id]).players.to_a.sort_by { |p| p.position(League.find(params[:id])) }
    # e.g. [["SimKann", 1, {"data-showurl"=>"http://localhost:3000/leagues/1"}],
    #        ["MonNight", 2, {"data-showurl"=>"http://localhost:3000/leagues/2"}]]
    @leagues = League.all.map{ |l| [ l.name, l.id, {'data-showurl' => league_url(l.id) } ] }
  end

  def new
    @league = League.new
  end

  def edit
  end

  def create
    @league = League.new(league_params)

    respond_to do |format|
      if @league.save
        format.html { redirect_to @league, notice: "League was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @league.update(league_params)
        format.html { redirect_to @league, notice: "League was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @league.destroy
    respond_to do |format|
      format.html { redirect_to leagues_url, notice: "League was successfully destroyed." }
    end
  end

  private
    def set_league
      @league = League.find(params[:id])
    end

    def league_params
      params.require(:league).permit(:name)
    end
end
