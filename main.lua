require "bot"
require "util"

print "Loading bot 0.1"

connection = Connection:new()
connection:activate_socket_debugging()
connection:activate_event_tracing()

success, errors = connection:open("irc.freenode.net", "6667")

connection.events:bind("command:hi", function(e, nick, chatroom, message) 
  local name = parse_nick(nick) 
  e.context:send_privmsg(chatroom, "Hi " .. name) 
end)

if success then
  connection:handshake("sabot_lua_bot")
  connection.events:bind("motd_end", function(e) 
    connection:send_join("##sabot_lua_bot,#voidptr")
  end)
  while connection:receive() do  end
else
  cprint("bold_red", "Couldn't connect: "..errors)
end

