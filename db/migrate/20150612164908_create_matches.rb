class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :host
      t.references :pattern
      t.date :match_date
    end
  end
end
