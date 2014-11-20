class PaymentsController < ApplicationController

	before_filter :set_prices
	@result = ''
	@show_params = ''
	def index
	end

	def show
	end

	def create

		participant = Registration.find_by(email: params[:email])
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

		
		@tours = {jerusalem: @result.jerusalem_tour?,
				  jer_participants: @result.jerusalem_participants,
				 deadsea: @result.deadsea_tour?,
				 deadsea_participants: @result.deadsea_participants,
				 nazareth: @result.nazareth_tour?,
				 nazareth_participants: @result.nazareth_participants,
				 caesarea: @result.caesarea?,
				 caesarea_participants: @result.caesarea_participants }
		calcToursPrice(@tours)

		if @confPrice.instance_of? String
			@totalPrice = @roomPrice + @toursPrice
		else
			@totalPrice = @roomPrice + @confPrice + @toursPrice
		end

		req = Nokogiri::XML::Builder.new do |xml|
		  xml.send("soap12:Envelope",
		  	'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
		  	'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema",
		  	'xmlns:soap12' => "http://www.w3.org/2003/05/soap-envelope") {
			xml.send("soap12:Body") {
					xml.SendParamToCredit2000('xmlns' => "http://tempuri.org/") {
						xml.send("parametr") {
							xml.tz_Number('011941622') # fill in
							xml.club('0')
							xml.confirmation_Source('0')
							xml.action_Type('5') # check
							xml.card_Reader('2') # check
							xml.client_Name('test')
							xml.host('http://www.google.co.il/')
							xml.company_Key('8fgU0hk2sG+AyzVb06TtTg==')
							xml.stars('0')
							xml.reader_Data('2') #check
							xml.currency('1') # check which is euro
							xml.total_Pyment(@totalPrice.to_s) # fill in, check what it should be with eurocents
							xml.purchase_Type('1')
							xml.uID('0')
							xml.vendor_Name('cus2000')
							xml.product_Id('8691') # id of participant
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


	def xml_res
		@show_params = params[:params]
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
		 	@toursPrice = @toursPrice + @tours[:jer_participants].to_i*100
		end
	end

end
