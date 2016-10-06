class CreateEventPhotos < ActiveRecord::Migration
  def change
    create_table :event_photos do |t|
      t.integer :event_id
      t.string :image

      t.timestamps null: false
    end
  end
end
