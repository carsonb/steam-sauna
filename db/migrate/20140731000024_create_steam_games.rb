class CreateSteamGames < ActiveRecord::Migration
  def change
    create_table :steam_games do |t|
      t.integer :app_id, null: false, limit: 8
      t.string :title, null: false
      t.text :header_image
      t.text :capsule_image
      t.text :categories
      t.boolean :multi_player

      t.timestamps
      t.index :app_id, unique: true
    end
  end
end
