class CreateVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :versions do |t|
      t.string :number
      t.string :name
      t.string :authors
      t.string :summary
      t.string :licenses
      t.string :sha256
      t.bigint :size
      t.bigint :download_count
      t.integer :position
      t.boolean :latest
      t.references :mod, foreign_key: true

      t.timestamps
    end
  end
end
