class PaymentConfirmation < ActionMailer::Base
 
  def confirmation_email(participant)
  	@payed_user = participant
  	@roomType = participant.accommodationType
  	@roomPrice = 0
  	@confPrice = 660

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

  	mail(to: @payed_user.email,
  		 from: "isotopes2015@conferences-travel-nevet.com",
  		 subject: 'Isotopes 2015 registration confirmation')
  end

  def confirmation_unsucessful(participant)
  	@payed_user = participant
  	mail(to: "giladrainer@gmail.com",
  		 from: "isotopes2015@conferences-travel-nevet.com",
  		 subject: 'Isotopes 2015 - Payment failure',
  		 tag: "payment-failure")
  end

end
