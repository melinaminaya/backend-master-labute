class CreateEvaluation < ActiveRecord::Migration[5.2]
  def change
    create_table :evaluations do |t|
      t.integer :rate, required: true
      t.belongs_to :service, index: true, required: true
      t.belongs_to :client, index: true
      t.belongs_to :worker, index: true
      t.timestamps
    end
  end
end
