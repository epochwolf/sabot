plugin.name = "Fun"
plugin.version = {0, 0, 1}
plugin.author = "epochwolf"
plugin.description = "Stuff to play around with"

plugin:command("hi", function(e, channel, nick, args)
  if not args then
    api:msg(channel, "Hi "..nick)
  else
    api:msg(channel, "Hi "..args)
  end
end)

-- plugin:command("eval", function(e, channel, nick, args)
--   local print_f = function(str) api:msg(channel, "print: "..str) end
--   local env = {api = api, string = string, table = table, math = math, print = print_f}
--   local f, err = loadstring(args)
--   if err then
--     api:msg(channel, "Error: "..err)
--   else
--     setfenv(f, env)
--     xpcall(f, function(err) api:msg(channel, "Error: "..err) end)
--   end
-- end)

plugin:command("roll", function(e, channel, nick, args)
  if args == "help" then
    api:msg(channel, "roll: Roll a six-sided die.")
  else
    api:msg(channel, nick..": "..  math.random(1, 6))
  end
end)



plugin:command("choose", function(e, channel, nick, args)
  local tokens
  if not args or args == "" then
    tokens = {"bacon", "purple", "vb6", "nothing"}
  else
    tokens = string:split(args)
  end
  local choosen = math.random(1, #tokens)
  api:action(channel, "chooses "..tokens[choosen]..".")
end)

plugin:command("wave", function(e, channel, nick, args)
  if not args then
    api:action(channel, "waves")
  else
    api:action(channel, "waves to "..args)
  end
end)

plugin:bind("join", function(e, channel, nick, args)
  if channel == "##sabot_lua_bot" then 
    api:action(channel, "waves")
  end
end)

plugin:bind("privmsg:action", function(e, channel, nick, args)
  if channel == "##sabot_lua_bot" and 4 == math.random(1, 6) then 
    api:action(channel, "helps "..nick.." with that.")
  end
end)