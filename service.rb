require 'webrick'
require 'json'

# Create a simple HTTP server
server = WEBrick::HTTPServer.new(Port: 8000)

# Endpoint to accept JSON array of int32 and return the sum
server.mount_proc '/process' do |req, res|
  if req.request_method == 'POST'
    begin
      data = JSON.parse(req.body)
      if data.is_a?(Array) && data.all? { |i| i.is_a?(Integer) && i.between?(-2**31, 2**31-1) }
        result = data.sum
        res.body = { result: result }.to_json
      else
        res.status = 400
        res.body = { error: 'Invalid input' }.to_json
      end
    rescue JSON::ParserError
      res.status = 400
      res.body = { error: 'Invalid JSON' }.to_json
    end
  else
    res.status = 405
    res.body = { error: 'Method Not Allowed' }.to_json
  end
end

# Start the server
trap 'INT' do server.shutdown end
server.start