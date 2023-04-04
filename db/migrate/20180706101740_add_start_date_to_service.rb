class AddStartDateToService < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :start_date, :datetime, required: true
  end
end
