class CreateRacers < ActiveRecord::Migration[5.2]
  def change
    create_table :racers do |t|
      t.float :win_per
      t.float :two_ren_per
      t.float :three_ren_per
      t.float :first_per
      t.float :second_per
      t.float :third_per
      t.float :fourth_per
      t.float :fifth_per
      t.float :sixth_per
      t.float :first_cource
      t.float :second_cource
      t.float :third_cource
      t.float :fourth_cource
      t.float :fifth_cource
      t.float :sixth_cource

      t.timestamps
    end
  end
end
