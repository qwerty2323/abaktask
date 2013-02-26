class RenameFullColumn < ActiveRecord::Migration
  def up
    rename_column :pages, :full_path, :path
  end

  def down
  end
end
