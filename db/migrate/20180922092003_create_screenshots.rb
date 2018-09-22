class CreateScreenshots < ActiveRecord::Migration[5.2]
  def change
    create_table :screenshots do |t|
      t.references :camera, foreign_key: true

      t.timestamps
    end
  end
end
