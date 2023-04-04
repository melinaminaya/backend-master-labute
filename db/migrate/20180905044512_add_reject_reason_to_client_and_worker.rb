class AddRejectReasonToClientAndWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :reject_reason, :string
    add_column :workers, :reject_reason, :string
  end
end
