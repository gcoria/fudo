require 'json'

class API
  def call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ['POST', '/auth']
      handle_auth(req)
    when ['POST', '/products']
      handle_create_product(req)
    when ['GET', '/products']
      handle_list_products(req)
    else
      [404, { 'content-type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
    end
  end

  private

  def handle_auth(req)
    [200, { 'content-type' => 'application/json' }, [{ status: 'ok' }.to_json]]
  end

  def handle_create_product(req)
    [201, { 'content-type' => 'application/json' }, [{ status: 'created' }.to_json]]
  end

  def handle_list_products(req)
    [200, { 'content-type' => 'application/json' }, [{ products: [] }.to_json]]
  end
end