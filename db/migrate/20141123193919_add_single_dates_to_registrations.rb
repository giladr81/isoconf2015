class AddSingleDatesToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :June22, :boolean
    add_column :registrations, :June23, :boolean
    add_column :registrations, :June24, :boolean
    add_column :registrations, :June25, :boolean
  end
end
