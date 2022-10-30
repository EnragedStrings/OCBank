function rgb(r,g,b)
  local rgb = (r * 0x10000) + (g * 0x100) + b
  return tonumber((rgb))
end

buttonTheme = {
  background = rgb(5, 63, 150),
  foreground = rgb(255,255,255),
  c1 = rgb(150,0,0),
  c2 = rgb(0,0,150),
  c3 = rgb(0,100,0),
  ct1 = rgb(255,255,255),
  ct2 = rgb(255,255,255),
  ct3 = rgb(255,255,255)
}
mainTheme = {
  background = rgb(40,40,40),
  middle = rgb(60,60,60),
  foreground = rgb(120,120,120),
  text = rgb(255,255,255)
}

local currency = "$"




local process = require("process")
local component = require("component")
local term = require("term")
process.info().data.signal = function() end

local shown = false
while not (component.isAvailable("internet") and component.isAvailable("gpu") and component.isAvailable("os_magreader") and component.isAvailable("os_cardwriter")) do
  if shown == false then 
    term.clear()
    print("Key components not found.") 
    shown = true
  end
  os.sleep(1)
end

local computer = require("computer")
local magReader = require("component").os_magreader
local writer = require("component").os_cardwriter
local gpu = require("component").gpu
local event = require("event")
local internet = require("internet")
local serialization = require("serialization")
local shell = require("shell")
local fs = require("filesystem")
--m = require("component").modem
sW, sH = gpu.getResolution()
local halt = false


local file = assert(io.open("/home/.shrc", "w"))
file:write("POS.lua")
file:close()

order = {}
local buttons = {}
local functions = {}
local items = {}
local columns = 6
local rowH = 3
local mWidth = (sW/2) - 28
local itemGap = 1
local itemWidth = (mWidth-((columns+1)*itemGap))/columns
local tax = 0.00
local total = 0
local pay = false
local subtotal = 0
local selected = 0
local itemnum = 0
local mngr = false
local isMngr = false
local createcard = false
local processing = false

local screenDir = ("/home/screens.txt")
screenDirFile = ""
local readerDir = ("/home/reader.txt")
readerDirFile = ""
local userDir = ("/home/users.txt")
local menuDir = ("/home/menu.lua")
local orderDir = ("/home/orders.txt")
local apiKeyDir = ("/home/apiKey.txt")
local verDir = ("/home/version.txt")

local screens = {}
for address, name in component.list("screen", true) do
  table.insert(screens, component.proxy(address))
end
local readers = {}
for address, name in component.list("os_magreader", true) do
  table.insert(readers, component.proxy(address))
end
function Split(s, delimiter)
  if s ~= nil then
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        if match ~= nil then
          table.insert(result, match);
        end
        if result == nil then
          result[1] = s
          result[2] = nil
        end
    end
  end
  return result;
end
function shorten(n, d, t)
  if n == "INF" then
    return(0)
  elseif n >= (10^9)-1 then
    local cn = Split(n, "0")
    return string.format("%E", n)
  elseif n >= 10^6 then
      return string.format("%."..d.."fM", n / 10^6)
  elseif n >= 10^3 then
      return string.format("%."..d.."fk", n / 10^3)
  else
    if t == true then
      return string.format("%."..d.."f", n)
    else
      return tostring(n)
    end
  end
