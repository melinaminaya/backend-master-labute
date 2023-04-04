class ChangeServiceImageToArray < ActiveRecord::Migration[5.2]
  def change
    remove_column :services, :image, :string
    add_column :services, :images, :json, array: true, default: []
  end
end
