class CreateStays < ActiveRecord::Migration[7.2]
  def change
    create_table :stays do |t|
      t.date :start_date, null: false
      t.date :end_date
      t.references :studio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
