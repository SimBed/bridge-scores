class AddLeagueIdToMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :league_id, :integer
  end
end
