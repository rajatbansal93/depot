class ApplicationMailer < ActionMailer::Base
  default from: "Rajat bansal <depot@example.com>"
  layout 'mailer'

  def received
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def shipped
    @greeting = "Hi"

    mail to: "to@example.org"
  end

end
