class RenameImageColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :image, :profile_photo
  end
end
