class AddApprovedToWorker < ActiveRecord::Migration[5.1]
  def change
    add_column :workers, :approved, :boolean, default: false
  end
end
