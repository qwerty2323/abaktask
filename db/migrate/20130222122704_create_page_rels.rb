class CreatePageRels < ActiveRecord::Migration
  def change
    create_table :page_rels do |t|
      t.integer :page_id
      t.integer :rel_id
      t.boolean :is_parent

      t.timestamps
    end
  end
end
