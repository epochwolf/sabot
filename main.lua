require "./connection"
require "./util"

print "Loading bot 0.1"

connection = Connection:new(Connections[freenode])

cprint("yellow", "Host: " .. connection.host)
cprint("yellow", "Port: " .. connection.port)

success, errors = connection:open()

if success then
  connection:handshake("epochwolf|bot")
  connection:send_join("##sabot_lua_bot")
  while 1 do connection:receive() end
else
  cprint("boldred", "Couldn't connect: "..errors)
end

