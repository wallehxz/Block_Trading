class ApplicationMailer < ActionMailer::Base
  default from: Settings.devise_email
  layout false
end
