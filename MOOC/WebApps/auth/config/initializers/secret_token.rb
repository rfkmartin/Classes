# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Auth::Application.config.secret_key_base = '5c29ee5a8c94f772815a1834980a284903207121a9c4c6d814e5ae314335c8fb5686aff5a929dc5b9bdd98877db0ac6befa7578b0c8ff5f8e99ab33afa27699a'
