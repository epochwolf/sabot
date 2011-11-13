--[[
Utility functions, language extensions used throughout the code. 
--]]
--Source: http://lua-users.org/wiki/SplitJoin
function string:split(sSeparator, nMax, bRegexp)
  assert(sSeparator ~= '')
  assert(nMax == nil or nMax >= 1)

  local aRecord = {}

  if self:len() > 0 then
    local bPlain = not bRegexp
    nMax = nMax or -1

    local nField=1 nStart=1
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

function parse_nick(nick)
  local bang_pos = nick:find('!')
  local at_pos = nick:find('@')
  return nick:sub(1, bang_pos - 1), nick:sub(bang_pos + 1, at_pos - 1), nick:sub(at_pos + 1)
end


function shallow_copy_table(original_table)
  local new_table = {}
  for k,v in ipairs(original_table) do new_table[k] = v end
  return copy
end

-- xterm 16 color codes, source: wikipedia
xterm_color = {
  reset         ="\27[00m", -- this returns the console to normal
  black         ="\27[0;30m", 
  blue          ="\27[0;34m",    
  green         ="\27[0;32m",    
  cyan          ="\27[0;36m",    
  red           ="\27[0;31m",    
  magenta       ="\27[0;35m",    
  yellow        ="\27[0;33m",
  gray          ="\27[0;37m",  
  bold_black    ="\27[1;30m",
  bold_blue     ="\27[1;34m",
  bold_green    ="\27[1;32m",
  bold_cyan     ="\27[1;36m",
  bold_red      ="\27[1;31m",
  bold_magenta  ="\27[1;35m",
  bold_yellow   ="\27[1;33m",
  bold_white    ="\27[1;37m",
}

function cprint(color, str)
  if xterm_color[color] then color = xterm_color[color] end --allow colors by code or name
  print(color .. str .. xterm_color.reset)
end


  