require 'json'
require_relative './controllers/auth_controller'
require_relative './controllers/product_controller'

class API
  def initialize
    @auth_controller = AuthController.new
    @product_controller = ProductController.new
  end

  def call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ['POST', '/auth']
      @auth_controller.call(req)
    when ['POST', '/products']
      @product_controller.create(req)
    when ['GET', '/products']
      @product_controller.index(req)
    else
      [404, { 'content-type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
    end
  end

  private

  def handle_create_product(req)
    auth_header = req.get_header('HTTP_AUTHORIZATION')
    token = auth_header&.gsub('Bearer ', '')
    
    if AuthController.valid_token?(token)
      [201, { 'content-type' => 'application/json' }, [{ status: 'created' }.to_json]]
    else
      [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
    end
  end

  def handle_list_products(req)
    auth_header = req.get_header('HTTP_AUTHORIZATION')
    token = auth_header&.gsub('Bearer ', '')
    
    if AuthController.valid_token?(token)
      [200, { 'content-type' => 'application/json' }, [{ products: [] }.to_json]]
    else
      [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
    end
  end
end