class AddPayedToRegistrations < ActiveRecord::Migration
  def change
  	add_column :registrations, :payed, :boolean
  end
end
