require "luarocks.loader"
Nick = require 'lib/nick'
require 'lib/util'
console = require 'lib/console'
local cprint = console.color
local socket = require "socket"
local BOT_VERSION = BOT_VERSION
local assert = assert
local unpack = unpack
local setmetatable = setmetatable
local type = type
local concat = table.concat
local time = os.time
local split = string.split
local strformat = string.format
local parse_nick = Nick.components

--[[
Class to manage an IRC Connection
--]]
local Connection = {}

-- CLASS METHODS

--[[ Create a new irc connection
host: Irc server to connect to (defaults to irc.freenode.net)
port: Port of the Irc server (defaults to 6667)

returns: new connection object
--]]
function Connection:new(config, bot_manager)
  assert(config)
  assert(bot_manager)
  -- TODO: find a way to merge tables to allow defaults to work properly
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.last_ping = time()
  o.last_send = time()
  o.socket = socket.tcp()
  o.config = config
  o.manager = bot_manager
  o.events = o.manager.events
  o.events:bind("ping", o.handle_ping)
  return o  
end

-- INSTANCE METHODS

function Connection:connect()
  self.last_ping = time()
  return self.socket:connect(self.config.server_host, self.config.server_port)
end

function Connection:handshake()
  local password = self.config.server_password
  local realname = strformat("Sabot Lua Bot v%s", concat(BOT_VERSION, '.'))
  local nick = self.config.nick[1]
  local username = self.config.username
  if password then self:send_password(password) end
  self:send_nick(nick)
  self:send_user(username, realname)
end

function Connection:auto_join()
  self:send_join(unpack(self.config.auto_join))
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
  if len ~= #str then
    self:event("connection_send_error", errorCode)
    return false, errorCode or "UNKNOWN ERROR"
  end
  self.last_send = time()
  return true
end

--[[ IRC Commands
These are raw methods, they do no special checking on input. 
For example send_message does not check for valid length.
It is recommended that you use the methods in bot.lua instead. 
--]] 

function Connection:send_nick(nick)
  assert(nick)
  return self:send(strformat("NICK %s", nick))
end

function Connection:send_password(password)
  assert(password)
  return self:send(strformat("PASS %s", password))
end

function Connection:send_user(user, realname)
  assert(user)
  assert(realname)
  return self:send(strformat("USER %s example.com %s :%s", user, self.config.server_host, realname)) -- pick a good hostname :)
end

function Connection:send_pong(server)
  return self:send("PONG " .. server)
end

function Connection:send_mode(...)
  return self:send("MODE " .. concat(..., " "))
end

function Connection:send_quit(message)
  message = message or "Sabot" .. concat(BOT_VERSION, '.')
  return self:send("QUIT :" .. message)
end

function Connection:send_topic(chan, topic)
  if topic then 
    return self:send(strformat("TOPIC %s :%s", chan, topic))
  else
    return self:send("TOPIC " .. chan)
  end
end

function Connection:send_privmsg(chan, message)
  return self:send(strformat("PRIVMSG %s :%s", chan, message))
end

--[[ Join channels
params: variable amount of channel names
--]]
function Connection:send_join(...)
  if(#arg == 0) then return end
  return self:send("JOIN " .. concat(arg, ","))
end

--[[ Part channels
params: variable amount of channel names
--]]
function Connection:send_part(...)
  if(#arg == 0) then return end
  return self:send("PART " .. concat(arg, ","))
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
    local str, after_colon = unpack(str:split(":", 1))
    local tokens =  str:split(" ")
    -- parser
    
    if tokens[2] == "PRIVMSG" then 
      local channel = tokens[3]
      local nick = parse_nick(tokens[1])
      if after_colon:sub(1, 6) == "ACTION" then 
        self:event("privmsg:action", channel, nick, after_colon:sub(8))
      else
        self:event("privmsg", channel, nick, after_colon)
        local command_char = self.config.command_char
        
        if after_colon:sub(1, command_char:len()) == command_char then
          local command, args = unpack(after_colon:split(" ", 1))
          command = command:sub(command_char:len() + 1)
          self:event("command", channel, nick, command, args)
          self:event("command:" .. command, channel, nick, args)
        end
      end
    -- Response Packets
    elseif tokens[2] == "376"  then 
      self:event("motd_end")
      self:auto_join()
    elseif tokens[2] == "JOIN" then self:event("join", tokens[3], parse_nick(tokens[1])) -- [3] channel, [1] nick!user@host
    elseif tokens[2] == "332"  then self:event("topic", tokens[4], after_colon) -- [4] is channel
    elseif tokens[2] == "353"  then self:event("names", tokens[4], after_colon:split(" ")) -- [4] channel, after_colon: nicks
    elseif tokens[2] == "366"  then self:event("end_of_names")
    
    -- Error Packets  
    elseif tokens[2] == "432"  then self:event("nick_error|erroneous_nick", tokens[4]) -- [4] is nick
    elseif tokens[2] == "433"  then self:event("nick_error|nick_already_in_use", tokens[4]) -- [4] is nick
    elseif tokens[2] == "436"  then self:event("nick_error|nick_collision", tokens[4]) -- [4] is nick
    elseif tokens[2] == "437"  then -- netsplit timeouts in effect...
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
      self:event("unhandled_packet", str)
    end 
  elseif "PING" == str:sub(1, 4) then 
    local server
    if ":" == str:sub(6, 6) then server = str:sub(7) else server = str:sub(6) end
    self:send_pong(server)
    self:event("ping", server, self.last_ping) 
    self.last_ping = time() -- in case an event wants to measure times between pings
  else
    self:event("invalid_packet", str) --as far as this bot is concerned
  end
  return
end

function Connection.handle_ping(e, server, last_ping)
  if time() - last_ping > 600 then
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
  self.events:bind("*", function(e, name, ...) 
    local args = {...}
    local t
    if args then
      if type(args) == "table" then 
        args = concat(args, '", "')
      end
      t = '"' .. args .. '"'
    else
      t = ""
    end
    if name ~= "connection_receive" then 
      cprint("gray", "  (" .. name .. ": " .. t .. ")") 
    end
  end)
end


return Connection