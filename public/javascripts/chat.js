// chat.js

var chat_socket, chat_channel

chat_socket = new Amber.Socket("/chat")
chat_socket.connect()
.then(() => {
      this.chat_channel = chat_socket.channel("chat_room:chat")
      this.chat_channel.join()
      this.chat_channel.on('message:new', (msg) => new_msg(msg))
      this.chat_channel.on('handle:join', (handle) => handle_join(handle))
      this.chat_channel.on('handle:leave', (handle) => handle_leave(handle))
      this.chat_channel.push('handle:join', {handle: window.handle})
      // notifyMe("") // enable notifications (no msg)
})

function new_msg(msg) {
  if(msg["author"] == "")
    msg["author"] = "anonymous"
  $("#messages").append("<li class='message'>" + msg["author"] + " > " + msg["message"] + "</li>")
  replace_links($(".message").last());
  replace_emojis($(".message").last());
  $('#messages').scrollTop($('#messages')[0].scrollHeight);
}

function handle_join(handle) {
  var already_exists;
  if(handle["handle"] == "")
    handle["handle"] = "anonymous"
  $("#users").each(function(i, e){
    if($(e).html() == handle["handle"] && $(e).html != "anonymous")
      already_exists = true;
  })
  if(already_exists != true)
    $("#users").append("<li class='user'>" + handle["handle"] + "</li>")
}

function handle_leave(handle) {
  if(handle["handle"] == "")
    handle["handle"] = "anonymous"
  $("#users li").each(function(i, el) { if($(el).html() == handle["handle"]) { $(el).remove(); return false; } })
}

$("#send-message").submit(function(e) {
  e.preventDefault();
  var msg = $("#message").val();
  $.ajax({url: "/send_message", method: "POST", data: $('#send-message').serialize(), success: function(e){
    $("input[name*=_csrf]").replaceWith(e['csrf']);
    $("#message").val("")
  }, xhrFields: {
     withCredentials: true
  }
  });
});

$(document).ready(function(){
  $(".message").each(function(i, e){
    replace_links($(e));
    replace_emojis($(e));
  })
})

function replace_links(message_text) {
  var matches = message_text.html().match(/(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9]\.[^\s]{2,})/)
  $(matches).each(function(i, url) {
    var already_linked = $(".message > a[href='" + url + "']").length > 0;
    if(!already_linked)
      message_text.html(message_text.html().replace(url, "<a target='_blank' href='" + url + "'>" + url + "</a>"))
  })
}

function unload(e) {
  this.chat_channel.push('handle:leave', {handle: window.handle})
}

window.onbeforeunload = unload;
window.addEventListener("beforeunload", unload);