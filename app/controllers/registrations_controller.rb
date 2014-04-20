class RegistrationsController < ApplicationController
	before_action :authenticate_user!, only: [:index, :show, :edit, :update]

	def index
		# @results = Registration.order(:id)
		@results = Registration.all
		respond_to do |format|
			format.html
			format.csv { send_data @results.to_csv }
			format.xlsx
		end
	end

	def new
		@form = Registration.new
		# render layout: false
	end

	def show
		@results = Registration.find(params[:id])
	end

	def edit
		@result = Registration.find(params[:id])
	end

	def update
		@result = Registration.find(params[:id])
		if @result.update_attributes(form_params)
			flash[:success] = 'Details updated!'
			redirect_to root_url
		else
			render 'edit'
		end
	end

	def create
		@form = Registration.new(form_params)
		if @form.save
			flash[:success] = 'Details saved! Thank you for your participation.'
			redirect_to root_url
		else
			render 'new'
		end
	end

	private

	def form_params
		params.require(:registration).permit!
	end

end
