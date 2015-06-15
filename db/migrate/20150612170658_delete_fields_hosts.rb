class DeleteFieldsHosts < ActiveRecord::Migration
  def change
    remove_column :hosts, :stripe
    remove_column :hosts, :shopify
  end
end
