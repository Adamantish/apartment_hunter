class CreateScrapes < ActiveRecord::Migration[5.2]
  def change
    create_table :scrapes do |t|
      t.integer :ads
      t.integer :new_ads

      t.timestamps
    end
  end
end
