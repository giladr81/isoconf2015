class PaymentsController < ApplicationController

	before_filter :set_prices
	@req_xml = 'default'
	@approveNum = ''
	@returnCode = ''
	# @show_params = ''
	
	def index
		redirect_to pay_url
	end

	def show

	end

	def create
		participant = Registration.find_by(email: params[:email])
		redirect_to pay_url,:flash => {error: 'Error! Unable to find email. Please fill in registration form first'} and return if participant.nil?		

		@result = participant		
		@roomType = participant.accommodationType
		case @roomType
		when 'Twin Room'
			@roomPrice = 1065
			@confPrice = 'Already included'
		when 'Single Room'
			@roomPrice = 1395
			@confPrice = 'Already included'
		when 'Double Room'
			@roomPrice = 1565
			@confPrice = 'Already included'
		when 'Prima Single Room'
			@roomPrice = 490
		when 'Prima Double Room'
			@roomPrice = 280*2
		end
		
		# @tours = {jerusalem: { going: @result.jerusalem_tour?, name: "Jerusalem & Bethlehem Tour", participants: @result.jerusalem_participants},
		# 		  deadsea:   { going: @result.deadsea_tour?, name: "Dead Sea & Masada Tour", participants: @result.deadsea_participants},
		# 		  nazareth:  { going: @result.nazareth_tour?, name: "Nazareth & Sea of Galilee Tour", participants: @result.nazareth_participants},
		# 		  caesarea:  { going: @result.caesarea?, name: "Caesarea, Acre & Rosh HaNikra Tour", participants: @result.caesarea_participants}
		# 		 }
		# calcToursPrice(@tours)

		if @confPrice.instance_of? String
			@totalPrice = (@roomPrice + @toursPrice)
		else
			@totalPrice = (@roomPrice + @confPrice + @toursPrice)
		end

		req = Nokogiri::XML::Builder.new do |xml|
		  xml.send("soap12:Envelope",
		  	'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
		  	'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema",
		  	'xmlns:soap12' => "http://www.w3.org/2003/05/soap-envelope") {
			xml.send("soap12:Body") {
					xml.SendParamToCredit2000('xmlns' => "http://tempuri.org/") {
						xml.send("parametr") {
							xml.tz_Number(participant.passport.to_s) # fill in
							xml.club('0')
							xml.confirmation_Source('0')
							xml.action_Type('5')
							xml.card_Reader('2')
							xml.client_Name(participant.title + ' ' + participant.lastName + ' ' + participant.firstName)
							xml.host('http://isotopes2015.conferences-travel-nevet.com/payments/confpay/')
							xml.company_Key('8fgU0hk2sG+AyzVb06TtTg==')
							xml.stars('0')
							xml.reader_Data('2')
							xml.currency('1') # check which is euro
							xml.total_Pyment((@totalPrice*100).to_s)
							xml.purchase_Type('1')
							xml.uID('0')
							xml.vendor_Name('cus2000')
							xml.product_Id(participant.id.to_s) # id of participant
							xml.return_Code('123')
							xml.fixed_Amount('0') #check
							xml.payments_Number('1') #check
							xml.first_Payment('0')
							xml.Approve('0') #check
							xml.ValidDate('1212')
							xml.StyleSheet
							xml.Lang('EN')
						}
					}
				}
			}
		end

		req_xml = req.to_xml

		client = Savon.client(
			endpoint: "https://www.credit2000.co.il/web_2202/wcf/wscredit2000.asmx",
			namespace: "http://tempuri.org/",
			pretty_print_xml: true)

		response = client.call(:send_param_to_credit2000, soap_action: "http://tempuri.org/SendParamToCredit2000", xml: req_xml)
		res = response.doc.remove_namespaces!

		@pay_link = res.xpath('//SendParamToCredit2000Result').text

		render 'show'
	end


	def confpay
		token = params[:params]
		req = Nokogiri::XML::Builder.new do |xml|
		  xml.send("soap12:Envelope",
		  	'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
		  	'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema",
		  	'xmlns:soap12' => "http://www.w3.org/2003/05/soap-envelope") {
			xml.send("soap12:Body") {
					xml.getTokenAndApprove('xmlns' => "http://tempuri.org/") {
						xml.uid(token) # fill in
						xml.approveNum()
						xml.returnCode()
						xml.customerId() # check
						xml.validDate() # check
						xml.cardType()
						}
					}
				}
		end

		client = Savon.client(
			endpoint: "https://www.credit2000.co.il/web_2202/wcf/wscredit2000.asmx?op=getTokenAndApprove",
			namespace: "http://tempuri.org/",
			pretty_print_xml: true)
		req_xml = req.to_xml

		response = client.call(:get_token_and_approve, soap_action: "http://tempuri.org/getTokenAndApprove", xml: req_xml)
		res = response.doc.remove_namespaces!

		approveNum = res.xpath('//getTokenAndApproveResponse/approveNum').text
		returnCode = res.xpath('//getTokenAndApproveResponse/returnCode').text
		userId = res.xpath('//etTokenAndApproveResponse/customerId').text

		@participant = Registration.find_by(id: userId.to_i)

		@pay_res = res

		if returnCode != '000'
			PaymentConfirmation.confirmation_email(@participant)
			redirect_to pay_url,:flash => {error: "Error! Couldn't complete payment, please try again later"} and return
		else
			PaymentConfirmation.confirmation_email(@participant)
			redirect_to root_url,:flash => {success: "Registration complete! You should receive a confirmation email shortly."} and return
		end
	end

	private

	def set_prices
		@confPrice = 660
		@roomType = ""
		@roomPrice = 0
		@toursPrice = 0
		@totalPrice = 0
		@tours
	end

	def calcToursPrice(tours)
		if tours[:jerusalem]
		 	@toursPrice = @toursPrice + @tours[:jerusalem][:participants].to_i*100
		end
		if tours[:deadsea]
		 	@toursPrice = @toursPrice + @tours[:deadsea][:participants].to_i*100
		end
		if tours[:nazareth]
		 	@toursPrice = @toursPrice + @tours[:nazareth][:participants].to_i*100
		end
		if tours[:caesarea]
		 	@toursPrice = @toursPrice + @tours[:caesarea][:participants].to_i*100
		end
	end

end
