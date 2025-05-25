class StaticFileServer
    attr_reader :cache_rules
    
    def initialize(app, root = 'public')
      @app = app
      @root = root
      @cache_rules = {
        '/authors' => 'public, max-age=86400',
        '/openapi.yaml' => 'no-store'
      }
    end
  
    def call(env)
      req = Rack::Request.new(env)
      path_info = req.path_info
  
      case path_info
      when '/authors', '/openapi.yaml'
        file_path = File.join(@root, path_info.sub(/^\//, ''))
        secure_path = File.expand_path(file_path)
        
        root_path = File.expand_path(@root)
        
        if secure_path.start_with?(root_path) && File.exist?(secure_path)
          serve_file(secure_path, {
            'cache-control' => @cache_rules[path_info]
          })
        else
          [404, { 'content-type' => 'text/plain' }, ['Not Found']]
        end
      else
        @app.call(env)
      end
    end
  
    private
  
    def serve_file(path, headers = {})
      if File.exist?(path)
        [
          200,
          { 'content-type' => mime_type(path) }.merge(headers),
          [File.read(path)]
        ]
      else
        [404, { 'content-type' => 'text/plain' }, ['Not Found']]
      end
    end
  
    def mime_type(path)
      ext = File.extname(path)
      Rack::Mime.mime_type(ext, 'text/plain')
    end
end

