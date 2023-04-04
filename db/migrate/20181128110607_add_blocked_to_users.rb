class AddBlockedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :blocked, :boolean, default: false
    add_column :workers, :blocked, :boolean, default: false
  end
end
