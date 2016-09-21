class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :topic
      t.datetime :start_time
      t.datetime :end_time
      t.string :location
      t.string :owner
      t.text :content

      t.timestamps null: false
    end
  end
end
