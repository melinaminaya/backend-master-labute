class AddBankAccountTypeToWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :workers, :bank_account_type, :string
  end
end
