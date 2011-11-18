local print = print
local Console = {}

-- xterm 16 color codes, source: wikipedia
Console.xterm_color = {
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

function Console.log(...)
  local args = {...}
  if 2 == #args then 
    Console.color(args[1], args[2])
  else
    print(args[1])
  end
end

function Console.error(err)
  Console.log("bold_red", "ERROR: "..err)
  Console.log(debug.traceback())
end

function Console.print_error(err)
  Console.log("bold_yellow", "WARNING: using unsupported function.")
  Console.error(err)
end

function Console.color(color, message)
  local colors = Console.xterm_color
  if colors[color] then color = colors[color] end --allow colors by code or name
  print(color .. message .. colors.reset)
end

return Console