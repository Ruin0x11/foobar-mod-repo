class CreateDependencies < ActiveRecord::Migration[5.2]
  def change
    create_table :dependencies do |t|
      t.references :mod, foreign_key: true
      t.references :version, foreign_key: true
      t.string :requirements

      t.timestamps
    end
  end
end
