class AdaptTransactionToWirecard < ActiveRecord::Migration[5.2]
  def change
    rename_column :transactions, :status, :order_status
    change_column :transactions, :order_status, :string, default: 'CREATED'
    add_column :transactions, :payment_status, :string, default: 'CREATED'

    rename_column :transactions, :code, :order_id
    add_column :transactions, :payment_id, :string
  end
end
