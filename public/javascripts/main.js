var socket, channel, message_channel, home_channel, base64

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
  $("#post-list").prepend("<img src='" + msg['image'] + "' />")
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
  base64 = base64 || "";
  $.post("/create_post", $('#create-post').serialize() + "&image=" + encodeURIComponent(base64), function(e){
    // console.log(e);
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    if(!e['error']) {
      message_channel.push('post:new', {board: e['board'], message: e['message'], author: e['author'], image: e['image']})
      home_channel.push('post:increment', {board: e['board']})
    } else {
      alert(e['error'])
    }
  }, "json");
})

function createImage(e) {
  base64 = e.target.result;
  $("#preview").attr("src", base64);
}

$('#image').change(function(){
  var file = $('#image')[0].files[0];
  var fr = new FileReader();
  fr.onload = createImage;   // onload fires after reading is complete
  fr.readAsDataURL(file);    // begin reading
})