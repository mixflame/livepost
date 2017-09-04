struct UserSocket < Amber::WebSockets::ClientSocket

  channel "board_room:*", BoardChannel
  channel "pm_room:*", PmChannel

  def on_connect
    # do some authentication here
    # return true or false, if false the socket will be closed
    true
  end
end