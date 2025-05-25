require 'json'
require_relative '../services/job_queue'

class ProductController
  @@products = []
  @@job_queue = JobQueue.new

  def self.all_products
    @@products
  end

  def create(req)
    auth_header = req.get_header('HTTP_AUTHORIZATION')
    token = auth_header&.gsub('Bearer ', '')
    
    unless AuthController.valid_token?(token)
      return [401, {'content-type' => 'application/json'}, [{error: 'Unauthorized'}.to_json]]
    end

    begin
      data = JSON.parse(req.body.read)
    rescue JSON::ParserError
      return [400, {'content-type' => 'application/json'}, [{error: 'Invalid JSON'}.to_json]]
    end

    job_id = SecureRandom.uuid

    @@job_queue.enqueue do
      username = AuthController.username_for(token)
      product = {
        id: SecureRandom.uuid,
        name: data['name'],
        price: data['price'],
        description: data['description'],
        created_by: username,
        created_at: Time.now.iso8601
      }
      
      sleep 2
      
      @@products << product
    end

    [202, {'content-type' => 'application/json'}, [{
      status: 'processing',
      message: 'Product creation in progress',
      job_id: job_id
    }.to_json]]
  end

  def index(req)
    auth_header = req.get_header('HTTP_AUTHORIZATION')
    token = auth_header&.gsub('Bearer ', '')
    
    unless AuthController.valid_token?(token)
      return [401, {'content-type' => 'application/json'}, [{error: 'Unauthorized'}.to_json]]
    end

    [200, {'content-type' => 'application/json'}, [{products: @@products}.to_json]]
  end
end

