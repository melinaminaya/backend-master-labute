class AddRegistrationIdToClientAndWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :registration_id, :string, default: nil
    add_column :workers, :registration_id, :string, default: nil
  end
end
