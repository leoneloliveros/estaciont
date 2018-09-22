class CreateWorkers < ActiveRecord::Migration[5.2]
  def change
    create_table :workers do |t|
      t.integer :station_id
      t.string :name

      t.timestamps
    end
  end
end