class AddBio < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :bio, :string, default: nil
    add_column :workers, :bio, :string, default: nil
  end
end
