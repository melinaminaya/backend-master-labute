class AddStatusToProposals < ActiveRecord::Migration[5.1]
  def change
    ids = Proposal.pluck(:id, :approved, :accepted)
    remove_column :proposals, :approved
    remove_column :proposals, :accepted
    add_column :proposals, :status, :string, default: 'waiting_for_approval'

    ids.each do |mapping|
      p = Proposal.find(mapping[0])
      p.update(status: Proposal::APPROVED) if mapping[1]
      p.update(status: Proposal::ACCEPTED) if mapping[2]
    end
  end
end
