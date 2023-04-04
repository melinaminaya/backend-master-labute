class CreateCapacities < ActiveRecord::Migration[5.1]
  def change
    create_table :capacities do |t|
      t.belongs_to :worker, index: true
      t.belongs_to :sub_category, index: true
      t.timestamps
    end
  end
end
