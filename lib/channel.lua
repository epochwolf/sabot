local Channel = {}
local substr = string.substr
local strfind = string.find

--instance variables
Channel.name = ""
Channel.modes = ""
Channel.topic = ""
Channel.bans = {} --array of strings
Channel.limit = 0
Channel.key = nil  -- or key (string)
Channel.nicks = {} -- nick: modes
Channel.joined = true -- false if left for some reasons

function Channel:new(name)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.name = name
  o.nicks = {}
  o.bans = {}
  return o
end

function Channel:ops()
  local r = {}
  for nick, modes in pairs(self.nicks) do
    if substr(modes, 'o') then
      r[#r] = nick
    end
  end
  return r
end

function Channel:is_oped(nick)
  return self.nicks[nick] and substr(self.nicks[nick], 'o')
end

function Channel:is_voiced(nick)
  return self.nicks[nick] and substr(self.nicks[nick], 'v')
end

function Channel:get_topic()
  self.bot.connection.topic(self.name)
end

function Channel:set_topic(str)
  self.bot.connection.topic(self.name, str)
end

function Channel:join()
  self.bot.connection.join(self.name)
end

function Channel:part()
  self.bot.connection.part(self.name)
end

function Channel.is_channel(channel)
  if strfind(channel, "^[#&+!]#?") then 
    return true
  else
    return false
  end
end

return Channel