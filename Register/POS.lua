computer = require("computer")
magReader = require("component").os_magreader
writer = require("component").os_cardwriter
component = require("component")
gpu = require("component").gpu
event = require("event")
internet = require("internet")
serialization = require("serialization")
shell = require("shell")
fs = require("filesystem")

if fs.exists("/home/GUI.lua") == false then
    shell.execute("wget https://raw.githubusercontent.com/sziberov/OpenComputers/master/lib/json.lua")
  end
  require("GUI")
x = 160
y = 50

x = (x/2)+1
y = y
term.clear()

span = 5

tax = 0.1

local screens = {}
for address, name in component.list("screen", false) do
  table.insert(screens, component.proxy(address))
end

local magReaders = {}
for address, name in component.list("os_magreader", false) do
  table.insert(magReaders, component.proxy(address).address)
end

function Split(s, delimiter)
  result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      if match ~= nil then
        table.insert(result, match);
      end
  end
  return result;
end

dir = ("/home/screens.txt")
userDir = ("/home/users.txt")
menuDir = ("/home/menu.json")
orderDir = ("/home/orders.txt")
apiKeyDir = ("/home/apiKey.txt")
verDir = ("/home/version.txt")

term.clear()

local file = assert(io.open("/home/.shrc", "w"))
file:write("POS.lua")
file:close()

if fs.exists(verDir) == true then
  local file = assert(io.open(verDir))
  version = tonumber(file:read(100000))
  file:close()
  shell.execute("rm version.txt")
  shell.execute("wget https://raw.githubusercontent.com/EnragedStrings/OCBank/main/Register/version.txt")
  local file = assert(io.open(verDir))
  gitversion = tonumber(file:read(100000))
  file:close()
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
  end
  file:close()
else
  local file = assert(io.open(userDir, "w"))
  file:write("defaultUser owner")
  file:close()
  computer.shutdown(true)
end

assignedReader = nil
currentUser = nil
function magData(eventName, address, playerName, cardData, cardUniqueId, isCardLocked, side)
  if assignedReader == nil then
    assignedReader = address
  end
  if address == assignedReader then
    if pay == true then
      ccData = getCardData(cardData)
      gpu.bind(custScreen)
      gpu.setBackground(0x5A5A5A)
      gpu.set(76, 15, "Input Pin:")
      term.setCursor(76, 16)
      pin = io.read()
      gpu.fill(76, 15, 10, 2, " ")
      gpu.set(74, 15, "Authorizing...")
      gpu.bind(empScreen)
      gpu.setBackground(0x5A5A5A)
      gpu.fill(76, 15, 10, 2, " ")
      gpu.set(74, 15, "Authorizing...")
      ip1 = string.sub(data.sha256(pin), 0, 16)
      ip2 = string.sub(data.sha256(pin), 17, 32)
      ccDecrypt = Split(data.decrypt(ccData, ip1, ip2), ",")
      
    end
    if getAPI == true then
      apiKey = cardData
      local file = assert(io.open(apiKeyDir, "w"))
      file:write(apiKey)
      file:close()
      computer.shutdown(true)
      getAPI = false
    elseif currentUser == nil then
      for i = 1, #users do
        if Split(users[i], " ")[1] == cardData then
          currentUser = Split(users[i], " ")
          print("Active user: "..currentUser[1])
        end
      end
      print("Writer Assigned: "..address)
      event.ignore("magData", magData)
      if currentUser ~= nil then
        print("booting...")
        display()
      else
        print("No User Found!")
        event.listen("magData", magData)
      end
    end
  end
end

if fs.exists(apiKeyDir) == true then
  local file = assert(io.open(apiKeyDir))
  apiKey = file:read(100000)
  file:close()
else
  print("Use API Card? (Y/n)")
  if io.read() == "y" then
    getAPI = true
    event.listen("magData", magData)
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

if fs.exists("/home/json.lua") == false then
  shell.execute("wget https://raw.githubusercontent.com/sziberov/OpenComputers/master/lib/json.lua")
end
json = assert(loadfile "json.lua")()

