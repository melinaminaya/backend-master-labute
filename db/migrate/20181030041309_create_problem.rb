class CreateProblem < ActiveRecord::Migration[5.2]
  def change
    create_table :problems do |t|
      t.string :description, required: true
      t.belongs_to :service, index: true, required: true
      t.timestamps
    end
  end
end
