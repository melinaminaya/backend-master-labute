class AddPhoneToClientAndWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :phone, :string
    add_column :workers, :phone, :string
  end
end
