require_relative '../test_helper'
require 'middleware/gzip_middleware'
require 'rack/mock'
require 'zlib'

class GzipMiddlewareTest < Minitest::Test
  def setup
    # Create a simple app that returns JSON
    @app = lambda do |env|
      [200, {'Content-Type' => 'application/json'}, ['{"message":"Hello, World!"}']]
    end
    
    @middleware = GzipMiddleware.new(@app)
  end

  def test_compresses_when_requested
    # Create a request with Accept-Encoding: gzip
    env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_ENCODING' => 'gzip')
    
    # Call the middleware
    status, headers, body = @middleware.call(env)
    
    # Verify the response is compressed
    assert_equal 200, status
    assert_equal 'gzip', headers['Content-Encoding']
    assert headers.key?('Content-Length'), "Response should have Content-Length header"
    
    # Decompress and verify content
    io = StringIO.new(body.first)
    gz = Zlib::GzipReader.new(io)
    decompressed = gz.read
    gz.close
    
    assert_equal '{"message":"Hello, World!"}', decompressed
  end

  def test_does_not_compress_when_not_requested
    # Create a request without Accept-Encoding
    env = Rack::MockRequest.env_for('/')
    
    # Call the middleware
    status, headers, body = @middleware.call(env)
    
    # Verify the response is not compressed
    assert_equal 200, status
    refute headers.key?('Content-Encoding')
    assert_equal '{"message":"Hello, World!"}', body.first
  end

  def test_compresses_any_content_type
    # Create an app that returns HTML
    app = lambda do |env|
      [200, {'Content-Type' => 'text/html'}, ['<html><body>Hello</body></html>']]
    end
    
    middleware = GzipMiddleware.new(app)
    
    # Create a request with Accept-Encoding: gzip
    env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_ENCODING' => 'gzip')
    
    # Call the middleware
    status, headers, body = middleware.call(env)
    
    # Verify the response is compressed regardless of content type
    assert_equal 200, status
    assert_equal 'gzip', headers['Content-Encoding']
    
    # Decompress and verify content
    io = StringIO.new(body.first)
    gz = Zlib::GzipReader.new(io)
    decompressed = gz.read
    gz.close
    
    assert_equal '<html><body>Hello</body></html>', decompressed
  end

  def test_handles_multiple_body_items
    # Create an app that returns multiple body items
    app = lambda do |env|
      [200, {'Content-Type' => 'text/plain'}, ['Hello, ', 'World!']]
    end
    
    middleware = GzipMiddleware.new(app)
    
    # Create a request with Accept-Encoding: gzip
    env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_ENCODING' => 'gzip')
    
    # Call the middleware
    status, headers, body = middleware.call(env)
    
    # Verify the response is compressed
    assert_equal 200, status
    assert_equal 'gzip', headers['Content-Encoding']
    
    # Decompress and verify content
    io = StringIO.new(body.first)
    gz = Zlib::GzipReader.new(io)
    decompressed = gz.read
    gz.close
    
    assert_equal 'Hello, World!', decompressed
  end
end 