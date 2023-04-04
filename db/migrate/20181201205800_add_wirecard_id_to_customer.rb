class AddWirecardIdToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :wirecard_id, :string, default: nil
  end
end
