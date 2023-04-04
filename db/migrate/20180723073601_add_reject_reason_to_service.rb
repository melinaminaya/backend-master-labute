class AddRejectReasonToService < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :reject_reason, :string
  end
end
