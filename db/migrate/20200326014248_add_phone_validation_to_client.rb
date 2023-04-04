class AddPhoneValidationToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :phone_validated, :boolean, default: false
  end
end
