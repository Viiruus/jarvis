class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :host, null: false, default: ""
      t.boolean :stripe, null: false, default: false
      t.boolean :added_to_trello, null: false, default: false

      t.timestamps
    end
  end
end
