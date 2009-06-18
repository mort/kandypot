# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_kandypot_session',
  :secret      => '552b3f511af53391e6e6a72198e3c85df499822e087083ca7d1b0f3144472b57c8a8234484bcd825df568a293ffefed6ed9d445396a22616c3c02399af9f84e6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
