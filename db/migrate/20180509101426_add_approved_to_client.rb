class AddApprovedToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :approved, :boolean, default: false
  end
end
