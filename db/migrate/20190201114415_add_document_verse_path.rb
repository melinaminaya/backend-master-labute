class AddDocumentVersePath < ActiveRecord::Migration[5.2]
  def change
    add_column :workers, :document_verse_path, :string
    add_column :clients, :document_verse_path, :string
  end
end
