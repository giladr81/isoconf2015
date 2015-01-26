class PaymentsController < ApplicationController

	before_filter :set_prices
	@req_xml = 'default'
	@approveNum = ''
	@returnCode = ''

	PLAZA_SINGLE = 150
	PLAZA_DOUBLE = 175
	PRIMA_SINGLE = 115
	PRIMA_DOUBLE = 125
	DISCOUNT = 125

	def index
		redirect_to pay_url
	end

	def show
		redirect_to pay_url
	end

	def create
		participant = Registration.find_by(email: params[:email])
		redirect_to pay_url,:flash => {error: 'Error! Unable to find email. Please fill in registration form first.'} and return if participant.nil?		
		redirect_to pay_url,:flash => {error: 'Error! Our records show you already payed. Please contact us with reference number ' + participant.id.to_s} and return if participant.payed?
		redirect_to pay_url,:flash => {error: 'Error! You chose bank transfer as payment method. Please contact <a href="mailto:galital@aviation-links.co.il">galital@aviation-links.co.il</a>'.html_safe} and return if participant.PaymentMethod == 'Bank transfer'

		if not participant.extraNightsBefoe.nil?
			nightsBefore = (Date.new(2015, 6, 21) - participant.extraNightsBefoe).to_i
			@moreNightsBefore = nightsBefore
		else
			nightsBefore = 0
		end

		if not participant.extraNightsAfter.nil?
			nightsAfter = (participant.extraNightsAfter - (Date.new(2015, 6, 26))).to_i
			@moreNightsAfter = nightsAfter
		else
			nightsAfter = 0
		end

		@result = participant		
		@roomType = participant.accommodationType
		case @roomType
		when 'Twin Room'
			@roomPrice = 1045 - DISCOUNT
			@confPrice = 'Already included'
		when 'Single Room'
			@roomPrice = 1375 - DISCOUNT
			@confPrice = 'Already included'
			@moreNightsBeforeTotal = nightsBefore * PLAZA_SINGLE
			@moreNightsAfterTotal = nightsAfter * PLAZA_SINGLE
		when 'Double Room'
			@roomPrice = 1545 - DISCOUNT 
			@confPrice = 'Already included'
			@moreNightsBeforeTotal = nightsBefore * PLAZA_DOUBLE
			@moreNightsAfterTotal = nightsAfter * PLAZA_DOUBLE
		when 'Prima Single Room'
			@roomPrice = 490
			@moreNightsBeforeTotal = nightsBefore * PRIMA_SINGLE
			@moreNightsAfterTotal = nightsAfter * PRIMA_SINGLE
		when 'Prima Double Room'
			@roomPrice = 280*2
			@moreNightsBeforeTotal = nightsBefore * PRIMA_DOUBLE
			@moreNightsAfterTotal = nightsAfter * PRIMA_DOUBLE
		when 'No Accommodation'
			@moreNightsBeforeTotal = 0
			@moreNightsAfterTotal = 0
		end
		
		if @roomType == 'No Accommodation'
			calc_single(@result)
		end

		if @confPrice.instance_of? String
			@totalPrice = (@roomPrice + @toursPrice + @moreNightsBeforeTotal + @moreNightsAfterTotal)
		else
			@totalPrice = (@confPrice +  @roomPrice + @toursPrice + @moreNightsBeforeTotal + @moreNightsAfterTotal)
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
							xml.action_Type('4')
							xml.card_Reader('2')
							xml.client_Name(participant.title + ' ' + participant.lastName + ' ' + participant.firstName)
							xml.host('http://isotopes2015.conferences-travel-nevet.com/payments/confpay/')
							xml.company_Key('gcv7KUX2LpOFNwpahmSvmQ==')
							xml.stars('0')
							xml.reader_Data('0')
							xml.currency('3') # check which is euro
							xml.total_Pyment((@totalPrice*100).to_s)
							xml.purchase_Type('1')
							xml.uID('0')
							xml.vendor_Name('CUS0686')
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
						xml.uid(token)
						xml.approveNum()
						xml.returnCode()
						xml.customerId()
						xml.validDate()
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
		userId = res.xpath('//getTokenAndApproveResponse/customerId').text

		@participant = Registration.find_by(id: userId.to_i)
		@pay_res = res

		if returnCode != '000'
			PaymentConfirmation.confirmation_unsucessful(@participant).deliver
			@errorCode = returnCode
			redirect_to pay_url,:flash => {error: "Error! Couldn't complete payment, please try again later"} and return
		else
			@participant.payed = true
			@participant.credit2000Approve = approveNum
			@participant.save
			PaymentConfirmation.confirmation_email(@participant).deliver
			redirect_to root_url,:flash => {success: "Registration complete! You should receive a confirmation email shortly."} and return
		end
	end

	private

	def set_prices
		@confPrice = 645 - DISCOUNT
		@roomType = ""
		@roomPrice = 0
		@toursPrice = 0
		@totalPrice = 0

		# Extra Nights
		# Quantity
		@moreNightsBefore = 0
		@moreNightsAfter = 0
		# Total - Quantity * Price
		@moreNightsBeforeTotal = 0
		@moreNightsAfterTotal = 0

		@singleDays = 0
	end

	def calc_single(participant)

		if participant.June22 == true
			@singleDays += 1
		end
		if participant.June23 == true
			@singleDays += 1
		end
		if participant.June24 == true
			@singleDays += 1
		end
		if participant.June25 == true
			@singleDays += 1
		end
		@confPrice = @singleDays * 140
	end
end
