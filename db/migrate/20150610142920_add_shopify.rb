class AddShopify < ActiveRecord::Migration
  def change
    add_column :hosts, :shopify, :boolean, null: false, default: false
  end
end
