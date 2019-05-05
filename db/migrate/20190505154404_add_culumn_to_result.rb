class AddCulumnToResult < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :collect_date, :datetime
  end
end
