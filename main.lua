require "bot"
require "util"

print "Loading bot 0.1"

bot = Bot:new()
connection = bot.connection
connection:activate_socket_debugging()
--connection:activate_event_tracing()

success, errors = connection:open("irc.freenode.net", "6667")

if success then
  connection:handshake("epochwolf|bot")
  connection:join("##sabot_lua_bot")
  while 1 do connection:receive() end
else
  cprint("boldred", "Couldn't connect: "..errors)
end

