class AddRejectReasonToProposal < ActiveRecord::Migration[5.1]
  def change
    add_column :proposals, :reject_reason, :string
  end
end
