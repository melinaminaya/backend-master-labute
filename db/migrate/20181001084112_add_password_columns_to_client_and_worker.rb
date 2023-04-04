class AddPasswordColumnsToClientAndWorker < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :allow_password_change, :boolean, default: false
    add_column :clients, :password_will_change, :boolean, default: false
    add_column :workers, :allow_password_change, :boolean, default: false
    add_column :workers, :password_will_change, :boolean, default: false
  end
end
