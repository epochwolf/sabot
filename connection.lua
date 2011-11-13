--[[
Class to manage an IRC Connection
--]]
require "luarocks.loader"
local socket = require "socket"
require "util"
require "events"

Connection = {}

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
  o.events = Events:new{context=o}
  o.events:bind("ping", o.handle_ping)
  o.command_char = "!"
  return o  
end

-- INSTANCE METHODS
function Connection:open(host, port)
  self.host = host
  self.port = port
  self.last_ping = os.time()
  self:event("connection_open", host, port)
  return self.socket:connect(self.host, self.port)
end

function Connection:handshake(nick, password)
  if password then 
    self:send_password(password)
  end
  self:send_nick(nick)
  realname = string.format("Sabot Lua Bot v%s", table.concat(Bot.VERSION, '.'))
  self:send_user(nick, realname)
end

function Connection:event(name, ...)
	self.events:fire(name, ...)
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

function Connection:send_mode(...)
  return self:send("MODE " .. table.concat(args, " "))
end

function Connection:send_quit(message)
  message = message or "Sabot" .. table.concat(Bot.VERSION, '.')
  return self:send("QUIT :" .. message)
end

function Connection:send_topic(chan, topic)
  if topic then 
    return self:send(string.format("TOPIC %s :%s", chan, topic))
  else
    return self:send("TOPIC " .. chan)
  end
end

function Connection:send_privmsg(chan, message)
  return self:send(string.format("PRIVMSG %s :%s", chan, message))
end

--[[ Join channels
params: variable amount of channel names
--]]
function Connection:send_join(...)
  if(#arg == 0) then return end
  return self:send("JOIN " .. table.concat(arg, ","))
end

--[[ Part channels
params: variable amount of channel names
--]]
function Connection:send_part(...)
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
	  self:receive_data(data)
  end
  return true
end

function Connection:receive_data(str)
  if ":" ==  str:sub(1, 1) then 
    -- tokenizer
    str = str:sub(2)
    str, after_colon = unpack(str:split(":", 1))
    tokens =  str:split(" ")
    -- parser
    
    if tokens[2] == "PRIVMSG" then 
      if after_colon:sub(1, 6) == "ACTION" then 
        self:event("privmsg:action", tokens[1], tokens[3], after_colon:sub(8))
      else
        self:event("privmsg", tokens[1], tokens[3], after_colon)
        if after_colon:sub(1, self.command_char:len()) == self.command_char then
          local command, args = unpack(after_colon:split(" ", 1))
          command = command:sub(self.command_char:len() + 1)
          self:event("command", tokens[1], tokens[3], command, args)
          self:event("command:" .. command, tokens[1], tokens[3], args)
        end
      end
    -- Response Packets
    elseif tokens[2] == "376" then self:event("motd_end")
    
    -- Error Packets  
    elseif tokens[2] == "432" then self:event("nick_error|erroneous_nick", tokens[4]) -- [4] is nick
    elseif tokens[2] == "433" then self:event("nick_error|nick_already_in_use", tokens[4]) -- [4] is nick
    elseif tokens[2] == "436" then self:event("nick_error|nick_collision", tokens[4]) -- [4] is nick
    elseif tokens[2] == "437" then -- netsplit timeouts in effect...
      if tokens[4].sub(1, 1).match("^[#%%&+]") then self:event("channel_unavailable", tokens[4])  -- [4] is channel
      else self:event("nick_unavailable", tokens[4]) end  -- [4] is nick
    -- :epochwolf|air!~epochwolf@c-76-22-116-27.hsd1.wa.comcast.net PRIVMSG #voidptr :ACTION hugs sabot_lua_bot
      
      
    --elseif 
    --[[
     >> :verne.freenode.net 332 epochwolf|bot ##sabot_lua_bot :Chatroom for testing sabot, an irc bot written in lua. https://github.com/epochwolf/sabot
     >> :verne.freenode.net 333 epochwolf|bot ##sabot_lua_bot epochwolf|air!~epochwolf@unaffiliated/epochwolf 1318737887
     >> :verne.freenode.net 353 epochwolf|bot @ ##sabot_lua_bot :epochwolf|bot epochwolf|air @ChanServ
     >> :verne.freenode.net 366 epochwolf|bot ##sabot_lua_bot :End of /NAMES list.
    --]]
    elseif false then
    else
      self:event("unhandled_packet", tokens, after_colon)
    end 
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

function Connection.handle_ping(e, server)
  local c = e.context
  if os.time() - c.last_ping > 600 then
    cprint("red", "Warning: Latency > 600ms")
  end
end

-- debugging instance methods

function Connection:activate_socket_debugging()
  self.events:bind("connection_open", function(e)
    local conn = e.context
    cprint("yellow", "Connection opened to " .. conn.host .. " on port " .. conn.port)
  end)
  self.events:bind("connection_send", function(e, str)
    cprint("green", " << " .. str)
  end)
  self.events:bind("connection_send_error", function(e, errorCode)
    cprint("red", "Send error: " .. errorCode)
  end)
  self.events:bind("connection_receive", function(e, str) 
    cprint("yellow", " >> " .. str)
  end)
  self.events:bind("connection_timeout", function(e, err)
    local con = e.context
    local msg = "Lost connection to %s:%d: %s"
    cprint("bold_red", msg:format(con.host, con.port, err))
  end)
end

function Connection:activate_event_tracing()
  local events = "connection_send|ping|invalid_packet|motd_end|privmsg|command"
  self.events:bind(events, function(e) cprint("gray", " %event: " .. e.name) end)
end