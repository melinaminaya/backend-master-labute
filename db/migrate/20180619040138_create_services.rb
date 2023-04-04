class CreateServices < ActiveRecord::Migration[5.1]
  def change
    create_table :services do |t|
      t.string :title, required: true
      t.string :description, required: true
      t.string :image
      t.datetime :end_date
      t.boolean :material_support, default: false
      t.string :status, required: true, default: 'waiting_for_approve'
      t.boolean :approved, default: false

      t.belongs_to :client, index: true, required: true
      t.timestamps
    end
    create_table :services_sub_categories, id: false do |t|
      t.belongs_to :service, index: true
      t.belongs_to :sub_category, index: true
    end
  end
end
