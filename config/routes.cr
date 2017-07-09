Amber::Server.instance.config do |app|
  pipeline :web do
    # Plug is the method to use connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    # plug Amber::Pipe::Params.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Flash.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::CSRF.new
  end

  # All static content will run these transformations
  pipeline :static do
    plug HTTP::StaticFileHandler.new("./public")
    plug HTTP::CompressHandler.new
  end

  socket_endpoint "/chat", UserSocket

  routes :static do
    get "/*", StaticController, :index
  end

  routes :web do
    get "/b/:slug", StaticController, :slug
  end

  routes :web do
    get "/", HomeController, :index
    post "/create_board", BoardController, :create_board
    post "/create_post", BoardController, :create_post
  end
end
