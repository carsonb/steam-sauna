class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :nickname
      t.string :image
      t.text :friends

      t.timestamps
      t.index :uid, unique: true
    end
  end
end
