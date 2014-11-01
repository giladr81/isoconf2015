class AddToursParticipantsToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :jerusalem_participants, :integer
    add_column :registrations, :deadsea_participants, :integer
    add_column :registrations, :nazareth_participants, :integer
    add_column :registrations, :caesarea_participants, :integer
  end
end
