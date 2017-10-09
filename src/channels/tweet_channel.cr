class TweetChannel < Amber::WebSockets::Channel
  def handle_joined
  end

  def handle_message(client_socket, msg)
    rebroadcast!(msg)
  end
end