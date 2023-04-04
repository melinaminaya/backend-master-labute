class ChangeServiceDefaultStatus < ActiveRecord::Migration[5.1]
  def change
    change_column :services, :status, :string, default: 'waiting_for_approval'
  end
end
