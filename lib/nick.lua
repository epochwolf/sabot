require "lib/util" 
local Nick = {}
local time = os.time
local split = string.split

--instance variables
Nick.name = ""
Nick.user = ""
Nick.host = ""
Nick.modes = ""
Nick.refresh_at = 0
Nick.last_seen = 0
Nick.away = nil -- or message (string)
Nick.disconnected_at = 0

function Nick:new(nickstr)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.refresh_at = time()
  o:update(nickstr)
  return o
end

function Nick:update(nickstr)
  name, user, host = Nick.components(nickstr)
  if name then self.name = name end 
  if user then self.user = user end
  if host then self.host = host end
end


--Input: epochwolf|bot!~epochwolf@c-67-170-60-66.hsd1.wa.comcast.net 
--Output: {"epochwolf|bot", "~epochwolf", "c-67-170-60-66.hsd1.wa.comcast.net"}
function Nick.components(nickstr)
  return unpack(split(nickstr, '[!@]', 2, true))
end

return Nick