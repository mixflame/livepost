Amber::Server.instance.config do |app|
  pipeline :web do
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::Flash.new
    plug Amber::Pipe::CSRF.new # bug in amber right now
  end

  # All static content will run these transformations
  pipeline :static do
    plug HTTP::StaticFileHandler.new("./public")
    plug HTTP::CompressHandler.new
  end

  pipeline :api do
    plug Amber::Pipe::Logger.new
  end

  socket_endpoint "/chat", UserSocket

  routes :api do
    get "/captcha_image", StaticController, :captcha_image
    get "/update_socket_count", BoardController, :update_socket_count
  end

  routes :web do
    get "/b/:slug", StaticController, :slug
  end

  routes :web do
    get "/", HomeController, :index
    post "/create_board", BoardController, :create_board
    post "/create_post", BoardController, :create_post
    get "/delete_board", BoardController, :delete_board
    post "/remove_board", BoardController, :remove_board
    get "/delete_post", BoardController, :delete_post
    post "/remove_post", BoardController, :remove_post
    get "/ban_hash", BoardController, :ban_hash
    post "/ban_hash", BoardController, :commit_ban_hash
    get "/unban_hash", BoardController, :unban_hash
    post "/unban_hash", BoardController, :commit_unban_hash
    post "/change_topic", BoardController, :change_topic
  end

  routes :static do
    get "/*", StaticController, :index
  end
end
