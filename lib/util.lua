local string = string
local print = print

--[[
Utility functions, language extensions used throughout the code. 
--]]
--Source: http://lua-users.org/wiki/SplitJoin

--major, minor, build
BOT_VERSION = {0, 2, 1}



function string:split(sSeparator, nMax, bRegexp)
  assert(sSeparator ~= '')
  assert(nMax == nil or nMax >= 1)

  local aRecord = {}

  if self:len() > 0 then
    local bPlain = not bRegexp
    nMax = nMax or -1

    local nField=1 
    local nStart=1
    local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
    while nFirst and nMax ~= 0 do
      aRecord[nField] = self:sub(nStart, nFirst-1)
      nField = nField+1
      nStart = nLast+1
      nFirst,nLast = self:find(sSeparator, nStart, bPlain)
      nMax = nMax-1
    end
    aRecord[nField] = self:sub(nStart)
  end
  
  return aRecord
end

-- function shallow_copy_table(original_table)
--   local new_table = {}
--   for k,v in ipairs(original_table) do new_table[k] = v end
--   return copy
-- end


  