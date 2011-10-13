--[[
Class to manage an IRC Connection
--]]
require "util"
require "luarocks.loader"
local socket = require "socket"

Connection = {}
--[[ Variables
  host
  port
--]]

Connections = {
  freenode = { host="irc.freenode.net", port="6667" }
}

-- CLASS METHODS

function Connection:new(o)
  o = (o and shallow_copy_table(o)) or {host="irc.freenode.net", port="6667"}
  setmetatable(o, self)
  self.__index = self
  o.last_ping = 0
  o.socket = socket.tcp()
  return o
end

-- INSTANCE METHODS

function Connection:open()
  return self.socket:connect(self.host, self.port)
end

function Connection:handshake(nick, password)
  self:send_nick(nick)
  if password then 
    self:send_password(password)
  end
  self:send_user("alphabot")
end

function Connection:send(str)  
  cprint("green", " << " .. str)
  return self:send_raw(str .. "\r\n")
end

function Connection:send_raw(str)
  local len, errorCode = self.socket:send(str)
  if len ~= string.len(str) then
    cprint("red", "Send error: " .. errorCode)
    return false, errorCode or "UNKNOWN ERROR"
  end
  lastSend = os.time()
  return true
end

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

function Connection:receive() 
  local data, err = self.socket:receive("*l")
  if not data and err and #err > 0 and err ~= "timeout" then
    cprint("bold_red", strformat("Lost connection to %s:%d: %s", self.host, self.port, err))
    return false
  elseif not data then
    return true
  else 
    cprint("yellow", " >> " .. data)
  end
  return self:receive_data(data)
end

function Connection:receive_data(data)
  if string.match(data, "^:?PING") then
    self:handle_ping(data)
  end
  return true
end

function Connection:handle_ping(data)
  local command, param = strmatch(data, "^:?([^:]+ ):?(.+)")
  self.last_ping = os.time()
  if last_ping and os.time() - lastPing > 600 then
    cprint("red", "Warning: Latency > 600ms")
  end
  self:send_pong(param)
end