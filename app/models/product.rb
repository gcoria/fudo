require 'securerandom'

class Product
  attr_reader :id, :name, :price, :description, :created_by, :created_at
  
  @@products = []
  
  def initialize(attributes)
    @id = SecureRandom.uuid
    @name = attributes[:name]
    @price = attributes[:price]
    @description = attributes[:description]
    @created_by = attributes[:created_by]
    @created_at = Time.now.iso8601
  end
  
  def save
    @@products << self
    true
  end
  
  def to_hash
    {
      id: @id,
      name: @name,
      price: @price,
      description: @description,
      created_by: @created_by,
      created_at: @created_at
    }
  end
  
  def self.all
    @@products.map(&:to_hash)
  end
  
  def self.reset
    @@products = []
  end
end 