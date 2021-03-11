class AddSeatToRelPlayerMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :rel_player_matches, :seat, :string
  end
end
