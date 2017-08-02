var socket, channel, message_channel, home_channel, base64

socket = new Amber.Socket("/chat")
socket.connect()
.then(() => {
      this.channel = socket.channel(`board_room:boards`)
      this.message_channel = socket.channel(`board_room:${window.board_name}`)
      this.home_channel = socket.channel(`board_room:home`)
      this.connected_channel = socket.channel(`board_room:connected`)
      this.channel.join()
      this.message_channel.join();
      this.home_channel.join();
      this.connected_channel.join();
      this.channel.on('board:new', (board) => new_board(board))
      this.message_channel.on('post:new', (msg) => new_post(msg))
      this.home_channel.on('post:increment', (board) => increment_posts(board))
      this.connected_channel.on('socket:connected', (socket) => connected_socket(socket))
      this.connected_channel.push('socket:connected', {board: window.board_name}) // i connected
      notifyMe("") // enable notifications (no msg)
    })

$(window).on("beforeunload", function (e) {
  this.socket.ws.close();
  $.get("/update_socket_count", {board: window.board_name});
});

function connected_socket(socket){
  console.log(socket);
  $("#sockets-connected").html(socket["connected"] + " sockets connected");
  $("#board-connected").html(socket["this_board"] + " connected")
}

function new_board(board){
  $("#board-list").append("<li><a href='/b/" + board['board'] + "'>" + board['board'] + "</a> (<span id='posts-" + board['board'].replace(" ", "-") + "'>0 posts) <a href='/delete_board?name=" + board["board"] + "'>delete</a></li>")
  alert_bottom("<a href='/b/" + board['board'] + "'>" + board['board'] + "</a>" + " was created.")
}

function new_post(msg){
  console.log(msg);
  $("#post-list").prepend("<div class='post'></div>")
  if(msg['image'] != "" && msg['image'] != "Q" && msg['image'] != "CYQwLiBcA0Q") {
    $("#post-list > .post").first().append("<p class='image'><img src='" + LZString.decompressFromEncodedURIComponent(msg['image']) + "' /></p>")
  }
  $("#post-list > .post").first().append("<div class='comment'><p class='comment-text'>" + msg['message'] + " - " + msg['author'] + " <a href='/delete_post?board_name=" + msg["board"] + "&message=" + msg["message"] +"'>delete</a></p></div>")
  load_embedded_one_post($(".comment-text").first());
  // board screen new message post ding
  if($('textarea').val() != msg['message']){
    var should_ding = localStorage.getItem("ding");
    if(should_ding == "true"){
      ding = new Audio("/ding.wav")
      ding.play()
    }
    notifyMe(msg['message'] + " - " + msg['author'])
  } else {
    $('textarea').val('');
    base64 = '';
    $("#preview").attr("src", base64);
    $("#image").val('');
  }
}

function increment_posts(board) {
  console.log(board)
  var posts_count = parseInt($('#total-posts').html());
  $('#total-posts').html(posts_count + 1);
  var board_posts_count = parseInt($('#posts-' + board['board']).html());
  $('.post-count').css("font-weight", "");
  $('#li-' + board['board']).css("font-weight", "bold");
  $('#posts-' + board['board']).html(board_posts_count + 1);
  alert_bottom(board['author'] + " posted in <a href='/b/" + board['board'].replace(/-/g, " ") + "'>" + board['board'].replace(/-/g, " ") + "</a>")
  if($('#last-posted').length > 0){
    console.log(board['board'])
    $('#last-posted').html("<a href='/b/" + board['board'] + "'>" + board['board'] + "</a>");
  }
}

function alert_bottom(msg) {
  $('.last-posted').show();
  $('.last-posted').html(msg);
  $('.last-posted').fadeOut(10000);
}

$("#create-board").submit(function(e) {
  e.preventDefault();
  $("#board_name").val(stripCombiningMarks($("#board_name").val()))
  $.post("/create_board", $('#create-board').serialize(), function(e){
    // console.log(e);
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    if(e['error'])
      alert(e['error'])
  }, "json");
})

