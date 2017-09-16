// chat.js

var chat_socket, chat_channel

chat_socket = new Amber.Socket("/chat")
chat_socket.connect()
.then(() => {
      this.chat_channel = chat_socket.channel("chat_room:chat")
      this.chat_channel.join()
      this.chat_channel.on('message:new', (msg) => new_msg(msg))
      // notifyMe("") // enable notifications (no msg)
})

function new_msg(msg) {
  $("#messages").append("<li class='message'>" + msg["author"] + "> " + msg["message"] + "</li>")
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