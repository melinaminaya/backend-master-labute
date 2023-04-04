class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.string :name
      t.string :status, default: 'waiting_for_acceptance'
      t.string :reject_reason
      t.references :client, foreign_key: true, null: true
      t.references :worker, foreign_key: true, null: true

      t.timestamps
    end
  end
end
