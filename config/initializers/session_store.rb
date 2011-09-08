# Be sure to restart your server when you modify this file.

Pair::Application.config.session_store :cookie_store, :key => '_pair_session'
# MyApp::Application.config.session_store :redis_session_store

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Pair::Application.config.session_store :active_record_store
