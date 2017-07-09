var socket, channel, message_channel

socket = new Amber.Socket("/chat")
socket.connect()
.then(() => {
      this.channel = socket.channel(`board_room:boards`)
      this.message_channel = socket.channel(`board_room:${window.board_name}`)
      this.channel.join()
      this.message_channel.join();
      this.channel.on('board:new', (board) => new_board(board))
      this.message_channel.on('post:new', (msg) => new_post(msg))
    })

function new_board(board){
  $("#board-list").append("<li>" + board['board'] + "</li>")
}

function new_post(msg){
  console.log(msg);
  $("#post-list").append("<p>" + msg['message'] + " - " + msg['author'] + "</p>")
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
    if(!e['error'])
      message_channel.push('post:new', {message: e['message'], author: e['author']})
    else
      alert(e['error'])
  }, "json");
})