function reverseString(str) {
    return str.split("").reverse().join("");
}

$("#create-post").submit(function(e) {
  e.preventDefault();
  $("#message").val(stripCombiningMarks($("#message").val()))
  $("#author").val(stripCombiningMarks($("#author").val()))
  var base64 = $("#preview").attr("src") || ""
  var canvas = document.createElement('canvas');
  var context = canvas.getContext("2d");
  context.canvas.width = $("#preview").width()
  context.canvas.height = $("#preview").height()
  context.drawImage(document.getElementById("preview"), 0, 0);
  base64 = canvas.toDataURL("image/jpeg", parseFloat($("#scale").val()));
  image = LZString.compressToEncodedURIComponent(base64)
  if(image.length / 1024 > 350){
    alert("Image is too big: " + parseInt(image.length/1024) + " kb Max size: 350kb, any dimensions")
    return;
  }
  if($("textarea#message").val().length > 2000){
    alert("Message is too large: " + $("textarea#message").val().length + " Max: 2000")
    return;
  }
  $.post("/create_post", $('#create-post').serialize() + "&image=" + image, function(e){
    // console.log(e);
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    if(e['error']) {
      alert(e['error'])
    }
  }, "json");
})

$("#author").change(function(e){
  localStorage.setItem("author", $("#author").val())
})

$(document).ready(function(){
  $("#author").val(localStorage.getItem("author") || "anonymous")
  $("div.post > p > img").each(function(i, e) { $(e).attr("src", LZString.decompressFromEncodedURIComponent($(e).data("src")))});
  var ding = localStorage.getItem("ding");
  if(ding == null) {
    ding = true;
    localStorage.setItem("ding", ding);
  }
  $("#ding").prop("checked", ding);
  $('.comment-text').each(function(i,e) {
    $(e).html(stripCombiningMarks($(e).html()))
  });
  $('.board-link').each(function(i,e) {
    $(e).html(stripCombiningMarks($(e).html()))
  });
  $('.board-name').each(function(i,e) {
    $(e).html(stripCombiningMarks($(e).html()))
  });
  load_embedded_data();
})

function load_embedded_data(){
  $(".comment-text").each(function(i, e){
    var matches = $(e).html().match(/(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9]\.[^\s]{2,})/)
    $(matches).each(function(i, url) {
      $.getJSON("https://noembed.com/embed?url=" + url, function(data) { $(e).html($(e).html().replace(url, data["html"])) })
    })
  });
}

function load_embedded_one_post(comment_text) {
  var matches = comment_text.html().match(/(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9]\.[^\s]{2,})/)
  $(matches).each(function(i, url) {
    $.getJSON("https://noembed.com/embed?url=" + url, function(data) { comment_text.html(comment_text.html().replace(url, data["html"])) })
  })
}

function createImage(e) {
  var base64 = e.target.result;
  $("#preview").attr("src", base64);
}

$('#image').change(function(){
  var file = $('#image')[0].files[0];
  var fr = new FileReader();
  fr.onload = createImage;   // onload fires after reading is complete
  fr.readAsDataURL(file);    // begin reading
})

$("#ding").change(function(){
  localStorage.setItem("ding", $("#ding").is(":checked"));
})

function notifyMe(msg) {
  // Let's check if the browser supports notifications
  if (!("Notification" in window)) {
    console.log("This browser does not support desktop notification");
  }

  // Let's check whether notification permissions have already been granted
  else if (Notification.permission === "granted" && msg != "") {
    // If it's okay let's create a notification
    var notification = new Notification(msg);
  }

  // Otherwise, we need to ask the user for permission
  else if (Notification.permission !== "denied") {
    Notification.requestPermission(function (permission) {
      // If the user accepts, let's create a notification
      if (permission === "granted" && msg != "") {
        var notification = new Notification(msg);
      }
    });
  }

  // At last, if the user has denied notifications, and you
  // want to be respectful there is no need to bother them any more.
}