class AddCpfToClientAndWorker < ActiveRecord::Migration[5.1]
  def change
    add_column :workers, :cpf, :string
    add_index :workers, :cpf, unique: true

    add_column :clients, :cpf, :string
    add_index :clients, :cpf, unique: true
  end
end
