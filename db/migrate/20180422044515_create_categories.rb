class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :title, required: true
      t.string :image

      t.timestamps
    end
  end
end
