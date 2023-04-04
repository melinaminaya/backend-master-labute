class AddProposalReferenceToWorker < ActiveRecord::Migration[5.1]
  def change
    ids = Proposal.pluck(:id, :worker_id)
    remove_column :proposals, :worker_id
    add_reference :proposals, :worker, index: true

    ids.each do |mapping|
      p = Proposal.find(mapping[0])
      p.update(worker_id: mapping[1])
    end
  end
end
