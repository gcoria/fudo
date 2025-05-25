require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

$LOAD_PATH.unshift File.expand_path('../app', __dir__)

module TestHelper
  include Rack::Test::Methods

  def setup_test_files
    @temp_dir = File.expand_path('../tmp/test', __dir__)
    FileUtils.mkdir_p(@temp_dir)
    
    @authors_file = File.join(@temp_dir, 'authors')
    File.write(@authors_file, 'Test Authors')
    
    @openapi_file = File.join(@temp_dir, 'openapi.yaml')
    File.write(@openapi_file, "openapi: 3.0.0\ninfo:\n  title: Test API\n  version: 1.0.0")
  end

  def teardown_test_files
    FileUtils.rm_rf(@temp_dir) if @temp_dir && File.exist?(@temp_dir)
  end
end 