class AllowUserNullOnEvaluation < ActiveRecord::Migration[5.2]
  def change
    change_column_null :evaluations, :client_id, true
    change_column_null :evaluations, :worker_id, true
  end
end
