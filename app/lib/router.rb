require 'json'

class Router
  def initialize
    @routes = {}
  end

  def add(method, path, controller, action)
    @routes[[method.upcase, path]] = { controller: controller, action: action }
  end

  def route(request)
    route_key = [request.request_method, request.path_info]
    route = @routes[route_key]

    if route
      controller = route[:controller]
      action = route[:action]
      controller.send(action, request)
    else
      not_found_response
    end
  end

  private

  def not_found_response
    [404, { 'content-type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
  end
end 