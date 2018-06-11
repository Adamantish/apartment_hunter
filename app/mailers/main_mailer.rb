class MainMailer < ApplicationMailer

  def new_scam(email, details)
    
    @details = details
    mail(to: email, subject: 'WG found')
  end
end