class Registration < ActiveRecord::Base
	validates :title, presence: true
	validates :firstName, presence: true
	validates :lastName, presence: true

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true,
					  format: 	  { with: VALID_EMAIL_REGEX }, 
					  uniqueness: { case_sensitive: false }

	validates :institutionalAffiliation, presence: true
	validates :accommodationType, presence: true

	def self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |registration|
				csv << registration.attributes.values_at(*column_names)
			end
		end
	end
end
