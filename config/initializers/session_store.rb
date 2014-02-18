# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_lime-cms_session',
  :secret      => '5d9c2750d74cf67a7b79da3e5e10d3d54f9f094bf7e9b1e7815be6ef1b58539d9f949ed7bb67d3ea782e2e574ca680d401262f11b7ceec10eede6afa19e61efc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
