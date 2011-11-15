plugin.name = "System"
plugin.version = {0, 0, 1}
plugin.author = "epochwolf"
plugin.description = "Basic commands for the bot"

plugin:command("hi", function(e, channel, nick, args)
  bot:msg(channel, "Hi "..nick)
end)

return {}