if fs.exists(menuDir) == true then
  local file = assert(io.open(menuDir))
  menu = json:decode(file:read(100000))
  file:close()
else
  local file = assert(io.open(menuDir, "w"))
  file:close()
  computer.shutdown(true)
end

function screenSetup()
  if #screens == 2 then
    print("If current screen is employee screen, enter '1'. Else, enter '2'")
    pickedScreen = tostring(io.read())
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
    local file = assert(io.open(dir, "w"))
    file:write(firstScreen.."\n"..secondScreen)
    file:close()
    computer.shutdown(true)
  else
    print("Error: Must Have Two Screens")
  end
end

if fs.exists(dir) == true then
  local file = assert(io.open(dir))
  screen = Split(file:read(1000), "\n")
  if screen ~= nil then
    if component.proxy(screen[1]) == nil or component.proxy(screen[2]) == nil then
      file:write()
      file:close()
      screenSetup()
    else
      empScreen = screen[1]
      custScreen = screen[2]
      file:close()
    end
  else
    file:close()
    screenSetup()
  end
else
  screenSetup()
end

function background(screen)
  if screen == empScreen then
    drawShape("box", screen, 0, 1, x, y, 0x5A5A5A)
    drawShape("box", screen, 2, 3, x-4, y-4, 0x878787)
    drawShape("box", screen, 2, 7, 15, 1, 0x5A5A5A)
    drawShape("box", screen, 2, 45, 15, 1, 0x5A5A5A)
    drawShape("box", screen, 16, 3, 1, y-4, 0x5A5A5A)
    drawShape("box", screen, x-17, 3, 1, y-4, 0x5A5A5A)
    gpu.setBackground(0x5A5A5A)
    gpu.set(4,2,"Made By EnragedStrings | Active User: "..currentUser[1])
  elseif screen == custScreen then
    drawShape("box", screen, 0, 1, x, y, 0x5A5A5A)
    drawShape("box", screen, 2, 3, x-4, y-4, 0x878787)
    drawShape("box", screen, 17, 3, 1, y-4, 0x5A5A5A)
  end
end

function foreground(screen)
  if screen == empScreen then
    makeButton("Quantity", screen, 1, y-4, 4.5, 3, 0xFFFFFF, 0x0000FF)
    makeButton("Clear", screen, 3.25, y-4, 5, 3, 0xFFFFFF, 0xFF0000)
    makeButton("Pay", screen, 5.75, y-4, 4.5, 3, 0x000000, 0x00FF00)
    makeButton("Exit", screen, 33, 45, 12, 3, 0xFFFFFF, 0xFF0000)

    count = 0
    for k, v in pairs(menu.items) do
      count = count + 1
      local row = (math.floor((count - 1) / span))
      local column = (count % span) - 1
      if column == -1 then
          column = (span - 1)
      end
      if menu.items[k].contents ~= nil and menu.items[k].price > 0 then
        makeButton(k.." $"..menu.items[k].price, empScreen, 9.3 + (column * 4.5), 4 + (row*4), 8.5, 3, 0xFFFFFF, 0xFF0000)
      end
    end

    if currentUser[2] == "manager" or currentUser[2] == "owner" then
      makeButton("Mngr Functions", screen, 33, 4, 12, 3, 0xFFFFFF, 0xFF0000)
    end

    
  else
    
  end
end

function getCardData(ccData)
  local response = internet.request("http://69.164.205.86/"..apiKey.."/"..ccData)

  local content = ""
  for chunk in response.read do
    content = content .. chunk
  end
  
  return(content)
end

