class CreateWords < ActiveRecord::Migration[5.1]
  def change
    create_table :words do |t|

      t.string :name
      t.timestamps
    end

    create_table :definitions do |t|

      t.string :text
      t.timestamps
    end

    create_table :word_definitions do |t|
      t.belongs_to :word
      t.belongs_to :definition
      t.timestamps
    end

  end
end
