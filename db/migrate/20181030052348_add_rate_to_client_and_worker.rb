class AddRateToClientAndWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :rate, :decimal, default: 0
    add_column :workers, :rate, :decimal, default: 0
  end
end
