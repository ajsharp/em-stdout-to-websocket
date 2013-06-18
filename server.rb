require 'rubygems'
require 'eventmachine'
require 'em-websocket'

module ProcessHandler
  def post_init
    @channel = EM::Channel.new
  end

  def channel
    @channel
  end

  def receive_data(data)
    channel.push(data)
    puts "received data=#{data.inspect}"
  end
end

EM.kqueue = true

EM.run do
  EM::WebSocket.run(host: '0.0.0.0', port: 3457) do |socket|
    EM.popen('ruby test.rb', ProcessHandler) do |handler|
      socket.onopen do
        handler.channel.subscribe do |msg|
          puts "sending: #{msg}"
          socket.send msg
        end
      end
    end
  end
end