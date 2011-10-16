--[[
Class to manage an IRC Connection
--]]
require "util"
require "luarocks.loader"
require "events"
local socket = require "socket"

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
  o = (o and shallow_copy_table(o)) or {host="irc.freenode.net", port="6667"}
  setmetatable(o, self)
  self.__index = self
  o.last_ping = 0
  o.events = Events:new()
  o.socket = socket.tcp()
  o.events:bind("ping", o.handle_ping)
  return o
end

-- INSTANCE METHODS

function Connection:open()
  self:event("connection_open")
  return self.socket:connect(self.host, self.port)
end

function Connection:handshake(nick, password)
  self:send_nick(nick)
  if password then 
    self:send_password(password)
  end
  self:send_user("alphabot")
end

function Connection:event(name, ...)
	self.events:fire(name, self, ...)
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

function Connection:send_user(user)
  return self:send(string.format("USER %s %s %s :Tag", user, user, self.host))
end

function Connection:send_pong(server)
  return self:send("PONG " .. server)
end

function Connection:send_message(chan, message)
  return self:send(string.format("PRIVMSG %s :%s", chan, message))
end

function Connection:send_join(chan)
  return self:send("JOIN " .. chan)
end

function Connection:send_part(chan)
  return self:send("PART " .. chan)
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

function Connection:receive_data(data)
  local command, param = string.match(data, "^:?([^:]+) :?(.+)")
  if command == "PING" then
	  self:event("ping", param)
  end
  return true
end

function Connection.handle_ping(event_name, self, server)
  self.last_ping = os.time()
  if self.last_ping and os.time() - self.last_ping > 600 then
    cprint("red", "Warning: Latency > 600ms")
  end
  connection:send_pong(server)
end


-- debugging instance methods

function Connection:activate_socket_debugging()
  self.events:bind("connection_open", function(_, conn)
    cprint("yellow", "Connection opened to " .. conn.host .. " on port " .. conn.port)
  end)
  self.events:bind("connection_send", function(_, _, str)
    cprint("green", " << " .. str)
  end)
  self.events:bind("connection_send_error", function(_, _, errorCode)
    cprint("red", "Send error: " .. errorCode)
  end)
  self.events:bind("connection_receive", function(_, _, str) 
    cprint("yellow", " >> " .. str)
  end)
  self.events:bind("connection_timeout", function(_, con, err)
    cprint("bold_red", strformat("Lost connection to %s:%d: %s", con.host, con.port, err))
  end)
end

function Connection:activate_event_tracing()
  events = {"connection_send", "ping"}
  for i, v in ipairs(events) do
    self.events:bind(v, function(event_name) cprint("gray", " %event: " .. event_name) end)
  end
end