require 'json'

class BaseController
  def json_response(status, body)
    [status, {'content-type' => 'application/json'}, [body.to_json]]
  end

  def error_response(status, message)
    json_response(status, {error: message})
  end

  def success_response(status, data)
    json_response(status, data)
  end

  def authenticate(req)
    auth_header = req.get_header('HTTP_AUTHORIZATION')
    token = auth_header&.gsub('Bearer ', '')
    
    unless AuthController.valid_token?(token)
      return nil
    end
    
    token
  end

  def parse_json(req)
    begin
      JSON.parse(req.body.read)
    rescue JSON::ParserError
      nil
    end
  end
end 