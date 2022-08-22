require 'webrick'

def start_server
  server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: "/var/www/app/public")

  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/note.rb"))

  server.mount_proc '/' do |req, res|
    json_content = req.body
    note = Note.new(pitch: 60, velocity: 10, time: 1, current_bpm: 60)
    note.play
    # Matybe strip slashes...
    # puts JSON.parse(req.body)
  end

  server.start
end

