class ApplicationMailer < ActionMailer::Base
  # default from: 'anas@ezicargo.com'
  # layout 'mailer'
  include Sendinblue

  mail = Sendinblue::Mailin.new("https://api.sendinblue.com/v2.0", Rails.application.secrets.sendinblue_api_key)
end
