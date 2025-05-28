# lib/middleware/gzip_middleware.rb
require 'zlib'
require 'stringio'

class GzipMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    request = Rack::Request.new(env)
    if request.env['HTTP_ACCEPT_ENCODING']&.include?('gzip')
      compressed = gzip(body.join)

      headers['content-encoding'] = 'gzip'
      headers['content-length'] = compressed.bytesize.to_s

      body = [compressed]
    end

    [status, headers, body]
  end

  private

  def gzip(string)
    out = StringIO.new
    gz = Zlib::GzipWriter.new(out)
    gz.write(string)
    gz.close
    out.string
  end
end