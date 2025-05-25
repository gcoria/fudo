require_relative '../test_helper'
require 'controllers/auth_controller'
require 'rack/mock'

class AuthControllerTest < Minitest::Test
  def setup
    @controller = AuthController.new
    AuthController.class_variable_set(:@@tokens, {})
  end

  def test_successful_authentication
    env = Rack::MockRequest.env_for(
      '/auth',
      method: 'POST',
      input: { username: 'admin', password: 'secret' }.to_json,
      'CONTENT_TYPE' => 'application/json'
    )
    request = Rack::Request.new(env)
    
    status, headers, body = @controller.call(request)
    response_body = JSON.parse(body.first)
    
    assert_equal 200, status
    assert_equal 'application/json', headers['content-type']
    assert response_body['token'], "Response should contain a token"
    assert_equal 32, response_body['token'].length, "Token should be 32 characters (16 bytes hex)"
  end

  def test_invalid_credentials
    env = Rack::MockRequest.env_for(
      '/auth',
      method: 'POST',
      input: { username: 'wrong', password: 'wrong' }.to_json,
      'CONTENT_TYPE' => 'application/json'
    )
    request = Rack::Request.new(env)
    
    status, headers, body = @controller.call(request)
    response_body = JSON.parse(body.first)
    
    assert_equal 401, status
    assert_equal 'application/json', headers['content-type']
    assert_equal 'Invalid credentials', response_body['error']
  end

  def test_invalid_json
    env = Rack::MockRequest.env_for(
      '/auth',
      method: 'POST',
      input: "This is not JSON",
      'CONTENT_TYPE' => 'application/json'
    )
    request = Rack::Request.new(env)
    
    status, headers, body = @controller.call(request)
    response_body = JSON.parse(body.first)
    
    assert_equal 400, status
    assert_equal 'application/json', headers['content-type']
    assert_equal 'Invalid JSON', response_body['error']
  end

  def test_token_validation
    env = Rack::MockRequest.env_for(
      '/auth',
      method: 'POST',
      input: { username: 'admin', password: 'secret' }.to_json,
      'CONTENT_TYPE' => 'application/json'
    )
    request = Rack::Request.new(env)
    
    _, _, body = @controller.call(request)
    token = JSON.parse(body.first)['token']
    
    assert AuthController.valid_token?(token), "Token should be valid"
    assert_equal 'admin', AuthController.username_for(token), "Username should be retrievable from token"
    
    assert_equal false, AuthController.valid_token?("invalid_token"), "Invalid token should not be valid"
    assert_nil AuthController.username_for("invalid_token"), "Invalid token should not have a username"
  end
end 