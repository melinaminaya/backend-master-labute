class AddTransactionNotificationControlVar < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :notified_approved_payment, :boolean, default: false
  end
end
