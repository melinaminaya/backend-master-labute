class CreateTransaction < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.integer :status, default: 1
      t.string :code
      t.belongs_to :service, index: true, required: true
      t.timestamps
    end
  end
end
