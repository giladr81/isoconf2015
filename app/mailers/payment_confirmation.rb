class PaymentConfirmation < ActionMailer::Base
  default from: "isotopes2015@gmail.com"

  def confirmation_email(participant)
  	@participant = participant
  	mail(to: @participant.email, subject: 'Isotopes 2015 registration confirmation')
  end

end
