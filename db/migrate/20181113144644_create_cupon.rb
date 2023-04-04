class CreateCupon < ActiveRecord::Migration[5.2]
  def change
    create_table :cupons do |t|
      t.string :name, required: true
      t.decimal :percentage, required: true
      t.timestamp
    end
  end
end
