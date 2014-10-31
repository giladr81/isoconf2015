class AddDetailsToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :passport, :string
    add_column :registrations, :country, :string
    add_column :registrations, :citizenship, :string
    add_column :registrations, :spouse_name, :string
    add_column :registrations, :spouse_passport, :string
    add_column :registrations, :spouse_country, :string
    add_column :registrations, :twin_share_with, :string
  end
end
