class AddWorkerIdToService < ActiveRecord::Migration[5.2]
  def change
    add_reference :services, :worker, foreign_key: true
  end
end
