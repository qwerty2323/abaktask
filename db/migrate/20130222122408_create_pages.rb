class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :full_path
      t.string :title
      t.string :text
      t.string :formatted_text

      t.timestamps
    end
  end
end
