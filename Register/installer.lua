shell = require("shell")
shell.execute("rm POS.lua")
shell.execute("rm menu.lua")
shell.execute("wget https://raw.githubusercontent.com/EnragedStrings/OCBank/main/Register/POS.lua")
shell.execute("wget https://raw.githubusercontent.com/EnragedStrings/OCBank/main/Register/menu.lua")
local writer = require("component").os_cardwriter
writer.write("defaultUser", "defaultUser", false)
shell.execute("POS")
