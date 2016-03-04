require 'faye/websocket'
require 'eventmachine'
require 'webrick'

# https://devcenter.heroku.com/articles/logging
$stdout.sync = true

LIVETIMING_WEBSOCKET_URI = 'ws://livetiming.sms-timing.com:10001'
IDS = {
  pulkovo: 586,
  drive: 686,
  narvskaya: 786
}

place = :pulkovo
last_message_was_at = 0

puts 'Initiate evenmachine'

begin
  Thread.new do
    EventMachine.run do
      ws = Faye::WebSocket::Client.new(LIVETIMING_WEBSOCKET_URI)

      EventMachine.add_periodic_timer(10) do
        puts "#{place}: Checking if ping needed"

        if Time.zone.now > last_message_was_at + 180
          puts "#{IDS[place]}: Pinging"
          ws.ping('Au!')
        end
      end

      ws.on :open do
        ws.send "START Karting@#{IDS[place]}"
        last_message_was_at = Time.zone.now
      end

      ws.on :message do |event|
        puts "Type: #{event.type}"
        puts "Message: #{event.msg}"
        last_message_was_at = Time.zone.now
      end

      ws.on :close do |event|
        puts "#{place}: close"
        raise "Disconnected with status code: #{event.code}, reason: #{event.reason}"
      end

      ws.on :error do |event|
        puts "#{place}: error"
        raise "Disconnected by error with status code: #{event.code}, reason: #{event.reason}"
      end

      ws.on :pong do |event|
        puts "#{place}: Pong received: #{event.data}"
        last_message_was_at = Time.zone.now
      end
    end
  end
  raise 'Thread complite'
rescue => e
  puts e
  sleep(60)
  retry
end

puts 'Event machine init has finished'

WEBrick::HTTPServer.new(Port: ENV['PORT']).start
