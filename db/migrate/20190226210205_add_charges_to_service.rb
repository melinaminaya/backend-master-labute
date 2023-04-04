class AddChargesToService < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :charges, :json, array: true, default: []
  end
end
