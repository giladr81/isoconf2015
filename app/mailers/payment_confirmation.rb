class PaymentConfirmation < ActionMailer::Base
  default from: "isotopes2015@gmail.com"

  def confirmation_email(participant)
  	@payed_user = participant
  	mail(to: @payed_user.email, subject: 'Isotopes 2015 registration confirmation')
  end

end
