require "./connection"
require "./util"

print "Loading bot 0.1"

connection = Connection:new()
connection:activate_socket_debugging()
--connection:activate_event_tracing()

success, errors = connection:open()

if success then
  connection:handshake("epochwolf|bot")
  connection:join("##sabot_lua_bot")
  while 1 do connection:receive() end
else
  cprint("boldred", "Couldn't connect: "..errors)
end

