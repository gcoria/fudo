require 'json'
require_relative './controllers/auth_controller'
require_relative './controllers/product_controller'
require_relative './lib/router'

class API
  def initialize
    @auth_controller = AuthController.new
    @product_controller = ProductController.new
    setup_router
  end

  def call(env)
    req = Rack::Request.new(env)
    @router.route(req)
  end

  private

  def setup_router
    @router = Router.new
    @router.add('POST', '/auth', @auth_controller, :call)
    @router.add('POST', '/products', @product_controller, :create)
    @router.add('GET', '/products', @product_controller, :index)
  end
end