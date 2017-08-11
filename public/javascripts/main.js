var socket, channel, message_channel, home_channel, base64, image, orig_height, orig_width, leftMButtonDown

image = new Image() // to imake image code easier

leftMButtonDown = false // we're not holding left m button down by default

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
  // $.get("/update_socket_count", {board: window.board_name});
});

function connected_socket(socket){
  console.log(socket);
  $("#sockets-connected").html(socket["connected"] + " sockets connected");
  if(socket["this_board"] != null)
    $("#board-connected").html(socket["this_board"] + " connected")
}

function new_board(board){
  $("#board-list").append("<li><a href='/b/" + board['board'] + "'>" + board['board'] + "</a> (<span id='posts-" + board['board'].replace(" ", "-") + "'>0 posts) <a href='/delete_board?name=" + board["board"] + "'>delete</a></li>")
  alert_bottom("<a href='/b/" + board['board'] + "'>" + board['board'] + "</a>" + " was created.")
}

function embed_media() {
  $("div.post > p > img").each(function(i, e) {
    decoded_base64 = LZString.decompressFromEncodedURIComponent($(e).data("src"))
    file_type = decoded_base64.split(",")[0].split(";")[0].split(":")[1]
    media_type = file_type.split("/")[0]
    if(media_type == "image"){
      $(e).attr("src", decoded_base64)
    } else if(media_type == "audio") {
      console.log("audio")
      $(e).replaceWith("<audio controls src='" + decoded_base64 + "'></audio>")
    } else if(media_type == "video") {
      console.log("video")
      $(e).replaceWith("<video controls><source type='" + file_type + "' src='" + decoded_base64 + "'></video>")
    }
  });
}

