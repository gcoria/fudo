require 'securerandom'
require_relative 'base_controller'

class AuthController < BaseController
  USERS = {
    'admin' => 'secret',
    'test_user' => 'test_password'
  }

  @@tokens = {}

  def self.valid_token?(token)
    @@tokens.key?(token)
  end

  def self.username_for(token)
    @@tokens[token]
  end

  def call(req)
    data = parse_json(req)
    
    unless data
      return error_response(400, 'Invalid JSON')
    end

    username = data['username']
    password = data['password']

    if USERS[username] == password
      token = SecureRandom.hex(16)
      @@tokens[token] = username

      success_response(200, {token: token})
    else
      error_response(401, 'Invalid credentials')
    end
  end
end