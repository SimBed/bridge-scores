class AddIndexToPlayersAlias < ActiveRecord::Migration[6.0]
  def change
    add_index :players, :alias, unique: true
  end
end
