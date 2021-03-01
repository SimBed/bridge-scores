class CreateRelPlayerMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :rel_player_matches do |t|
      t.integer :player_id
      t.integer :match_id
      t.float :result

      t.timestamps
    end
  end
end
