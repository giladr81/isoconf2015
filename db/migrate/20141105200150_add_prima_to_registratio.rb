class AddPrimaToRegistratio < ActiveRecord::Migration
  def change
    add_column :registrations, :PrimaType, :string
    add_column :registrations, :PrimaSpouse, :string
    add_column :registrations, :PrimaSpousePassport, :string
    add_column :registrations, :PrimaSpouseCountry, :string
  end
end
