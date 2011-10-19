--[[
Class to manage an IRC Connection
--]]
require "luarocks.loader"
local socket = require "socket"
require "util"
require "events"

Connection = {}
--[[ Variables
  host
  port
--]]

-- CLASS METHODS

--[[ Create a new irc connection
host: Irc server to connect to (defaults to irc.freenode.net)
port: Port of the Irc server (defaults to 6667)

returns: new connection object
--]]
function Connection:new(o)
  -- TODO: find a way to merge tables to allow defaults to work properly
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.last_ping = os.time()
  o.last_send = os.time()
  o.socket = socket.tcp()
  o.bot.events:bind("ping", o.handle_ping)
  return o
end

-- INSTANCE METHODS

function Connection:open(host, port)
  self.host = host
  self.port = port
  self:event("connection_open")
  return self.socket:connect(self.host, self.port)
end

function Connection:handshake(nick, password)
  if password then 
    self:send_password(password)
  end
  self:send_nick(nick)
  realname = string.format("Sabot Lua Bot v%s", Bot.VERSION:concat('.'))
  self:send_user(nick, "sabot-v0", )
end

function Connection:event(name, ...)
	self.bot.events:fire(name, self,...)
end

function Connection:send(str)  
  self:event("connection_send", str)
  return self:send_raw(str .. "\r\n")
end

function Connection:send_raw(str)
  local len, errorCode = self.socket:send(str)
  if len ~= string.len(str) then
    self:event("connection_send_error", errorCode)
    return false, errorCode or "UNKNOWN ERROR"
  end
  lastSend = os.time()
  return true
end

--[[ IRC Commands
These are raw methods, they do no special checking on input. 
For example send_message does not check for valid length.
It is recommended that you use the methods in bot.lua instead. 
--]] 

function Connection:send_nick(nick)
  return self:send(string.format("NICK %s", nick))
end

function Connection:send_password(password)
  return self:send(string.format("PASS %s", password))
end

function Connection:send_user(user, realname)
  return self:send(string.format("USER %s example.com %s :%s", user, self.host, realname)) -- pick a good hostname :)
end

function Connection:send_pong(server)
  return self:send("PONG " .. server)
end

function Connection:mode(...)
  return self:send("MODE " .. table.concat(args, " "))
end

function Connection:quit(message)
  message = message or "Sabot" .. table.concat(Bot.VERSION, '.')
  return self:send("QUIT :" .. message)
end

function Connection:topic(chan, topic)
  if topic then 
    return self:send(string.format("TOPIC %s :%s", chan, topic))
  else
    return self:send("TOPIC " .. chan)
  end
end

function Connection:message(chan, message)
  return self:send(string.format("PRIVMSG %s :%s", chan, message))
end

--[[ Join channels
params: variable amount of channel names
--]]
function Connection:join(...)
  if(#arg == 0) then return end
  return self:send("JOIN " .. table.concat(arg, ","))
end

--[[ Part channels
params: variable amount of channel names
--]]
function Connection:part(...)
  if(#arg == 0) then return end
  return self:send("PART " .. table.concat(arg, ","))
end

function Connection:receive() 
  local data, err = self.socket:receive("*l")
  if not data and err and #err > 0 and err ~= "timeout" then
    self:event("connection_timeout", err)
    return false
  elseif not data then
    return true
  else 
	  self:event("connection_receive", data)
  end
  return self:receive_data(data)
end

function Connection:receive_data(str)
  if ":" ==  str:sub(1, 1) then 
    str = str:sub(2)
    str, after_colon = unpack(str:split(":", 1))
    tokens =  str:split(" ")
    
    
  elseif "PING" == str:sub(1, 4) then 
    if ":" == str:sub(6, 6) then server = str:sub(7) else server = str:sub(6) end
    self:send_pong(server)
    self:event("ping", server) 
    self.last_ping = os.time() -- in case an event wants to measure times between pings
    
  else
    self:event("invalid_packet", data) --as far as this bot is concerned
  end
  return
end

function Connection.handle_ping(event_name, self, server)
  if os.time() - self.last_ping > 600 then
    cprint("red", "Warning: Latency > 600ms")
  end
end

-- debugging instance methods

function Connection:activate_socket_debugging()
  self.bot.events:bind("connection_open", function(_, conn)
    cprint("yellow", "Connection opened to " .. conn.host .. " on port " .. conn.port)
  end)
  self.bot.events:bind("connection_send", function(_, _, str)
    cprint("green", " << " .. str)
  end)
  self.bot.events:bind("connection_send_error", function(_, _, errorCode)
    cprint("red", "Send error: " .. errorCode)
  end)
  self.bot.events:bind("connection_receive", function(_, _, str) 
    cprint("yellow", " >> " .. str)
  end)
  self.bot.events:bind("connection_timeout", function(_, con, err)
    cprint("bold_red", strformat("Lost connection to %s:%d: %s", con.host, con.port, err))
  end)
end

function Connection:activate_event_tracing()
  events = {"connection_send", "ping", "invalid_packet"}
  for i, v in ipairs(events) do
    self.bot.events:bind(v, function(event_name) cprint("gray", " %event: " .. event_name) end)
  end
end