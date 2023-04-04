class CreateCuponUsage < ActiveRecord::Migration[5.2]
  def change
    create_table :cupon_usages do |t|
      t.belongs_to :service, index: true, required: true
      t.belongs_to :client, index: true, required: true
      t.belongs_to :cupon, index: true, required: true
    end
  end
end
