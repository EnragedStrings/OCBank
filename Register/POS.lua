computer = require("computer")
magReader = require("component").os_magreader
writer = require("component").os_cardwriter
component = require("component")
gpu = require("component").gpu
event = require("event")
internet = require("internet")
term = require("term")
serialization = require("serialization")
shell = require("shell")
fs = require("filesystem")
sW, sH = gpu.getResolution()
function rgb(r,g,b)
  local rgb = (r * 0x10000) + (g * 0x100) + b
  return tonumber((rgb))
end


local file = assert(io.open("/home/.shrc", "w"))
file:write("POS.lua")
file:close()

order = {}
buttons = {}
functions = {}
items = {}
columns = 4
rowH = 3
mWidth = (sW/2) - 28
itemGap = 1
itemWidth = (mWidth-((columns+1)*itemGap))/columns
tax = 0.101
total = 0
subtotal = 0
selected = 0
mngr = false
isMngr = false
createcard = false
currency = "$"

screenDir = ("/home/screens.txt")
userDir = ("/home/users.txt")
menuDir = ("/home/menu.lua")
orderDir = ("/home/orders.txt")
apiKeyDir = ("/home/apiKey.txt")
verDir = ("/home/version.txt")

buttonTheme = {
  background = rgb(5, 63, 150),
  foreground = rgb(255,255,255),
  c1 = rgb(255,0,0),
  c2 = rgb(0,0,255),
  c3 = rgb(0,255,0),
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

local screens = {}
for address, name in component.list("screen", false) do
  table.insert(screens, component.proxy(address))
end
multiscreen = false
function Split(s, delimiter)
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
  if assigned == false then
    for i = 1, #users do
      if users[i][1] == cardUniqueId or users[i][1] == "nil" then
        if users[i][2] == "defaultUser" or users[i][1] == cardUniqueId then
          assigned = true
          currentUser = users[i][2]
          usrLvl = users[i][3]
          background(custScreen)
          background(empScreen)
          foreground(empScreen)
          foreground(custScreen)
        end
      end
    end
  elseif newMemeberCard == true then
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
  end
end
function multi(screenc)
  if multiscreen == true and screenc ~= nil then
    gpu.bind(screenc)
  end
end
function screenSetup()
  term.clear()
  print("If current screen is employee screen, enter '1'. Else, enter '2'")
  pickedScreen = tostring(io.read())
  while pickedScreen ~= "1" and pickedScreen ~= "2" do
    term.clear()
    print("If current screen is employee screen, enter '1'. Else, enter '2'")
    print("Invalid Input")
    pickedScreen = tostring(io.read())
  end
  for i = 1, #screens do
    if gpu.getScreen() == screens[i].address and pickedScreen == "1" then
      for j = 1, #screens do
        if i == j then
          firstScreen = screens[j].address
        else
          secondScreen = screens[j].address
        end
      end
    elseif gpu.getScreen() == screens[i].address and pickedScreen == "2" then
      for j = 1, #screens do
        if i == j then
          secondScreen = screens[j].address
        else
          firstScreen = screens[j].address
        end
      end
    end
  end
  local file = assert(io.open(screenDir, "w"))
  file:write(firstScreen.."\n"..secondScreen)
  file:close()
  computer.shutdown(true)
end
function dependents()
  if fs.exists(screenDir) == true then
    local file = assert(io.open(screenDir))
    pScreens = Split(file:read(10000), "\n")
    file:close()
    if pScreens ~= nil then
      trip = false
      for i = 1, 2 do
        if component.proxy(pScreens[i]) == nil then
          trip = true
        end
      end
      if trip == true then
        if #screens > 1 then
          screenSetup()
        end
      else
        multiscreen = true
        empScreen = pScreens[1]
        custScreen = pScreens[2]
      end
    else
      if #screens > 1 then
        screenSetup()
      end
    end
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
    apiKey = file:read(100000)
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
      local file = assert(io.open(apiKeyDir, "w"))
      file:write(apiKey)
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
  if address == custScreen then
  else
    if button == 0 then
      if x >= 61 and 64 > x and y > 6 and 30 > y then
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
            background(empScreen)
            mngr = false
            foreground(empScreen)
          end
        end
      elseif x >= 6 and 23 > x and y > 3 and 30 > y then
        selected = y - 3
        foreground(empScreen)
        foreground(custScreen)
      elseif x >= 23 and 26 > x and y > 3 and 30 > y then
        if order[y-3] ~= nil then
          if order[y-3][3] > 1 then
            order[y-3][3] = order[y-3][3] - 1
          else
            table.remove(order, y-3)
          end
        end
        foreground(empScreen)
        foreground(custScreen)
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
function logo(time, color, lscreen)
  multi(lscreen)
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
        createButton((15+itemGap)+((itemWidth+itemGap)*(j-1)), 4+((itemGap+rowH)*(i-1)), itemWidth, rowH, buttonTheme.background, menu[pos].itemName, false, true, buttonTheme.foreground, function()
          if assigned == true and mngr == false then
            for l = 1, #menu do
              if menu[l].itemName == buttonClicked then
                menu[l].code()
                found = false
                for m = 1, #order do
                  if order[m][1] == buttonClicked then
                    selected = m
                    order[m][3] = order[m][3] + 1
                    found = true
                  end
                end
                if found == false then
                  selected = #order + 1
                  table.insert(order, {buttonClicked, menu[i].price, 1})
                end
                foreground(empScreen)
                foreground(custScreen)
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
  multi(empScreen)
  gpu.setBackground(0x000000)
  if custScreen ~= nil then
    logo(0.05, true, custScreen)
  end
  logo(0.05, true, empScreen)
  assigned = false
  event.listen("magData", magData)
  while assigned == false do
    os.sleep()
    gpu.setForeground(mainTheme.text)
    gpu.set(sW-4, sH, os.date("%H:%M"))
  end
end
function background(bscreen)
  multi(bscreen)
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
  if gpu.getScreen() == custScreen then
    gpu.set(25-#(shorten(subtotal,2, true)), sH-5, currency..(shorten(subtotal,2, true)))
    gpu.set(25-#(shorten(tax*subtotal,2, true)), sH-4, (currency..shorten(tax*subtotal,2, true)))
    gpu.set(25-#format_int(string.format("%.2f",total)), sH-3, currency..format_int(string.format("%.2f",total)))
  else
    gpu.set(25-#(shorten(subtotal,2, true)), sH-8, currency..(shorten(subtotal,2, true)))
    gpu.set(25-#(shorten(tax*subtotal,2, true)), sH-7, (currency..shorten(tax*subtotal,2, true)))
    gpu.set(25-#format_int(string.format("%.2f",total)), sH-6, currency..format_int(string.format("%.2f",total)))
  end
end
function refreshOrder(screen)
  multi(screen)
  gpu.setBackground(mainTheme.foreground)
  if selected > #order then
    selected = #order
  end
  gpu.setForeground(mainTheme.text)
  for i = 1, #order do
    if order[i][3] > 10^10 then
      order[i][3] = 1
    end
    if i == selected then
      gpu.setBackground(rgb(60,60,60))
      gpu.fill(6, 3+i, 20, 1, " ")
    else
      gpu.setBackground(mainTheme.foreground)
      gpu.fill(6, 3+i, 20, 1, " ")
    end
    if order[i][3] > 1  then
      gpu.set(6, 3+i, "("..shorten(order[i][3],1, false)..") "..order[i][1])
    else
      gpu.set(6, 3+i, order[i][1])
    end
    price = tostring(shorten((tonumber(order[i][2])*tonumber(order[i][3])), 2, true))
    if gpu.getScreen() ~= custScreen then
      gpu.set(22-#price, 3+i, currency..price.."[-]")
    else
      gpu.set(25-#price, 3+i, currency..price)
    end
  end
  calcTotal()
end
function foreground(fscreen)
  multi(fscreen)
  menu = getMenu()
  gpu.setBackground(mainTheme.foreground)
  if gpu.getScreen() ~= custScreen then
    gpu.fill(5, 3, 22, sH-7, " ")
  else
    gpu.fill(5, 3, 22, sH-4, " ")
  end
  if gpu.getScreen() == custScreen then
    gpu.set(6, sH-5, "Subtotal:")
    gpu.set(6, sH-4, "Tax: "..shorten(tax*100, 2, true).."%")
    gpu.set(6, sH-3, "Total:")
  else
    gpu.set(6, sH-8, "Subtotal:")
    gpu.set(6, sH-7, "Tax: "..shorten(tax*100, 2, true).."%")
    gpu.set(6, sH-6, "Total:")
  end
  gpu.setForeground(mainTheme.text)
  if fscreen == empScreen then
    gpu.setBackground(rgb(10, 10, 10))
    gpu.setBackground(mainTheme.background)
    gpu.set(1, sH, "Created By EnragedStrings | User: "..string.upper(currentUser).." | "..string.upper(usrLvl))
    if usrLvl == "owner" or usrLvl == "manager" then
      refreshButton("Mngr Func")
    end
    refreshOrder(fscreen)
    refreshButtons({"Mngr Func", "New User"})
  end
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
  background(empScreen)
  mngr = false
  foreground(empScreen)
end
dependents()

createButton((sW/2)-12, sH-5, 10, 3, buttonTheme.background, "Exit", false, true, buttonTheme.foreground, function()
  if assigned == true then
    if createcard == true then
      computer.shutdown(true)
    end
    mngr = false
    boot()
  end
end
)
createButton(2.5, sH-4, 3.5, 3, buttonTheme.c1, "Clear", false, true, buttonTheme.ct1, function()
  if assigned == true then
    order = {}
    background(empScreen)
    background(custScreen)
    foreground(empScreen)
    foreground(custScreen)
  end
end
)
createButton(6, sH-4, 4, 3, buttonTheme.c2, "Quant", false, true, buttonTheme.ct2, function()
  if assigned == true then
    multi(empScreen)
    if #order >= selected then
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
      if (math.floor(order[selected][3]*100))/100 == 0 then
        order[selected][3] = 1
      end
      order[selected][3] = order[selected][3] * quan
      background(empScreen)
      background(custScreen)
      foreground(empScreen)
      foreground(custScreen)
    end
  end
end
)
createButton(10, sH-4, 3.5, 3, buttonTheme.c3, "Pay", false, true, buttonTheme.ct3, function()
  if assigned == true then
  end
end
)
createButton(17, sH-6, 15.5, 3, buttonTheme.background, "New User", false, true, buttonTheme.foreground, function()
  if mngr == true then
    multi(empScreen)
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
createButton((sW/2)-12, 4, 10, 3, buttonTheme.background, "Mngr Func", false, true, buttonTheme.foreground, function()
  if assigned == true then
    if usrLvl == "owner" or usrLvl == "manager" then
      if mngr == false then
        mngr = true
        multi(empScreen)
        gpu.setForeground(mainTheme.text)
        gpu.setBackground(rgb(80,80,80))
        gpu.fill(29, 3, sW-56, sH-4, " ")
        gpu.setBackground(mainTheme.background)
        gpu.fill(32, 4, 35, sH-6, " ")
        gpu.setBackground(mainTheme.foreground)
        gpu.fill(34, 5, 31, sH-8, " ")
        gpu.set(35, 5, "Employees:")
        refreshButton("New User")
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
        background(empScreen)
        foreground(empScreen)
      end
    end
  end
end
)

createMenu()
boot()

event.listen("touch", mouseClick)

while true do
    os.sleep(0.1)
    gpu.setBackground(mainTheme.background)
    gpu.setForeground(mainTheme.text)
    gpu.set(sW-4, sH, os.date("%H:%M"))
end
