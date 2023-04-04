class AddRegisterFieldsToWorker < ActiveRecord::Migration[5.1]
  def change
    add_column :workers, :register_token, :string
    add_column :workers, :confirmation_token, :string
    add_column :workers, :image_path, :string
    add_column :workers, :document_path, :string
    add_column :workers, :proof_of_address_path, :string
    add_column :workers, :criminal_path, :string
    add_column :workers, :status, :string, required: true, default: 'pending', null: false
  end
end
