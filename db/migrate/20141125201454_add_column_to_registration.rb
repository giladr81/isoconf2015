class AddColumnToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :PaymentMethod, :string
  end
end