function new_post(msg){
  console.log(msg);
  $("#post-list").prepend("<div class='post'></div>")
  console.log(msg['image'])
  if(msg['image'] != "" && msg['image'] != "Q" && msg['image'] != "CYQwLiBcA0Q") {
    decoded_base64 = LZString.decompressFromEncodedURIComponent(msg['image']);
    file_type = decoded_base64.split(",")[0].split(";")[0].split(":")[1]
    console.log(file_type + " imported")
    media_type = file_type.split("/")[0]
    if(media_type == "image"){
      $("#post-list > .post").first().append("<p class='image'><img src='" + decoded_base64 + "' /></p>")
    } else if(media_type == "audio") {
      $("#post-list > .post").first().append("<p class='image'><audio controls src='" + decoded_base64 + "' /></p>")
    } else if(media_type == "video") {
      $("#post-list > .post").first().append("<p class='image'><video controls><source type='" + file_type + "' src='" + decoded_base64 + "'></video></p>")
    }
  }
  embed_media();
  $("#post-list > .post").first().append("<div class='comment'><p class='comment-text'>" + msg['message'] + " - " + msg['author'] + " <a href='/delete_post?board_name=" + msg["board"] + "&message=" + msg["message"] +"'>delete</a></p></div>")
  load_embedded_one_post($(".comment-text").first());
  // board screen new message post ding
  if($('textarea').val() != htmlDecode(msg['message'])){
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

function htmlDecode(input){
  var e = document.createElement('div');
  e.innerHTML = input;
  return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
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
  // global ding
  var should_ding = localStorage.getItem("ding");
  if(should_ding == "true" && window.location.pathname == "/"){
    ding = new Audio("/ding.wav")
    ding.play()
  }
}

function alert_bottom(msg) {
  $('.last-posted').show();
  $('.last-posted').html(msg);
  $('.last-posted').fadeOut(10000);
}

$("#create-board").submit(function createBoard(e) {
  e.preventDefault();
  if(!checkBlankPassword()) return;
  $("#board_name").val(stripCombiningMarks($("#board_name").val()))
  $.ajax({url: "/create_board", method: "POST", data: $('#create-board').serialize(), success: function(e){
    // console.log(e);
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    if(e['error'])
      alert(e['error'])
    // $("#captcha_image").attr("src", "/captcha_image?"+ new Date().getTime());
    $("#board_name").val("");
    // $("#captcha_response").val("");
  }, xhrFields: {
     withCredentials: true
  }
  });
})

function reverseString(str) {
    return str.split("").reverse().join("");
}

function drawCanvas() {
  var canvas = document.getElementById('canvas_preview');
  var context = canvas.getContext("2d");
  orig_width = image.width;
  orig_height = image.height;
  context.canvas.width = orig_width;
  context.canvas.height = orig_height;
  $("#image-size").html(context.canvas.width + "x" + context.canvas.height + ": " + (base64.length / 1024).toPrecision(2) + "kb")
  context.drawImage(image, 0, 0);
}

function updateCanvas() {
  if(leftMButtonDown == false) {
    return;
  }
  var canvas = document.getElementById('canvas_preview');
  var context = canvas.getContext("2d");
  var base64_image = new Image();
  base64_image.src = base64;
  base64_image.height = orig_height * parseFloat($("#transform").val());
  base64_image.width = orig_width * parseFloat($("#transform").val());
  context.canvas.width = base64_image.width;
  context.canvas.height = base64_image.height;
  base64_image.onload = function(){
    context.drawImage(base64_image, 0, 0, base64_image.width, base64_image.height);
    var compressed_base64 = canvas.toDataURL("image/jpeg", parseFloat($("#scale").val()));
    var compressed_image = new Image();
    compressed_image.src = compressed_base64
    $("#image-size").html(context.canvas.width + "x" + context.canvas.height + ": " + (compressed_base64.length / 1024).toPrecision(2) + "kb")
    compressed_image.onload = function() {
      context.drawImage(compressed_image, 0, 0);
    }
  };
}

function clearCanvas() {
  var canvas = document.getElementById('canvas_preview');
  var context = canvas.getContext("2d");
  context.clearRect(0, 0, image.width, image.height);
  $("#canvas_preview").remove()
  $("#canvas_holder").append('<canvas id="canvas_preview"></canvas>')
  image = new Image()
}

function checkBlankPassword() {
  if($("#password").val() == ""){
    var useBlankPassword = confirm("Really use a blank password? Only admin is able to delete boards or posts with blank passwords.")
    return useBlankPassword;
  }
}

$("#scale, #transform").mousedown(function(e) {
    if(e.which === 1) leftMButtonDown = true;
});

$(document).mouseup(function(e) {
    if(leftMButtonDown && e.which === 1) leftMButtonDown = false;
});

$("#scale, #transform").mousemove(updateCanvas);
// $("#scale").change(updateCanvas);
// $("#transform").change(updateCanvas);

$("#create-post").submit(function(e) {
  e.preventDefault();
  // if(!checkBlankPassword()) return;
  if($("#canvas_preview").width > 1200 || $("#canvas_preview").height > 900){
    alert("This image is too large. Max: 1200x900");
    return;
  }
  $("#message").val(stripCombiningMarks($("#message").val()))
  $("#author").val(stripCombiningMarks($("#author").val()))
  var base64 = image.src || ""
  if(base64 != "" && file_type.split("/")[0] == "image") {
    var canvas = document.getElementById('canvas_preview');
    var context = canvas.getContext("2d");
    context.canvas.width = orig_width * parseFloat($("#transform").val())
    context.canvas.height = orig_height * parseFloat($("#transform").val())
    context.drawImage(image, 0, 0, context.canvas.width, context.canvas.height);
    if(file_type == "image/png" || file_type == "image/jpeg"){
        base64 = canvas.toDataURL(file_type, parseFloat($("#scale").val()));
    }
  }
  image_string = LZString.compressToEncodedURIComponent(base64)
  if(image_string.length / 1024 > 5000){
    alert("Image is too big: " + parseInt(image_string.length/1024) + " kb Max size: 350kb, any dimensions")
    return;
  }
  if($("textarea#message").val().length > 2000){
    alert("Message is too large: " + $("textarea#message").val().length + " Max: 2000")
    return;
  }
  $.ajax({url: "/create_post", method: "POST", type: "form", data: $('#create-post').serialize() + "&image=" + image_string, success: function(e){
    // console.log(e);
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    if(e['error']) {
      alert(e['error'])
    }
    // $("#captcha_image").attr("src", "/captcha_image?" + new Date().getTime());
    // $("#captcha_response").val("");
    clearCanvas();
  }});
})

$("#author").change(function(e){
  localStorage.setItem("author", $("#author").val())
})

$(document).ready(function(){
  $("#author").val(localStorage.getItem("author") || "anonymous")
  embed_media();
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
      // $.getJSON("https://noembed.com/embed?url=" + url, function(data) { $(e).html($(e).html().replace(url, data["html"])) })
      var already_linked = $(".comment-text > a[href='" + url + "']").length > 0;
      if(!already_linked)
        $(e).html($(e).html().replace(url, "<a target='_blank' href='" + url + "'>" + url + "</a>"))
    })
  });
}

function load_embedded_one_post(comment_text) {
  var matches = comment_text.html().match(/(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9]\.[^\s]{2,})/)
  $(matches).each(function(i, url) {
    // $.getJSON("https://noembed.com/embed?url=" + url, function(data) { comment_text.html(comment_text.html().replace(url, data["html"])) })
    var already_linked = $(".comment-text > a[href='" + url + "']").length > 0;
    if(!already_linked)
      comment_text.html(comment_text.html().replace(url, "<a target='_blank' href='" + url + "'>" + url + "</a>"))
  })
}

function createImage(e) {
  base64 = e.target.result;
  file_type = base64.split(",")[0].split(";")[0].split(":")[1];
  console.log(file_type);
  is_image = file_type.split("/")[0] == "image";
  console.log(is_image);
  type = file_type.split("/")[1];
  console.log(type);
  image = new Image();
  image.src = base64;
  image.onload = function(){
    drawCanvas();
  };
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