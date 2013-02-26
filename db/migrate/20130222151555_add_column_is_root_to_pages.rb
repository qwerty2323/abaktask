class AddColumnIsRootToPages < ActiveRecord::Migration
  def change
    add_column :pages, :is_root, :boolean

  end
end
