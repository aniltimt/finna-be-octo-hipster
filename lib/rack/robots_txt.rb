module Rack
  class RobotsTxt
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      env['PATH_INFO'] == '/robots.txt' ? robots_response(request) : @app.call(env)
    end

    def robots_response(request)
      if request.host =~ /^(.*).freshlimestudio.com/ ||
          request.host == "localhost"
        Rack::Response.new do |res|
          res.header['Content-Type'] = 'text/plain'
          res.write "User-agent: *\n"
          res.write "Disallow: /\n"
        end.finish
      else
        Rack::Response.new do |res|
          res.header['Content-Type'] = 'text/plain'
          res.write "User-agent: *\n"
          res.write "Disallow: /admin/*\n"
          res.write "Disallow: /assets/**\n"
          res.write "Disallow: /admin/**\n"
          res.write "Disallow: /javascripts/**\n"
          res.write "Disallow: /account/**\n"
          res.write "Disallow: /passwords/**\n"
          res.write "Disallow: /users/**\n"
          res.write "Host: #{request.host.gsub("www.", "")}"
        end.finish
      end
    end
  end
end
