var socket, channel, message_channel, home_channel

socket = new Amber.Socket("/chat")
socket.connect()
.then(() => {
      this.channel = socket.channel(`board_room:boards`)
      this.message_channel = socket.channel(`board_room:${window.board_name}`)
      this.home_channel = socket.channel(`board_room:home`)
      this.channel.join()
      this.message_channel.join();
      this.home_channel.join();
      this.channel.on('board:new', (board) => new_board(board))
      this.message_channel.on('post:new', (msg) => new_post(msg))
      this.home_channel.on('post:increment', (board) => increment_posts(board))
    })

function new_board(board){
  $("#board-list").append("<li><a href='/b/" + board['board'] + "'>" + board['board'] + "</a> (<span id='posts-" + board['board'].replace(" ", "-") + "'>0 posts)</li>")
}

function new_post(msg){
  console.log(msg);
  $("#post-list").prepend("<p>" + msg['message'] + " - " + msg['author'] + "</p>")
}

function increment_posts(board) {
  console.log(board)
  var posts_count = parseInt($('#total-posts').html());
  $('#total-posts').html(posts_count + 1);
  var board_posts_count = parseInt($('#posts-' + board['board']).html());
  $('#posts-' + board['board']).html(board_posts_count + 1);
}

$("#create-board").submit(function(e) {
  e.preventDefault();
  $.post("/create_board", $('#create-board').serialize(), function(e){
    // console.log(e);
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    if(!e['error'])
      channel.push('board:new', {board: e['board']})
    else
      alert(e['error'])
  }, "json");
})

$("#create-post").submit(function(e) {
  e.preventDefault();
  $.post("/create_post", $('#create-post').serialize(), function(e){
    // console.log(e);
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    if(!e['error']) {
      message_channel.push('post:new', {board: e['board'], message: e['message'], author: e['author']})
      home_channel.push('post:increment', {board: e['board']})
    } else {
      alert(e['error'])
    }
  }, "json");
})