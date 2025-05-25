require_relative '../test_helper'
require 'middleware/static_file_server'

class StaticFileServerTest < Minitest::Test
  include TestHelper

  def setup
    setup_test_files
    @app = lambda { |env| [404, { 'content-type' => 'text/plain' }, ['Not Found']] }
    @static_server = StaticFileServer.new(@app, @temp_dir)
    
    @static_server.instance_variable_set(:@cache_rules, {
      '/authors' => 'public, max-age=86400',
      '/openapi.yaml' => 'no-store'
    })
  end

  def teardown
    teardown_test_files
  end

  def test_serve_authors_file
    get '/authors'
    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response.headers['content-type']
    assert_equal 'public, max-age=86400', last_response.headers['cache-control']
    assert_equal 'Test Authors', last_response.body
  end

  def test_serve_openapi_file
    get '/openapi.yaml'
    assert_equal 200, last_response.status
    assert_equal 'text/yaml', last_response.headers['content-type']
    assert_equal 'no-store', last_response.headers['cache-control']
    assert_match(/openapi: 3\.0\.0/, last_response.body)
  end

  def test_non_existing_file_returns_404
    get '/non-existent-file'
    assert_equal 404, last_response.status
  end

  def test_path_traversal_is_prevented
    get '/../README.md'
    assert_equal 404, last_response.status
  end

  def test_passes_through_to_app_for_non_static_paths
    get '/api/resource'
    assert_equal 404, last_response.status
    assert_equal 'Not Found', last_response.body
  end

  def test_public_directory_not_directly_accessible
    get '/public/authors'
    assert_equal 404, last_response.status
  end

  private

  def app
    @static_server
  end
end 