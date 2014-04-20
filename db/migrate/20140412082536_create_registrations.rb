class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :title
      t.string :firstName
      t.string :lastName
      t.string :email
      t.string :institutionalAffiliation
      t.string :accommodationType
      t.string :doubleRoomShare
      t.integer :accompaniedBy
      t.boolean :presentationPoster
      t.boolean :presentationOral
      t.date :extraNightsBefoe
      t.date :extraNightsAfter
      t.string :specialRequests

      t.timestamps
    end
  end
end
