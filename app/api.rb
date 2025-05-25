require 'json'
require_relative './controllers/auth_controller'

class API
  def call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ['POST', '/auth']
      auth_controller = AuthController.new
      auth_controller.call(req)
    when ['POST', '/products']
      handle_create_product(req)
    when ['GET', '/products']
      handle_list_products(req)
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