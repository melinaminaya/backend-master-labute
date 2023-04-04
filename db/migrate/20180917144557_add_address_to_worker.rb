class AddAddressToWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :workers, :address, :json, default: {}
  end
end
