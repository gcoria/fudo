require_relative '../test_helper'
require 'api'
require 'rack/test'

class ApiAuthenticationTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    AuthController.class_variable_set(:@@tokens, {})
    ProductController.class_variable_set(:@@products, [])
  end

  def app
    API.new
  end

  def test_authentication_flow
    post '/auth', { username: 'admin', password: 'secret' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    assert_equal 200, last_response.status
    response_body = JSON.parse(last_response.body)
    assert response_body['token'], "Response should contain a token"
    token = response_body['token']

    get '/products', nil, { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
    assert_equal 205, last_response.status
    response_body = JSON.parse(last_response.body)
    assert_equal [], response_body['products']

    post '/products', 
         { name: 'Test Product', price: 99.99 }.to_json, 
         { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
    assert_equal 202, last_response.status, "Should return 202 Accepted for async creation"
    response_body = JSON.parse(last_response.body)
    assert_equal 'processing', response_body['status']
    assert response_body['job_id'], "Response should contain a job ID"
    
    sleep 3
    get '/products', nil, { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
    assert_equal 200, last_response.status
    response_body = JSON.parse(last_response.body)
    assert_equal 1, response_body['products'].length
    assert_equal 'Test Product', response_body['products'][0]['name']
  end

  def test_unauthorized_access
    get '/products'
    assert_equal 401, last_response.status
    response_body = JSON.parse(last_response.body)
    assert_equal 'Unauthorized', response_body['error']

    get '/products', nil, { 'HTTP_AUTHORIZATION' => "Bearer invalid_token" }
    assert_equal 401, last_response.status
    response_body = JSON.parse(last_response.body)
    assert_equal 'Unauthorized', response_body['error']
  end

  def test_failed_authentication
    post '/auth', { username: 'wrong', password: 'wrong' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    assert_equal 401, last_response.status
    response_body = JSON.parse(last_response.body)
    assert_equal 'Invalid credentials', response_body['error']
  end
end
