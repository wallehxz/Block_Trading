class ApplicationMailer < ActionMailer::Base
  default from: Settings.email_account
  layout 'mailer'
end
