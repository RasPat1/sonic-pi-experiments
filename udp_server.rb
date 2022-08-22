# http_server.rb
require 'socket'

def start_server
  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/note.rb"))
  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/state.rb"))
  state = State.new(self)
  state.settings.synth_name(:piano)
  state.puts "Booting Server"
  puts "Boooooooting"

  udp = UDPSocket.new                   #=> #<UDPSocket:fd 3>
  # UDPSocket.new(Socket::AF_INET6) #=> #<UDPSocket:fd 4>
  udp.bind("127.0.0.1", 8000)
  server = UDPServer.new 8000

  u1 = UDPSocket.new
  u1.bind("127.0.0.1", 8000)
  u2 = UDPSocket.new
  u2.connect("127.0.0.1", 8000)
  u2.send "uuuu", 0
  p u1.recvfrom(10) #=> ["uuuu", ["AF_INET", 33230, "localhost", "127.0.0.1"]]

  while session = server.accept
   method, path = session.gets.split                    # In this case, method = "POST" and path = "/"
    headers = {}
    while line = session.gets.split(' ', 2)              # Collect HTTP headers
      break if line[0] == ""                            # Blank line means no more headers
      headers[line[0].chop] = line[1].strip             # Hash headers by type
    end
    data = session.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header

    state.puts data
    note = Note.from_json(data, state: state)
    note.play

    session.close
  end
end


u1 = UDPSocket.new
u1.bind("127.0.0.1", 8000)
u2 = UDPSocket.new
u2.connect("127.0.0.1", 8000)
u2.send "uuuu", 0
p u1.recvfrom(6) #=> ["uuuu", ["AF_INET", 33230, "localhost", "127.0.0.1"]]
