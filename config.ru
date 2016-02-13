require 'websocket-eventmachine-client'

LIVETIMING_WEBSOCKET_URI = 'ws://livetiming.sms-timing.com:10001'
IDS = {
  pulkovo: 586,
  drive: 686,
  narvskaya: 786
}

EventMachine.run do
  ws = WebSocket::EventMachine::Client.connect(uri: LIVETIMING_WEBSOCKET_URI)

  ws.onopen do
    ws.send "START Karting@#{IDS[:pulkovo]}"
  end

  ws.onmessage do |msg, type|
    puts "Type: #{type}"
    puts "Message: #{msg}"
  end

  ws.onclose do |code, reason|
    puts "Close code: #{code}"
    puts "Close reason: #{reason}"
  end

  ws.onerror do |error|
    puts "Error occured: #{error}"
  end

  ws.onping do |message|
    puts "Ping received: #{message}"
  end

  ws.onpong do |message|
    puts "Pong received: #{message}"
  end

  EventMachine.next_tick do
    ws.send 'Hello Server!'
  end
end