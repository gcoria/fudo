require 'json'
require 'securerandom'

class AuthController
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
    begin
      data = JSON.parse(req.body.read)
    rescue JSON::ParserError
      return [400, {'content-type' => 'application/json'}, [{error: 'Invalid JSON'}.to_json]]
    end

    username = data['username']
    password = data['password']

    if USERS[username] == password
      token = SecureRandom.hex(16)
      @@tokens[token] = username

      [200, {'content-type' => 'application/json'}, [{token: token}.to_json]]
    else
      [401, {'content-type' => 'application/json'}, [{error: 'Invalid credentials'}.to_json]]
    end
  end

  private

  def respond_with(res, status, body)
    res.status = status
    res['Content-Type'] = 'application/json'
    res.write(body.to_json)
    res
  end
end