end
function format_num(amount, decimal, prefix, neg_prefix)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places
  neg_prefix = neg_prefix or "-" -- default negative sign

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end

        -- attach prefix string e.g '$' 
  formatted = (prefix or "") .. formatted 

        -- if value is negative then format accordingly
  if (amount<0) then
    if (neg_prefix=="()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted 
    end
  end

  return formatted
end
function format_int(number)

  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the 
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end
function magData(eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side)
  --Listens To Card Readers
  if getAddress == true then
    print(address)
    readerAddress = address
    getAddress = false
  elseif address == readerAddress then
    if assigned == false then
      if getAPI == true then
        apiKey = cardData
        print("Input POS Company Card Number")
        POSCard = io.read()
        local file = assert(io.open(apiKeyDir, "w"))
        file:write(apiKey.." "..POSCard)
        file:close()
        computer.shutdown(true)
      else
        for i = 1, #users do
          if users[i][1] == cardUniqueId or users[i][1] == "nil" then
            if users[i][2] == "defaultUser" or users[i][1] == cardUniqueId then
              assigned = true
              currentUser = users[i][2]
              usrLvl = users[i][3]
              background()
              foreground()
            end
          end
        end
      end
    elseif assigned == true then
      if newMemeberCard == true then
        m.broadcast(8000, "SMCP cadd "..cardUniqueId.." 1 "..cardName)
        newMemeberCard = false
      elseif newswipe == true then
        copy = false
        for i = 1, #users do
          if users[i][1] == cardUniqueId then
            copy = true
          end
        end
        if copy == false then
          table.insert(users, {cardUniqueId,newUser[1],newUser[2]})
          local file = assert(io.open(userDir, "w"))
          newUsers = ""
          for i = 1, #users do
            if i == #users then
              newUsers = newUsers..users[i][1].." "..users[i][2].." "..users[i][3]
            else
              newUsers = newUsers..users[i][1].." "..users[i][2].." "..users[i][3].."\n"
            end
          end
          file:write(newUsers)
          file:close()
          newswipe = false
        end
      elseif pay == true and processing == false then
        processing = true
        gpu.setBackground(mainTheme.foreground)
        gpu.fill((sW/2)-9, pheight+4, 18, 1, " ")
        gpu.set((sW/2)-7, pheight+4, "Input Pin:")
        term.setCursor((sW/2)+4, pheight+4)
        pininput = io.read()
        while pininput == "" or pininput == nil do
          term.setCursor((sW/2)+4, pheight+4)
          pininput = io.read()
        end
        transresult = transaction(apiKey, cardData, pininput, POSCard, subtotal)
        if string.find(transresult, "Approved") ~= nil then
          gpu.set((sW/2)-(4.5), pheight+6, "Approved!")
          os.sleep(2)
          pay = false
          processing = false
          background()
          foreground()
        else
          gpu.set((sW/2)-(4.5), pheight+6, "Declined!")
        end
      else
        background()
        foreground()
      end
    end
  end
end
function screenSetup()
  if #screens > 1 then
    for i = 1, #screens do
      if screens[i].address == gpu.getScreen() then
        print("["..i.."] "..screens[i].address.." (Current)")
      else
        print("["..i.."] "..screens[i].address)
      end
    end
    print("Input Screen Number")
    screen = tonumber(io.read())
    while screen > #screens do
      print("Invalid!")
      screen = tonumber(io.read())
    end
    while screens[screen].address == nil do
      print("Invalid!")
      screen = tonumber(io.read())
    end
    screen = screens[screen].address
  else
    screen = gpu.getScreen()
  end

  pcFound = false
  for i = 1, #screenDirFile do
    if screenDirFile[i][1] == computer.address() then
      screenDirFile[i][2] = screen
      pcFound = true
    end
  end
  tmpFile = ""
  for i = 1, #screenDirFile do
    if screenDirFile[i][1] ~= nil and screenDirFile[i][2] ~= nil then
      tmpFile = tmpFile.."\n"..screenDirFile[i][1].." "..screenDirFile[i][2]
    end
  end
  screenDirFile = tmpFile
  if pcFound == false then
    screenDirFile = screenDirFile.."\n"..computer.address().." "..screen
  end
  local file = assert(io.open(screenDir, "w"))
  file:write(screenDirFile)
  file:close()
  computer.shutdown(true)
end
function readerSetup()
  if #readers > 1 then
    for i = 1, #readers do
      print("["..i.."] "..readers[i].address)
    end
    print("Swipe Card Reader")
    getAddress = true
    event.listen("magData", magData)
    while getAddress == true do
      os.sleep()
    end
    pcFound = false
    for i = 1, #readerDirFile do
      if readerDirFile[i][1] == computer.address() then
        readerDirFile[i][2] = readerAddress
        pcFound = true
      end
    end
    tmpFile = ""
    for i = 1, #readerDirFile do
      if readerDirFile[i][1] ~= nil and readerDirFile[i][2] ~= nil then
        tmpFile = tmpFile.."\n"..readerDirFile[i][1].." "..readerDirFile[i][2]
      end
    end
    readerDirFile = tmpFile
    if pcFound == false then
      readerDirFile = readerDirFile.."\n"..computer.address().." "..readerAddress
    end
  end
  local file = assert(io.open(readerDir, "w"))
  file:write(readerDirFile)
  file:close()
  computer.shutdown(true)
end
function dependents()
  if fs.exists(screenDir) == true then
    local file = assert(io.open(screenDir))
    screenDirFile = file:read(1000)
    screenDirFile = Split(screenDirFile, "\n")
    pcFound = false
    for i = 1, #screenDirFile do
      screenDirFile[i] = Split(screenDirFile[i], " ")
      if screenDirFile[i][1] == computer.address() then
        dispScreen = screenDirFile[i][2]
        pcFound = true
      end
    end
    file:close()
    if pcFound == false then
      dispScreen = ""
    end
    if component.proxy(dispScreen) == nil then
      screenSetup()
    else
      gpu.bind(dispScreen)
    end
  else
    screenSetup()
  end
  gpu.bind(dispScreen)
  if fs.exists(readerDir) == true then
    local file = assert(io.open(readerDir))
    readerDirFile = file:read(1000)
    readerDirFile = Split(readerDirFile, "\n")
    pcFound = false
    for i = 1, #readerDirFile do
      readerDirFile[i] = Split(readerDirFile[i], " ")
      if readerDirFile[i][1] == computer.address() then
        readerAddress = readerDirFile[i][2]
        pcFound = true
      end
    end
    file:close()
    if pcFound == false then
      readerAddress = ""
    end
    if component.proxy(readerAddress) == nil then
      readerSetup()
    end
  else
    readerSetup()
  end
  if fs.exists(verDir) == true then
    local file = assert(io.open(verDir))
    version = tonumber(file:read(100000))
    file:close()
    gitversion = 0
    while gitversion == nil do
      shell.execute("rm version.txt")
      shell.execute("wget https://raw.githubusercontent.com/EnragedStrings/OCBank/main/Register/version.txt")
      local file = assert(io.open(verDir))
      gitversion = tonumber(file:read(100000))
      file:close()
    end
    if gitversion > version then
      shell.execute("rm installer.lua")
      shell.execute("wget https://raw.githubusercontent.com/EnragedStrings/OCBank/main/Register/installer.lua")
      shell.execute("installer.lua")
    end
  else
    local file = assert(io.open(verDir, "w"))
    file:write("0")
    file:close()
    computer.shutdown(true)
  end
  if fs.exists(userDir) == true then
    local file = assert(io.open(userDir))
    users = file:read(100000)
    if users ~= nil then
      users = Split(users, "\n")
      for i = 1, #users do
        users[i] = Split(users[i], " ")
      end
    end
    file:close()
  else
    local file = assert(io.open(userDir, "w"))
    file:write("nil defaultUser owner")
    file:close()
    writer.write("defaultUser", "defaultUser", false)
    computer.shutdown(true)
  end
  if fs.exists(orderDir) == true then
    local file = assert(io.open(orderDir))
    orders = file:read(100000)
    if orders ~= nil then
  
    end
    file:close()
  else
    local file = assert(io.open(orderDir, "w"))
    file:close()
    computer.shutdown(true)
  end
  if fs.exists(menuDir) == true then
    require("menu")
    menu = getMenu()
  else
    shell.execute("wget https://raw.githubusercontent.com/EnragedStrings/OCBank/main/Register/menu.lua")
    computer.shutdown(true)
  end
  if fs.exists(apiKeyDir) == true then
    local file = assert(io.open(apiKeyDir))
    keyfile = Split(file:read(100000), " ")
    apiKey = keyfile[1]
    POSCard = keyfile[2]
    file:close()
  else
    print("Use API Card? (Y/n)")
    if io.read() == "y" then
      getAPI = true
      event.pull("magData", magData)
      while getAPI == true do
        os.sleep()
      end
    else
      print("Input API Key (Ask Server Owner If Unknown!)")
      apiKey = io.read()
      print("Would you like to write the key to a card? (Y/n)")
      if io.read() == "y" then
        writer.write(apiKey, "API KEY CARD", true, 7)
      end
      print("Input POS Company Card Number")
      POSCard = io.read()
      local file = assert(io.open(apiKeyDir, "w"))
      file:write(apiKey.." "..POSCard)
      file:close()
      computer.shutdown(true)
    end
  end
end
function deleteButton(name)
  for i = 1, #buttons do
    if buttons[i].name == name then
      table.remove(buttons, i)
    end
  end
end
function createButton(xpos, ypos, width, height, bColor, bName, bShow, bDispName, bNameColor, bCode)
    xpos = xpos*2
    width = width*2
    for i = 1, #buttons do
      if buttons[i].name == bName then
        table.remove(buttons, i)
      end
    end
    table.insert(buttons, 
      {
        x = xpos,
        y = ypos,
        w = width,
        h = height,
        name = bName,
        color = bColor,
        code = bCode,
        show = bShow,
        dispName = bDispName,
        nameColor = bNameColor
      }
    )
    if bShow == true or bShow == nil then
      gpu.setBackground(bColor)
      gpu.fill(xpos, ypos, width, height, " ")
      if bDispName == true then
        gpu.setForeground(bNameColor)
        gpu.set(xpos+((width/2)-(#bName)/2), ypos+(height/2), bName)
      end
    end
    functions[bName] = bCode
end
function refreshButtons(exceptions)
  for i = 1, #buttons do
    found = false
    for j = 1, #exceptions do
      if buttons[i].name == exceptions[j] then
        found = true
      end
    end
    if found == false then
      gpu.setBackground(buttons[i].color)
      gpu.fill(buttons[i].x, buttons[i].y, buttons[i].w, buttons[i].h, " ")
      if buttons[i].dispName == true then
        gpu.setForeground(buttons[i].nameColor)
        gpu.set(buttons[i].x+((buttons[i].w/2)-(#buttons[i].name)/2), buttons[i].y+(buttons[i].h/2), buttons[i].name)
      end
    end
  end
end
function refreshButton(name)
    for i = 1, #buttons do
        if buttons[i].name == name then
            gpu.setBackground(buttons[i].color)
            gpu.fill(buttons[i].x, buttons[i].y, buttons[i].w, buttons[i].h, " ")
            if buttons[i].dispName == true then
              gpu.setForeground(buttons[i].nameColor)
              gpu.set(buttons[i].x+((buttons[i].w/2)-(#buttons[i].name)/2), buttons[i].y+(buttons[i].h/2), buttons[i].name)
            end
        end
    end
end
function mouseClick(_, address, x, y, button, name)
  if halt == false then
    if address == dispScreen then
      if button == 0 then
        if x >= 61 and 64 > x and y > 6 and 30 > y and pay == false and assigned == true then
          removed = false
          if users[y-6][2] ~= currentUser or currentUser == "defaultUser" then
            if usrLvl == "manager" and users[y-6][3] == "employee" then
              table.remove(users, y-6)
              removed = true
            elseif usrLvl == "owner" then
              table.remove(users, y-6)
              removed = true
            end
            if removed == true then
              local file = assert(io.open(userDir, "w"))
              newUsers = ""
              for i = 1, #users do
                if i == #users then
                  newUsers = newUsers..users[i][1].." "..users[i][2].." "..users[i][3]
                else
                  newUsers = newUsers..users[i][1].." "..users[i][2].." "..users[i][3].."\n"
                end
              end
              file:write(newUsers)
              file:close()
              background()
              mngr = false
              foreground()
            end
          end
        elseif x >= 6 and 23 > x and y > 3 and 30 > y and pay == false and assigned == true then
          selected = y - 3
          foreground()
        elseif x >= 23 and 26 > x and y > 3 and 30 > y and pay == false and assigned == true then
          start = 1
          for i = 1, #order do
            if start == y-3 then

              if order[i] ~= nil then
                if order[i][3] > 1 then
                  order[i][3] = order[i][3] - 1
                else
                  table.remove(order, i)
                end
              end
              foreground()
              start = start + #order[i][4] + 1
            else
              start = start + #order[i][4] + 1
            end
          end
        else
          for i = 1, #buttons do
            if x >= buttons[i].x and buttons[i].x + buttons[i].w > x and y >= buttons[i].y and buttons[i].y + buttons[i].h > y then
              buttonClicked = buttons[i].name
              functions[buttons[i].name]()
            end
          end
        end
      end
    end
  end
end
function logo(time, color)
  term.clear()
  if color == true then
      gpu.setForeground(0x00FF00)
  end
  term.setCursor((sW/2)-33,(sH/2)-3)
  print(" ██████╗███╗   ███╗ █████╗ ██████╗        ██╗███╗  ██╗ █████╗    ")
  os.sleep(time)
  if color == true then
      gpu.setForeground(0xFFB640)
  end
  term.setCursor((sW/2)-33,(sH/2)-2)
  print("██╔════╝████╗ ████║██╔══██╗██╔══██╗       ██║████╗ ██║██╔══██╗   ")
  os.sleep(time)
  if color == true then
      gpu.setForeground(0xFF6D00)
  end
  term.setCursor((sW/2)-33,(sH/2)-1)
  print("╚█████╗ ██╔████╔██║██║  ╚═╝██████╔╝       ██║██╔██╗██║██║  ╚═╝   ")
  os.sleep(time)
  if color == true then
      gpu.setForeground(0xFF2400)
  end
  term.setCursor((sW/2)-33,(sH/2))
  print(" ╚═══██╗██║╚██╔╝██║██║  ██╗██╔═══╝        ██║██║╚████║██║  ██╗   ")
  os.sleep(time)
  if color == true then
      gpu.setForeground(0x9924C0)
  end
  term.setCursor((sW/2)-33,(sH/2)+1)
  print("██████╔╝██║ ╚═╝ ██║╚█████╔╝██║            ██║██║ ╚███║╚█████╔╝██╗")
  os.sleep(time)
  if color == true then
      gpu.setForeground(0x0092FF)
  end
  term.setCursor((sW/2)-33,(sH/2)+2)
  print("╚═════╝ ╚═╝     ╚═╝ ╚════╝ ╚═╝            ╚═╝╚═╝  ╚══╝ ╚════╝ ╚═╝")
  gpu.setForeground(0xFFFFFF)
  gpu.fill((sW/2)-35, (sH/2)-3, 1, 6, "║")
  gpu.fill((sW/2)+33, (sH/2)-3, 1, 6, "║")
  gpu.set((sW/2)-35, (sH/2)-4, "╔═══════════════════════════════════════════════════════════════════╗")
  gpu.set((sW/2)-35, (sH/2)+3, "╚═══════════════════════════════════════════════════════════════════╝")
  if color == true then
      gpu.setForeground(0xFF0000)
  end
  term.setCursor((sW/2)-33,(sH/2)+3)
  print("Plese Swipe Employee Card!")
  if color == true then
    gpu.setForeground(0xFFFFFF)
  end
  gpu.set(1, sH, "Created By EnragedStrings")
end
function createMenu()
  for i = 1, math.ceil((#menu/columns)) do
    for j = 1, columns do
      if #menu >= ((i-1)*columns)+j then
        local pos = ((i-1)*columns)+j
        os.sleep()
        if menu[pos].background ~= nil then
          bcgrnd = menu[pos].background
        else
          bcgrnd = buttonTheme.background
        end
        if menu[pos].foreground ~= nil then
          frgrnd = menu[pos].foreground
        else
          frgrnd = buttonTheme.foreground
        end
        createButton((15+itemGap)+((itemWidth+itemGap)*(j-1)), 4+((itemGap+rowH)*(i-1)), itemWidth, rowH, bcgrnd, menu[pos].itemName, false, true, buttonTheme.foreground, function()
          if assigned == true and pay == false and mngr == false and halt == false then
            for l = 1, #menu do
              if menu[l].itemName == buttonClicked then
                menu[l].code()
                if menu[l].defaultCode == true then
                  found = false
                  for m = 1, #order do
                    if order[m][1] == buttonClicked then
                      selected = getorderpos(m)
                      order[m][3] = order[m][3] + 1
                      found = true
                    end
                  end
                  if found == false then
                    selected = getorderpos(#order) + 1
                    table.insert(order, {buttonClicked, menu[l].price, 1, menu[l].contents})
                    selected = getorderpos(#order)
                  end
                  foreground()
                end
              end
            end
          end
        end
        )
      end
    end
  end
end
function boot()
  gpu.bind(dispScreen)
  gpu.setBackground(0x000000)
  logo(0.05, true)
  assigned = false
  event.listen("magData", magData)
  refreshButton("Admin")
  while assigned == false and halt == false do
    os.sleep()
    gpu.setForeground(mainTheme.text)
    gpu.set(sW-4, sH, os.date("%H:%M"))
  end
end
function background()
  gpu.setBackground(mainTheme.background)
  gpu.fill(1, 1, sW, sH, " ")
  gpu.fill(sW-29, 3, 2, sH-4, " ")
  gpu.setBackground(mainTheme.foreground)
  gpu.fill(5, 3, sW-8, sH-4, " ")
  gpu.setBackground(mainTheme.background)
  gpu.set(1, sH, "Created By EnragedStrings")
  gpu.fill(sW-27, 3, 2, sH-4, " ")
  gpu.fill(27, 3, 2, sH-4, " ")
end
function calcTotal()
  gpu.setBackground(mainTheme.foreground)
  subtotal = 0
  for i = 1, #order do
    subtotal = subtotal + (tonumber(order[i][2])*tonumber(order[i][3]))
  end
  total = math.floor((((subtotal*tax)+subtotal)*100)+0.5)/100
  gpu.setForeground(mainTheme.text)
  gpu.set(25-#(shorten(subtotal,2, true)), sH-8, currency..(shorten(subtotal,2, true)))
  gpu.set(25-#(shorten(tax*subtotal,2, true)), sH-7, (currency..shorten(tax*subtotal,2, true)))
  gpu.set(25-#format_int(string.format("%.2f",total)), sH-6, currency..format_int(string.format("%.2f",total)))
end
function getSelector(input)
  position = 0
  for i = 1, #order do
    if input >= position + 1 and 2 + #order[i][4] + position > input then
      orderpos = position + 1
      itemnum = i
    end
    position = position + #order[i][4] + 1
  end
  return(itemnum)
end
function getorderpos(ordernum)
  position2 = 0
  for i = 1, ordernum-1 do
    position2 = position2 + #order[i][4] + 1
  end
  return(position2+1)
end
function refreshOrder()
  gpu.setBackground(mainTheme.foreground)
  if getSelector(selected) > #order then
    selected = orderpos
  end
  gpu.setForeground(mainTheme.text)
  for i = 1, #order do
    data = getorderpos(i)
    if order[i][3] > 10^10 then
      order[i][3] = 1
    end
    if i == itemnum then
      gpu.setBackground(rgb(60,60,60))
      gpu.fill(6, 3+data, 20, 1, " ")
      if #order[i][4] > 0 then
        for j = 1, #order[i][4] do
          gpu.fill(6, data+j+3, 20, 1, " ")
        end
      end
    else
      gpu.setBackground(mainTheme.foreground)
      gpu.fill(6, 3+data, 20, 1, " ")
      if #order[i][4] > 0 then
        for j = 1, #order[i][4] do
          gpu.fill(6, data+j+3, 20, 1, " ")
        end
      end
    end
    if order[i][3] > 1  then
      gpu.set(6, 3+data, "("..shorten(order[i][3],1, false)..") "..order[i][1])
    else
      gpu.set(6, 3+data, order[i][1])
    end
    if #order[i][4] > 0 then
      for j = 1, #order[i][4] do
        if order[i][4][j][1] ~= "" then
          gpu.set(8, data+j+3, "("..shorten(order[i][4][j][2],1, false)..") "..order[i][4][j][1])
        else
          gpu.set(8, data+j+3, order[i][4][j][1])
        end
      end
    end
    price = tostring(shorten((tonumber(order[i][2])*tonumber(order[i][3])), 2, true))
    gpu.set(22-#price, 3+data, currency..price.."[-]")
  end
  calcTotal()
end
function foreground()
  menu = getMenu()
  gpu.setBackground(mainTheme.foreground)
  gpu.fill(5, 3, 22, sH-4, " ")
  gpu.set(6, sH-8, "Subtotal:")
  gpu.set(6, sH-7, "Tax: "..shorten(tax*100, 2, true).."%")
  gpu.set(6, sH-6, "Total:")
  gpu.setForeground(mainTheme.text)
  gpu.setBackground(rgb(10, 10, 10))
  gpu.setBackground(mainTheme.background)
  gpu.set(1, sH, "Created By EnragedStrings | User: "..string.upper(currentUser).." | "..string.upper(usrLvl))
  if usrLvl == "owner" or usrLvl == "manager" then
    refreshButton("Mngr Func")
  end
  refreshOrder()
  refreshButtons({"Mngr Func", "New User", "Cancel", "Reboot", "Stop POS", "Admin"})
end
function cnewUser()
  gpu.set(35, #users+8, "Input Card")
  os.sleep(2)
  writer.write("SMCP", newUser[1], true)
  gpu.set(35, #users+8, "Swipe Card")
  newswipe = true
  while newswipe == true do
    os.sleep()
  end
  background()
  mngr = false
  foreground()
end
function getTax(ServerID)
  token=apiKey
  headers = {
    access_token=token
  } 
  requeststring = ("http://69.164.205.86/GetTax/?serverID="..ServerID)
  local handle = internet.request(requeststring, {}, headers, "GET")
  return(handle())
end
function transaction(ServerID, pullfrom, pin, sendto, amount)
  token=apiKey
  headers = {
    access_token=token
  } 
  requeststring = ("http://69.164.205.86/"..ServerID.."/?cardNum="..pullfrom.."&pin="..pin.."&tcardNum="..sendto.."&tamnt="..amount)
  local handle = internet.request(requeststring, {}, headers, "GET")
  processing = false
  return(handle())
end
dependents()
tax = getTax(apiKey)

createButton((sW/2)-12, sH-5, 10, 3, buttonTheme.background, "Exit", false, true, buttonTheme.foreground, function()
  if assigned == true and pay == false and halt == false then
    if createcard == true then
      computer.shutdown(true)
    end
    mngr = false
    boot()
  end
end
)
createButton(2.5, sH-4, 3.5, 3, buttonTheme.c1, "Clear", false, true, buttonTheme.ct1, function()
  if assigned == true and pay == false and halt == false then
    order = {}
    background()
    foreground()
  end
end
)
createButton(6, sH-4, 4, 3, buttonTheme.c2, "Quant", false, true, buttonTheme.ct2, function()
  if assigned == true and pay == false and halt == false then
    if getSelector(selected) > #order then
      selected = orderpos
    end
    gpu.setForeground(mainTheme.foreground)
    gpu.setBackground(mainTheme.foreground)
    term.setCursor(5,3)
    qin = tonumber(io.read())
    qin = math.abs(qin)
    if qin > 10^10 then
      qin = 10^8
    end
    quan = qin
    if (math.floor(quan*100))/100 == 0 then
      quan = 1
    end
    if (math.floor(order[itemnum][3]*100))/100 == 0 then
      order[itemnum][3] = 1
    end
    order[itemnum][3] = order[itemnum][3] * quan
    background()
    foreground()
  end
end
)
createButton(10, sH-4, 3.5, 3, buttonTheme.c3, "Pay", false, true, buttonTheme.ct3, function()
  if assigned == true and pay == false and halt == false then
    pay = true
    pwidth = 50
    pheight = 8
    gpu.setBackground(mainTheme.background)
    gpu.fill(pwidth, pheight, sW-(pwidth*2), sH-(pheight*2), " ")
    gpu.setBackground(mainTheme.foreground)
    gpu.fill(pwidth+2, pheight+1, sW-(pwidth*2)-4,sH-(pheight*2)-2, " ")
    gpu.set((sW/2)-3.5, pheight+2, "Payment:")
    gpu.set(((sW/2)-(#format_int(string.format("%.2f",total)))/2)-1, pheight+3, currency..format_int(string.format("%.2f",total)))
    refreshButton("Cancel")
    gpu.setBackground(mainTheme.foreground)
    gpu.set((sW/2)-9, pheight+4, "Please Swipe Card.")
    
  end
end
)
createButton((sW/4)-5, sH-(13), 10, 3, buttonTheme.c1, "Cancel", false, true, buttonTheme.ct1, function()
  if assigned == true and pay == true then
    pay = false
    processing = false
    background()
    foreground()
  end
end
)
createButton(17, sH-6, 15.5, 3, buttonTheme.background, "New User", false, true, buttonTheme.foreground, function()
  if mngr == true and pay == false then
    gpu.setBackground(mainTheme.foreground)
    gpu.setForeground(mainTheme.text)
    term.setCursor(35, #users+7)
    newUser = Split(io.read().." ", " ")
    newUser[2] = string.lower(newUser[2])
    if newUser[2] ~= "employee" and newUser[2] ~= "owner" and newUser[2] ~= "manager" then
      newUser[2] = "employee"
    end
    if usrLvl == "manager" then
      if newUser[2] == "employee" then
        cnewUser()
      end
    else
      cnewUser()
    end
  end
end
)
createButton(34.5, 4, 15.5, 3, buttonTheme.background, "Reboot", false, true, buttonTheme.foreground, function()
  if mngr == true and pay == false then
    computer.shutdown(true)
  end
end
)
createButton(34.5, 8, 15.5, 3, buttonTheme.background, "Stop POS", false, true, buttonTheme.foreground, function()
  if mngr == true and pay == false and usrLvl == "owner" then
    gpu.setBackground(0x000000)
    term.clear()
    halt = true
    event.ignore("touch")
    event.ignore("magData")
  end
end
)
createButton((sW/2)-12, 4, 10, 3, buttonTheme.background, "Mngr Func", false, true, buttonTheme.foreground, function()
  if assigned == true and pay == false and halt == false then
    if usrLvl == "owner" or usrLvl == "manager" then
      if mngr == false then
        mngr = true
        gpu.setForeground(mainTheme.text)
        gpu.setBackground(rgb(80,80,80))
        gpu.fill(29, 3, sW-56, sH-4, " ")
        gpu.setBackground(mainTheme.background)
        gpu.fill(32, 4, 35, sH-6, " ")
        gpu.setBackground(mainTheme.foreground)
        gpu.fill(34, 5, 31, sH-8, " ")
        gpu.set(35, 5, "Employees:")
        refreshButton("New User")
        refreshButton("Reboot")
        if usrLvl == "owner" then
          refreshButton("Stop POS")
        end
        gpu.setBackground(mainTheme.foreground)
        gpu.setForeground(mainTheme.text)
        for i = 1, #users do
          gpu.set(35, 6+i, users[i][2].." | "..users[i][3])
          if users[i][2] ~= currentUser or currentUser == "defaultUser" then
            if usrLvl == "manager" and users[i][3] == "employee" then
              gpu.set(61, 6+i, "[-]")
            elseif usrLvl == "owner" then
              gpu.set(61, 6+i, "[-]")
            end
          end
        end
      else
        mngr = false
        background()
        foreground()
      end
    end
  end
end
)
createButton(0.5, 1, 1, 1, 0x000000, "Admin", false, false, 0x000000, function()
  if assigned == false then
    term.clear()
    print("Input Code:")
    code = io.read()
    token=apiKey
    headers = {
      access_token=token
    } 
    requeststring = ("http://69.164.205.86/admin/"..code)
    local handle = internet.request(requeststring, {}, headers, "GET")
    coderesult = handle()
    if string.find(coderesult, "Granted") then
      gpu.setBackground(0x000000)
      term.clear()
      halt = true
      event.ignore("touch")
      event.ignore("magData")
    else
      boot()
    end
  end
end
)

event.listen("touch", mouseClick)
createMenu()
boot()

while halt == false do
    os.sleep()
    gpu.setBackground(mainTheme.background)
    gpu.setForeground(mainTheme.text)
    gpu.set(sW-4, sH, os.date("%H:%M"))
end
