class PaymentConfirmation < ActionMailer::Base
 
  def confirmation_email(participant)
  	@payed_user = participant
  	mail(to: @payed_user.email, subject: 'Isotopes 2015 registration confirmation')
  end

  def confirmation_unsucessful(participant)
  	@payed_user = participant
  	mail(to: "giladrainer@gmail.com", subject: 'Isotopes 2015 - Payment failure')
  end

end
