class MainMailer < ApplicationMailer

  def new_scam(details)
    @@my_email ||= Person.find_by(name: 'ME').email
    @details = details
    mail(to: @@my_email, subject: 'Scam TIME!')
  end
end