class CreateSubCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_categories do |t|
      t.string :title, required: true
      t.string :image
      t.belongs_to :category, index: true, required: true

      t.timestamps
    end
  end
end
