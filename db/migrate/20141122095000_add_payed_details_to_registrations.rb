class AddPayedDetailsToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :credit2000Approve, :string
  end
end
