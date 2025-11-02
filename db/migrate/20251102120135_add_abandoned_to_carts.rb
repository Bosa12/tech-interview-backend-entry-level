class AddAbandonedToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean
    add_column :carts, :default, :string
    add_column :carts, :false, :string
  end
end
