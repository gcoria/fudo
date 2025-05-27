require_relative '../test_helper'
require 'controllers/product_controller'
require 'controllers/auth_controller'
require 'rack/mock'

class ProductControllerTest < Minitest::Test
  def setup
    @controller = ProductController.new
    AuthController.class_variable_set(:@@tokens, {})
    
    @auth_controller = AuthController.new
    env = Rack::MockRequest.env_for(
      '/auth',
      method: 'POST',
      input: { username: 'admin', password: 'secret' }.to_json,
      'CONTENT_TYPE' => 'application/json'
    )
    request = Rack::Request.new(env)
    
    _, _, body = @auth_controller.call(request)
    @token = JSON.parse(body.first)['token']
    
    Product.reset
  end

  def test_create_product_returns_accepted_status
    env = Rack::MockRequest.env_for(
      '/products',
      method: 'POST',
      input: { name: 'Test Product', price: 99.99 }.to_json,
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => "Bearer #{@token}"
    )
    request = Rack::Request.new(env)
    
    status, headers, body = @controller.create(request)
    response_body = JSON.parse(body.first)
    
    assert_equal 202, status, "Should return 202 Accepted status"
    assert_equal 'application/json', headers['content-type']
    assert_equal 'processing', response_body['status']
    assert response_body['job_id'], "Response should contain a job_id"
    
    sleep 3
    
    products = Product.all
    assert_equal 1, products.length
    assert_equal 'Test Product', products.first[:name]
    assert_equal 99.99, products.first[:price]
    assert_equal 'admin', products.first[:created_by]
  end

  def test_unauthorized_product_creation
    env = Rack::MockRequest.env_for(
      '/products',
      method: 'POST',
      input: { name: 'Test Product', price: 99.99 }.to_json,
      'CONTENT_TYPE' => 'application/json'
    )
    request = Rack::Request.new(env)
    
    status, headers, body = @controller.create(request)
    response_body = JSON.parse(body.first)
    
    assert_equal 401, status
    assert_equal 'application/json', headers['content-type']
    assert_equal 'Unauthorized', response_body['error']
    
    env = Rack::MockRequest.env_for(
      '/products',
      method: 'POST',
      input: { name: 'Test Product', price: 99.99 }.to_json,
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => "Bearer invalid_token"
    )
    request = Rack::Request.new(env)
    
    status, headers, body = @controller.create(request)
    response_body = JSON.parse(body.first)
    
    assert_equal 401, status
    assert_equal 'Unauthorized', response_body['error']
  end

  def test_list_products
    product = Product.new(
      name: 'Pre-existing Product',
      price: 199.99,
      created_by: 'admin'
    )
    product.save
    
    env = Rack::MockRequest.env_for(
      '/products',
      method: 'GET',
      'HTTP_AUTHORIZATION' => "Bearer #{@token}"
    )
    request = Rack::Request.new(env)
    
    status, headers, body = @controller.index(request)
    response_body = JSON.parse(body.first)
    
    assert_equal 200, status
    assert_equal 'application/json', headers['content-type']
    assert_equal 1, response_body['products'].length
    assert_equal 'Pre-existing Product', response_body['products'][0]['name']
  end
end
