class TempController < ApplicationController
	def index
	end

	def edit
		@result = Registration.find(params[:id])
	end

	def show
	end
	
	private

	def form_params
		params.require(:registration).permit!
	end

end
