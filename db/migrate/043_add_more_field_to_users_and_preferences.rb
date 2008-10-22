class AddMoreFieldToUsersAndPreferences < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string
    add_column :preferences, :default_project_for_mail, :integer
    add_column :preferences, :default_context_for_mail, :integer
    add_column :smtp_settings, :user_id, :integer
  end

  def self.down
    remove_column :users, :email, :string
    remove_column :preferences, :default_project_for_mail, :integer
    remove_column :preferences, :default_context_for_mail, :integer
	remove_column :smtp_settings, :user_id
  end
end
