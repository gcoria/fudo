require 'json'
require 'securerandom'
require_relative '../services/job_queue'
require_relative 'base_controller'
require_relative '../models/product'

class ProductController < BaseController
  @@job_queue = JobQueue.new

  def self.all_products
    Product.all
  end

  def create(req)
    token = authenticate(req)
    return error_response(401, 'Unauthorized') unless token
    
    data = parse_json(req)
    return error_response(400, 'Invalid JSON') unless data
    
    return error_response(400, 'Name is required') unless data['name']
    return error_response(400, 'Price is required') unless data['price']
    
    job_id = SecureRandom.uuid

    @@job_queue.enqueue do
      username = AuthController.username_for(token)
      
      product = Product.new(
        name: data['name'],
        price: data['price'],
        description: data['description'],
        created_by: username
      )
      
      sleep 2 

      product.save
    end

    success_response(202, {
      status: 'processing',
      message: 'Product creation in progress',
      job_id: job_id
    })
  end

  def index(req)
    token = authenticate(req)
    return error_response(401, 'Unauthorized') unless token
    
    success_response(200, {products: Product.all})
  end
end

