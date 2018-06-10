class CreateApartments < ActiveRecord::Migration[5.2]
  def change
    create_table :apartments do |t|
      t.string :ad_title
      t.string :ad_link
      t.timestamps
    end

    add_index :apartments, :ad_link
  end
end
