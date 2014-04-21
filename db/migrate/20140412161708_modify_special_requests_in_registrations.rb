class ModifySpecialRequestsInRegistrations < ActiveRecord::Migration
  def change
  	change_column :registrations, :specialRequests, :text
  end
end
