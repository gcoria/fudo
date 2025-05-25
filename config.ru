require_relative './app/api'
require_relative './app/middleware/static_file_server'
require_relative './app/middleware/gzip_middleware'

use StaticFileServer
use GzipMiddleware

run API.new