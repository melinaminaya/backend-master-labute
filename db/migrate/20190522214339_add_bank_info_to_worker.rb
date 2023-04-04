class AddBankInfoToWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :workers, :bank_digit, :string
    add_column :workers, :bank_account, :string
    add_column :workers, :bank_agency, :string
  end
end
