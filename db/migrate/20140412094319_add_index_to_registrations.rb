class AddIndexToRegistrations < ActiveRecord::Migration
  def change
  		add_index :registrations, :email, unique: true
  end
end
