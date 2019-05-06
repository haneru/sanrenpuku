class AddColumnToRacer < ActiveRecord::Migration[5.2]
  def change
    add_column :racers, :racer_number, :string
  end
end
