require 'twilio-ruby'

# put your own credentials here
account_sid = 'ACe26ff555036eb053a3eed510f846e2a2'
auth_token = 'abb23aff57e22b0ed8b138d4615de525'

# set up a client to talk to the Twilio REST API
Client = Twilio::REST::Client.new account_sid, auth_token

# alternatively, you can preconfigure the client like so
Twilio.configure do |config|
  config.account_sid = account_sid
  config.auth_token = auth_token
end