function updateOrders()
  gpu.bind(empScreen)
  gpu.setBackground(0x878787)
  gpu.fill(4,8,28, y-13, " ")
  if orders ~= nil then
    for i = 1, #orders do
      if 34 > (5+((i-1)*5))+4 then
        gpu.fill(5+((i-1)*5), 4, 4, 2, " ")
      end
    end
  end
  subtotal = 0
  if order ~= nil then
    for i = 1, #order[2] do
      if order[2][i][2] == nil or order[2][i][2] == 1 then
        gpu.set(6, 8+i, order[2][i][1])
      else
        gpu.set(6, 8+i, "("..order[2][i][2]..") "..order[2][i][1])
      end
      gpu.set(25 - #tostring(menu.items[order[2][i][1]].price), 8+i, "$"..menu.items[order[2][i][1]].price.." [-]")
      subtotal = subtotal + (menu.items[order[2][i][1]].price * order[2][i][2])
    end
  end

  taxa = math.floor(((subtotal * tax)*100)+0.5)/100
  total = subtotal + taxa

  gpu.set(6, y-9, "Subtotal:")
  gpu.set(6, y-8, "Tax ("..(tax*100).."%):")
  gpu.set(6, y-7, "Total:")
  gpu.set(29 - #tostring(subtotal), y-9, "$"..subtotal)
  gpu.set(29 - #tostring(taxa), y-8, "$"..taxa)
  gpu.set(29 - #tostring(total), y-7, "$"..total)

  gpu.bind(custScreen)
  gpu.setBackground(0x878787)
  gpu.fill(4,3,28, y-4, " ")
  if order ~= nil then
    for i = 1, #order[2] do
      if order[2][i][2] == nil or order[2][i][2] == 1 then
        gpu.set(6, 3+i, order[2][i][1])
      else
        gpu.set(6, 3+i, "("..order[2][i][2]..") "..order[2][i][1])
      end
      gpu.set(31 - #tostring(menu.items[order[2][i][1]].price), 3+i, "$"..menu.items[order[2][i][1]].price)
    end
  end
  gpu.set(6, y-5, "Subtotal:")
  gpu.set(6, y-4, "Tax ("..(tax*100).."%):")
  gpu.set(6, y-3, "Total:")
  gpu.set(31 - #tostring(subtotal), y-5, "$"..subtotal)
  gpu.set(31 - #tostring(taxa), y-4, "$"..taxa)
  gpu.set(31 - #tostring(total), y-3, "$"..total)

  gpu.bind(empScreen)
end

function display()
  background(empScreen)
  background(custScreen)
  foreground(empScreen)
  updateOrders()
end
gpu.bind(empScreen)

print("Please Swipe Card")
event.listen("magData", magData)

mng = false
pay = false
while true do
  local _, address, x, y, button, name = event.pull("touch")
  if button == 0 and tostring(address) == tostring(empScreen) then
    if 156 > x and x > 131 and 7 > y and y > 3 and pay == false then
      if currentUser[2] == "manager" or currentUser[2] == "owner" then
        if mng == false then
          mng = true
          drawShape("box", empScreen, 17, 3, 47, 46, 0x878787)
          drawShape("box", empScreen, 18, 4, 15, 44, 0x5A5A5A)
          makeButton("Add User", empScreen, 9, 45, 15, 3, 0x000000, 0x00FF00)
          for i = 1, #users do
            gpu.setForeground(0xFFFFFF)
            gpu.setBackground(0x5A5A5A)
            gpu.set(37, 4+i, Split(users[i], " ")[1])
            if Split(users[i], " ")[1] ~= currentUser[1] then
              if Split(users[i], " ")[2] ~= "manager" or currentUser[2] == "owner" then
                if Split(users[i], " ")[2] ~= "owner" or currentUser[2] == "owner" then
                  gpu.set(62, 4+i, "[-]")
                end
              end
            end
            if Split(users[i], " ")[2] == "manager" then
              gpu.set(53, 4+i, "Manager")
            elseif Split(users[i], " ")[2] == "owner" then
              gpu.set(53, 4+i, "Owner")
            else
              gpu.set(53, 4+i, "Employee")
            end
          end
        else
          mng = false
          display()
        end
      end
    elseif 156 > x and x > 131 and 48 > y and y > 44 and pay == false then
      computer.shutdown(true)
    elseif 66 > x and x > 36 and 48 > y and y > 44 and pay == false then
      gpu.setBackground(0)
      term.setCursor(37, 5 + #users)
      inputUser = io.read()
      inputUser = Split(inputUser, " ")
      if inputUser[2] ~= nil and currentUser[2] ~= "owner" then
        inputUser = inputUser[1].." Employee"
        inputUser = Split(inputUser, " ")
      end

      local file = assert(io.open(userDir))
      usersr = file:read(10000)
      file:close()
      local file = assert(io.open(userDir, "w"))
      if inputUser[2] ~= nil then
        file:write(usersr.."\n"..inputUser[1].." "..inputUser[2])
      else
        file:write(usersr.."\n"..inputUser[1].." employee")
      end
      file:close()
      if inputUser[2] == "manager" then
        writer.write(inputUser[1], "Manager Card: '"..inputUser[1].."'", false, 1)
      elseif inputUser[2] == "owner" then
        writer.write(inputUser[1], "Owner Card: '"..inputUser[1].."'", false, 4)
      else
        writer.write(inputUser[1], "Employee Card: '"..inputUser[1].."'", false, 3)
      end
      computer.shutdown(true)
    elseif 64 > x and x > 61 and 5 + #users > y and y > 4 and mng == true and pay == false then
      if Split(users[y-4], " ")[1] ~= currentUser[1] then
        if Split(users[y-4], " ")[2] ~= "manager" or currentUser[2] == "owner" then
          if Split(users[y-4], " ")[2] ~= "owner" or currentUser[2] == "owner" then
            table.remove(users, y-4)
            userString = nil
            for i = 1, #users do
              if i ~= 1 then
                userString = userString.."\n"..users[i]
              else
                userString = users[i]
              end
            end
            local file = assert(io.open(userDir, "w"))
            file:write(userString)
            file:close()
            computer.shutdown(true)
          end
        end
      end
    elseif 128 > x and x > 34 and 49 > y and y > 3 and pay == false then
      count = 0
      for k, v in pairs(menu.items) do
        count = count + 1
        local row = (math.floor((count - 1) / span))
        local column = (count % span) - 1
        if column == -1 then
            column = (span - 1)
        end
        if (54 + (column * 18)) > x and x > (36 + (column * 18)) and 4 + (row*4) + 3 > y and y > 3 + (row*4) and menu.items[k] ~= nil and pay == false then
          if order == nil then
            order = {}
            if orders == nil then
              orders = {}
            end
            order[1] = #orders + 1
            order[2] = {}
          end
          local found = false
          for i = 1, #order[2] do
            if order[2][i][1] == k then
              found = true
              order[2][i][2] = order[2][i][2] + 1
            end
          end
          if found == false then
            table.insert(order[2], {k, 1})
          end
          updateOrders()
        end
      end
    elseif x == 28 and 40 > y and y > 8 and pay == false then
      if order[2][y-8] ~= nil then
        if order[2][y-8][2] == nil or order[2][y-8][2] == 1 then
          table.remove(order[2], (y-8))
        else
          order[2][y-8][2] = order[2][y-8][2] - 1
        end
        updateOrders()
      end
    elseif y > 45 and 49 > y and pay == false then
      if x > 3 and 13 > x and order ~= nil then
        term.setCursor(1,1)
        order[2][#order[2]][2] = math.abs(order[2][#order[2]][2] * io.read())
        updateOrders()
        term.setCursor(1,1)
        gpu.setBackground(0x5A5A5A)
        gpu.fill(0, 1, 20, 1, " ")
      elseif x > 12 and 23 > x then
        order[2] = {}
        order[1] = {}
        updateOrders()
      elseif x > 22 and 32 > x then
        pay = true
        gpu.bind(custScreen)
        gpu.setBackground(0x5A5A5A)
        gpu.fill(55, 10, 50, 30, " ")
        gpu.set(77, 11, "Payment")
        gpu.set(72, 13, "Please Swipe Card")
        gpu.bind(empScreen)
        gpu.setBackground(0x5A5A5A)
        gpu.fill(55, 10, 50, 30, " ")
        gpu.set(77, 11, "Payment")
        gpu.set(73, 13, "Waiting For Card")
        makeButton("Cancel", empScreen, 17.5, 36, 10, 3, 0xFFFFFF, 0xFF0000)
        event.listen("magData", magData)
      end
    elseif x > 69 and 90 > x and y > 35 and 39 > y and pay == true then
      pay = false
      display()
    end
  end
end
