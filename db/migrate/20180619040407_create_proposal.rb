class CreateProposal < ActiveRecord::Migration[5.1]
  def change
    create_table :proposals do |t|
      t.decimal :price, required: true, precision: 7, scale: 2
      t.string :text, required: true
      t.boolean :approved, default: false
      t.boolean :accepted, default: false

      t.belongs_to :worker, index: true, required: true
      t.belongs_to :service, index: true, required: true
      t.timestamps
    end
  end
end
