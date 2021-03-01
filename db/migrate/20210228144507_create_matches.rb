class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.datetime :date
      t.float :score

      t.timestamps
    end
  end
end
