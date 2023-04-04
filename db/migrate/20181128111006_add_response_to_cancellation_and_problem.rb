class AddResponseToCancellationAndProblem < ActiveRecord::Migration[5.2]
  def change
    add_column :problems, :response, :string, default: nil
    add_column :cancellations, :response, :string, default: nil
  end
end
