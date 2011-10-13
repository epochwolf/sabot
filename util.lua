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