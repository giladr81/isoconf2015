class PaymentsController < ApplicationController

	@name

	def show
		# participant = Registration.find(params[:email])
		# @name = participant.accommodationType
	end

	def create
		participant = Registration.find_by(email: params[:email])
		@name = participant.accommodationType
		render 'show'
	end
end
