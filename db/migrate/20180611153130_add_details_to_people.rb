class AddDetailsToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :search_url, :string
    add_column :people, :site_id, :integer
  end
end
