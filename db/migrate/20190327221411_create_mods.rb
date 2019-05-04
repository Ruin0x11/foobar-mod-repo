class CreateMods < ActiveRecord::Migration[5.2]
  def change
    create_table :mods do |t|
      t.string :identifier
      t.references :user

      t.timestamps
    end
    add_index :mods, :identifier, unique: true
  end
end
