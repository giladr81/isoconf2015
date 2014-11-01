class AddToursToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :jerusalem_tour, :string
    add_column :registrations, :deadsea_tour, :string
    add_column :registrations, :nazareth_tour, :string
    add_column :registrations, :caesarea, :string
  end
end
