local Bot = require "lib/bot"
local config = require "config"

local bot = Bot:new(config)
bot:enable_debugging()
local success, errors = bot:connect()
if success then
  bot:run()
else
  print(errors)
end

-- connection = Connection:new()
-- connection:activate_socket_debugging()
-- connection:activate_event_tracing()
-- 
-- success, errors = connection:open("irc.freenode.net", "6667")
-- 
-- connection.events:bind("command:commands|command:help", function(e, nick, chatroom, message) 
--   e.context:send_privmsg(chatroom, "Available commands: bye, hi, quit") 
-- end)
-- 
-- connection.events:bind("command:hi", function(e, nick, chatroom, message) 
--   local name = parse_nick(nick) 
--   if message then
--     pos = message:find(" ")
--     if pos then 
--       name = message:sub(1, pos)
--     else
--       name = message
--     end
--   end
--   e.context:send_privmsg(chatroom, "Hi " .. name) 
-- end)
-- 
-- connection.events:bind("command:bye", function(e, nick, chatroom, message) 
--   local name = parse_nick(nick) 
--   if message then
--     pos = message:find(" ")
--     if pos then 
--       name = message:sub(1, pos)
--     else
--       name = message
--     end
--   end
--   e.context:send_privmsg(chatroom, "Bye " .. name) 
-- end)
-- 
-- 
-- connection.events:bind("command:join", function(e, nick, chatroom, message) 
--   local name = parse_nick(nick) 
--   if name == "epochwolf" or name:match("^epochwolf|.*") then
--     e.context:send_join(message)
--   else
--     e.context:send_privmsg(chatroom, "No")
--   end
-- end)
-- 
-- 
-- connection.events:bind("command:part", function(e, nick, chatroom, message) 
--   local name = parse_nick(nick) 
--   if name == "epochwolf" or name:match("^epochwolf|.*") then
--     e.context:send_part(message)
--   else
--     e.context:send_privmsg(chatroom, "No")
--   end
-- end)
-- 
-- connection.events:bind("command:quit", function(e, nick, chatroom, message) 
--   local name = parse_nick(nick) 
--   if name == "epochwolf" or name:match("^epochwolf|.*") then
--     e.context:send_privmsg(chatroom, "okay :(")
--     e.context:send_quit(name .. " asked me to leave")
--   else
--     e.context:send_privmsg(chatroom, "No")
--   end
-- end)
-- 
-- if success then
--   connection:handshake("sabot_lua_bot")
--   connection.events:bind("motd_end", function(e) 
--     connection:send_join("##sabot_lua_bot")
--   end)
--   while connection:receive() do  end
-- else
--   cprint("bold_red", "Couldn't connect: "..errors)
-- end

