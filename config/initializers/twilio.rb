require 'twilio-ruby'

# put your own credentials here
if Rails.env == "development"
  TWILIO_SID = 'ACd7ec911c90d59516569d2dc021c6d462'
  TWILIO_AUTH_TOKEN = '780edc339ce2f0d9f8d36987fdc3663a'
  TWILIO_NUMBER = '+14018294438'
else
  TWILIO_SID = ''
  TWILIO_AUTH_TOKEN = ''
  TWILIO_NUMBER = ''
end

# set up a client to talk to the Twilio REST API
Client = Twilio::REST::Client.new TWILIO_SID, TWILIO_AUTH_TOKEN

# alternatively, you can preconfigure the client like so
Twilio.configure do |config|
  config.account_sid = TWILIO_SID
  config.auth_token = TWILIO_AUTH_TOKEN
end
