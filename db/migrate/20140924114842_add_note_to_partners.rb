class AddNoteToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :note, :text
  end
end
