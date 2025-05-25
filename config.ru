require_relative './app/api'
require_relative './app/middleware/static_file_server'

use StaticFileServer
run API.new