class WordSchema < ActiveRecord::Migration[5.1]
  def up
    change_table :words do |t|
      t.string :name
      t.string :definition
    end
  end
 
  def down
    change_table :words do |t|
      t.remove :name, :definition
    end
  end
end
