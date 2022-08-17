component = require("component")
gpu = require("component").gpu
term = require("term")
data = require("component").data
serialization = require("serialization")
colors = require("colors")

local screens = {}
for address, name in component.list("screen", false) do
  table.insert(screens, component.proxy(address))
end

function drawLine(screenID, val2, val3, val4, val5, val6, val7)
    gpu.bind(screenID)
    screen, x0, y0, x1, y1, color, thickness = screenID, val2*2, val3, val4*2, val5, val6, val7
    dx = math.abs(x1 - x0)
    dy = math.abs(y1 - y0)
    if x1 > x0 then
        sx = 1
    else
        sx = -1
    end
    if y1 > y0 then
        sy = 1
    else
        sy = -1
    end
    err = dx - dy
    while x0 ~= x1 or y0 ~= y1 and 200 > x0 and 200 > y0 and x0 > -50 and y0 > -50 do
        gpu.setBackground(color)
        gpu.set(x0, y0, "  ")
        e2 = 2*err
        if e2 > -dy then
            err = err - dy
            x0 = x0 + sx
        end
        if e2 < dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
    gpu.setBackground(prevBack)
end

function getScreens()
    return screens
end


function drawShape(type, screenID, val2, val3, val4, val5, val6, val7, val8, val9, val10)
    prevBack = gpu.getBackground()
    gpu.bind(screenID)
    if type == "line" then
        drawLine(screenID, val2, val3, val4, val5, val6, val7)
    elseif type == "triangle" then
        screen, tx1, ty1, tx2, ty2, tx3, ty3, color, outline, bs = screenID, val2, val3, val4, val5, val6, val7, val8, val9, val10
        drawLine(screen, tx1, ty1, tx2, ty2, color)
        drawLine(screen, tx2, ty2, tx3, ty3, color)
        drawLine(screen, tx1, ty1, tx3, ty3, color)
        if outline == "fill" or outline == nil then
            txmax = math.max(tx1, tx2, tx3)
            tymax = math.max(ty1, ty2, ty3)
            txmin = math.min(tx1, tx2, tx3)
            tymin = math.min(ty1, ty2, ty3)
            tlc = (math.max(txmax, tymax) - math.min(txmin, tymin))/2
        else
            txmax = math.max(tx1, tx2, tx3)
            tymax = math.max(ty1, ty2, ty3)
            txmin = math.min(tx1, tx2, tx3)
            tymin = math.min(ty1, ty2, ty3)
            if bs ~= nil then
                tlc = bs - 1
            else
                tlc = 0
            end
        end
        for i = 1, tlc do
            txmax = math.max(tx1, tx2, tx3)
            tymax = math.max(ty1, ty2, ty3)
            txmin = math.min(tx1, tx2, tx3)
            tymin = math.min(ty1, ty2, ty3)
            if tx1 == txmax then
                tx1 = tx1 - 1
            end
            if tx2 == txmax then
                tx2 = tx2 - 1
            end
            if tx3 == txmax then
                tx3 = tx3 - 1
            end

            if tx1 == txmin then
                tx1 = tx1 + 1
            end
            if tx2 == txmin then
                tx2 = tx2 + 1
            end
            if tx3 == txmin then
                tx3 = tx3 + 1
            end


            if ty1 == tymax then
                ty1 = ty1 - 1
            end
            if ty2 == tymax then
                ty2 = ty2 - 1
            end
            if ty3 == tymax then
                ty3 = ty3 - 1
            end

            if ty1 == tymin then
                ty1 = ty1 + 1
            end
            if ty2 == tymin then
                ty2 = ty2 + 1
            end
            if ty3 == tymin then
                ty3 = ty3 + 1
            end
            drawLine(screen, tx1, ty1, tx2, ty2, color)
            drawLine(screen, tx2, ty2, tx3, ty3, color)
            drawLine(screen, tx1, ty1, tx3, ty3, color)
        end
        gpu.setBackground(prevBack)
    elseif type == "box" then
        local screen, x, y, w, h, color, a, outline, thickness = screenID, val2, val3, val4, val5, val6, val7, val8, val9
        if a == nil or math.fmod(a, 180) == 0 then
            if outline == "fill" or outline == nil then
                gpu.setBackground(color)
                gpu.fill(x*2, y, w*2, h, " ")
                gpu.setBackground(prevBack)
            else
                if thickness == nil or thickness == 0 then
                    thickness = 1
                end
                gpu.setBackground(color)
                gpu.fill(x*2, y, thickness*2, h, " ")
                gpu.fill(x*2+w*2-thickness*2, y, thickness*2, h, " ")
                gpu.fill(x*2, y, w*2, thickness, " ")
                gpu.fill(x*2, (y+h)-thickness, w*2, thickness, " ")
                gpu.setBackground(prevBack)
            end
        else
            x1 = x
            y1 = y
            x2 = x + w
            y2 = y
            x3 = x + w
            y3 = y + h
            x4 = x
            y4 = y + h

            Ox = x + (w/2)
            Oy = y + (h/2)

            tempX1 = x1 - Ox
            tempY1 = y1 - Oy

            tempX2 = x2 - Ox
            tempY2 = y2 - Oy

            tempX3 = x3 - Ox
            tempY3 = y3 - Oy

            tempX4 = x4 - Ox
            tempY4 = y4 - Oy
            a = math.rad(a)
            rotatedX1 = tempX1*math.cos(a) - tempY1*math.sin(a)
            rotatedY1 = tempX1*math.sin(a) + tempY1*math.cos(a)

            rotatedX2 = tempX2*math.cos(a) - tempY2*math.sin(a)
            rotatedY2 = tempX2*math.sin(a) + tempY2*math.cos(a)

            rotatedX3 = tempX3*math.cos(a) - tempY3*math.sin(a)
            rotatedY3 = tempX3*math.sin(a) + tempY3*math.cos(a)

            rotatedX4 = tempX4*math.cos(a) - tempY4*math.sin(a)
            rotatedY4 = tempX4*math.sin(a) + tempY4*math.cos(a)

            ax1 = math.floor((rotatedX1 + Ox)+0.5)
            ay1 = math.floor((rotatedY1 + Oy)+0.5)

            ax2 = math.floor((rotatedX2 + Ox)+0.5)
            ay2 = math.floor((rotatedY2 + Oy)+0.5)

            ax3 = math.floor((rotatedX3 + Ox)+0.5)
            ay3 = math.floor((rotatedY3 + Oy)+0.5)

            ax4 = math.floor((rotatedX4 + Ox)+0.5)
            ay4 = math.floor((rotatedY4 + Oy)+0.5)

            if outline == "fill" or outline == nil then
                bxmax = math.max(ax1, ax2, ax3, ax4)
                bymax = math.max(ay1, ay2, ay3, ay4)
                bxmin = math.min(ax1, ax2, ax3, ax4)
                bymin = math.min(ay1, ay2, ay3, ay4)
                blc = (math.max(bxmax, bymax) - math.min(bxmin, bymin))/2
            else
                if thickness == nil or thickness == 0 then
                    thickness = 1
                end
                blc = thickness - 1
                gpu.setBackground(0xFF0000)  
                drawLine(screen, ax1, ay1, ax2, ay2, color)
                drawLine(screen, ax2, ay2, ax3, ay3, color)
                drawLine(screen, ax3, ay3, ax4, ay4, color)
                drawLine(screen, ax4, ay4, ax1, ay1, color)
                gpu.setBackground(prevBack)
            end
            for i = 1, blc do
                bxmax = math.max(ax1, ax2, ax3, ax4)
                bymax = math.max(ay1, ay2, ay3, ay4)
                bxmin = math.min(ax1, ax2, ax3, ax4)
                bymin = math.min(ay1, ay2, ay3, ay4)
                if ax1 == bxmax then
                    ax1 = ax1 - 1
                end
                if ax2 == bxmax then
                    ax2 = ax2 - 1
                end
                if ax3 == bxmax then
                    ax3 = ax3 - 1
                end
                if ax4 == bxmax then
                    ax4 = ax4 - 1
                end

                if ax1 == bxmin then
                    ax1 = ax1 + 1
                end
                if ax2 == bxmin then
                    ax2 = ax2 + 1
                end
                if ax3 == bxmin then
                    ax3 = ax3 + 1
                end
                if ax4 == bxmin then
                    ax4 = ax4 + 1
                end

                if ay1 == bymax then
                    ay1 = ay1 - 1
                end
                if ay2 == bymax then
                    ay2 = ay2 - 1
                end
                if ay3 == bymax then
                    ay3 = ay3 - 1
                end
                if ay4 == bymax then
                    ay4 = ay4 - 1
                end

                if ay1 == bymin then
                    ay1 = ay1 + 1
                end
                if ay2 == bymin then
                    ay2 = ay2 + 1
                end
                if ay3 == bymin then
                    ay3 = ay3 + 1
                end
                if ay4 == bymin then
                    ay4 = ay4 + 1
                end
                drawLine(screen, ax1, ay1, ax2, ay2, color)
                drawLine(screen, ax2, ay2, ax3, ay3, color)
                drawLine(screen, ax3, ay3, ax4, ay4, color)
                drawLine(screen, ax4, ay4, ax1, ay1, color)
            end
            gpu.setBackground(prevBack)
        end
    elseif type == "circle" then
        local screen, x, y, d, color, outline, thickness = screenID, val2*2, val3, val4, val5, val6, val7
        for i = 1, d do -- Row
            for j = 1, d do -- Column
                if tostring(j) == tostring(d) or tostring(i) == tostring(d) then
                else
                    local cD = math.sqrt((j-(d/2))^2 + (i-(d/2))^2)
                    if d/2.5 >= cD then
                        gpu.setBackground(color)
                        gpu.set(x+((j-1)*2), y+((i-1)), "  ")
                    end
                end
            end
        end
        gpu.setBackground(prevBack)
    end
end
function makeButton(name, screenID, x, y, w, h, textColor, blockColor)
    gpu.bind(screenID)
    prevBack = gpu.getBackground()
    x = x*2
    gpu.setBackground(blockColor)
    gpu.fill(x*2, y, w*2, h, " ")
    gpu.setForeground(textColor)
    gpu.set(x*2 + ((w*2-#name)/2), y + (h/2), name)
    gpu.setBackground(prevBack)
end

function setRes(x, y)
    gpu.setResolution(x, y)
end
