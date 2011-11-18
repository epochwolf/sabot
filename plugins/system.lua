plugin.name = "System"
plugin.version = {0, 0, 1}
plugin.author = "epochwolf"
plugin.description = "Basic commands for the bot"

plugin:command("commands", function(e, channel, nick, args)
  local commands = {}
  for name, p in pairs(bot.plugin_manager.plugins) do
    if p.commands then
      for command in pairs(p.commands) do
        commands[#commands+1] = command
      end
    end
  end
  table.sort(commands)
  commands = table.concat(commands, ", ")
  api:msg(channel, "Commands: "..commands)
end)

plugin:command("about", function(e, channel, nick, args)
  api:msg(channel, "I'm an irc bot written in lua. My source is available on github: https://github.com/epochwolf/sabot")
end)

plugin:command("version", function(e, channel, nick, args)
  local ver = table.concat(BOT_VERSION, ".")
  api:msg(channel, "Sabot Lua Bot v"..ver)
end)

plugin:command("help", function(e, channel, nick, args)
  api:msg(channel, "Why don't you ask the temporal wolf that created me?")
end)

plugin:command("error", function(e, channel, nick, args)
  assert(bubbles)
end)

plugin:command("quit", function(e, channel, nick, args)
  api:msg(channel, "Sorry, I don't have a way to do that yet.")
end)

plugin:command("join", function(e, channel, nick, args)
  if not args then
    api:msg(channel, "Which channel?")
  else
    local first = unpack(string.split(args, " ", 1))
    api:join(first)
    api:msg(channel, "Ok.")
  end
end)

plugin:command("part", function(e, channel, nick, args)
  if not args then
    api:msg(channel, "Which channel?")
  else
    local first = unpack(string.split(args, " ", 1))
    api:part(first)
    api:msg(channel, "Ok.")
  end
end)

return {}