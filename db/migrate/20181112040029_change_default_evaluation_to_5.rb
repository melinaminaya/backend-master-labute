class ChangeDefaultEvaluationTo5 < ActiveRecord::Migration[5.2]
  def change
    change_column :clients, :rate, :decimal, default: 5.0
    change_column :workers, :rate, :decimal, default: 5.0
  end
end
