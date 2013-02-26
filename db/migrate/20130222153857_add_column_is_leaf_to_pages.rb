class AddColumnIsLeafToPages < ActiveRecord::Migration
  def change
    add_column :pages, :is_leaf, :boolean

  end
end
