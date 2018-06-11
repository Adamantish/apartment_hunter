class AddPersonIdToApartments < ActiveRecord::Migration[5.2]
  def change
    add_column :apartments, :person_id, :integer
    add_index :apartments, :person_id
  end
end
