class AddStatusAndConfirmationTokenToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :confirmation_token, :string
    add_column :clients, :status, :string, required: true, default: 'pending', null: false
  end
end
