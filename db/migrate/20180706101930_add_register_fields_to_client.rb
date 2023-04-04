class AddRegisterFieldsToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :register_token, :string
    add_column :clients, :image_path, :string
    add_column :clients, :document_path, :string
    add_column :clients, :proof_of_address_path, :string
    add_column :clients, :criminal_path, :string
  end
end
