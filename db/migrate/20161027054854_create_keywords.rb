class CreateKeywords < ActiveRecord::Migration[5.0]
  def change
    create_table :keywords do |t|
      t.string :content
      t.references :keywordable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
