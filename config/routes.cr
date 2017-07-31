Amber::Server.instance.config do |app|
  pipeline :web do
    # Plug is the method to use connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    # plug Amber::Pipe::Params.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::Flash.new
    # plug Amber::Pipe::CSRF.new # need help re-enabling this, see #9
  end

  # All static content will run these transformations
  pipeline :static do
    plug HTTP::StaticFileHandler.new("./public")
    plug HTTP::CompressHandler.new
  end

  socket_endpoint "/chat", UserSocket

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
    get "/update_socket_count", BoardController, :update_socket_count
  end

  routes :static do
    get "/*", StaticController, :index
  end
end
