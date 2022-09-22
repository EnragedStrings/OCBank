function rgb(r,g,b)
    local rgb = (r * 0x10000) + (g * 0x100) + b
    return tonumber((rgb))
  end

local items = 
{
    {
        itemName = "T1 PC",
        contents = {
            {"T1 Case", 1},
            {"T1 Screen", 1},
            {"T1 CPU", 1},
            {"T1.5 Mem Cards", 2},
            {"T1 Card", 2},
            {"T1 HDD", 1},
            {"EEPROM", 1},
            {"Keyboard", 1},
            {"", 1}
        },
        price = 100.00,
        background = rgb(0, 40, 95),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T2 PC",
        contents = {
            {"T2 Case", 1},
            {"T2 Screen", 1},
            {"T2 CPU", 1},
            {"T2.5 Mem Cards", 2},
            {"T2 Card", 1},
            {"T1 Card", 1},
            {"T2 HDD", 1},
            {"T1 HDD", 1},
            {"EEPROM", 1},
            {"Keyboard", 1},
            {"", 1}
        },
        price = 250.00,
        background = rgb(0, 50, 130),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T3 PC",
        contents = {
            {"T3 Case", 1},
            {"T3 Screen", 1},
            {"T3 CPU", 1},
            {"T3.5 Mem Cards", 2},
            {"T3 Card", 1},
            {"T2 Card", 2},
            {"T3 HDD", 1},
            {"T2 HDD", 1},
            {"Floppy Disc", 1},
            {"EEPROM", 1},
            {"Keyboard", 1},
            {"", 1}
        },
        price = 500.00,
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T1 Scrn",
        contents = {},
        price = 10.00,
        background = rgb(0, 40, 95),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T2 Scrn",
        contents = {},
        price = 50.00,
        background = rgb(0, 50, 130),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T3 Scrn",
        contents = {},
        price = 100.00,
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T1 Srvr",
        contents = {
            {"T1 Server", 1},
            {"T2 CPU", 1},
            {"T2.5 Mem Cards", 2},
            {"T2 Card", 2},
            {"T2 HDD", 2},
            {"T2 BUS", 1},
            {"EEPROM", 1},
            {"", 1}
        },
        price = 250.00,
        background = rgb(0, 40, 95),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T2 Srvr",
        contents = {
            {"T2 Server", 1},
            {"T3 CPU", 1},
            {"T3.5 Mem Cards", 3},
            {"T3 Card", 1},
            {"T2 Card", 2},
            {"T3 HDD", 3},
            {"T3 BUS", 2},
            {"EEPROM", 1},
            {"", 1}
        },
        price = 400.00,
        background = rgb(0, 50, 130),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T3 Srvr",
        contents = {
            {"T3 Server", 1},
            {"T3 CPU", 1},
            {"T3.5 Mem Cards", 4},
            {"T3 Card", 2},
            {"T2 Card", 2},
            {"T3 HDD", 4},
            {"T3 BUS", 3},
            {"EEPROM", 1},
            {"", 1}
        },
        price = 800.00,
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T1 GPU",
        contents = {},
        price = 50.00,
        background = rgb(0, 40, 95),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T2 GPU",
        contents = {},
        price = 100.00,
        background = rgb(0, 50, 130),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T3 GPU",
        contents = {},
        price = 200.00,
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T1 Data",
        contents = {},
        price = 25.00,
        background = rgb(0, 40, 95),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T2 Data",
        contents = {},
        price = 50.00,
        background = rgb(0, 50, 130),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T3 Data",
        contents = {},
        price = 100.00,
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T1 BUS",
        contents = {},
        price = 1.00,
        background = rgb(0, 40, 95),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T2 BUS",
        contents = {},
        price = 5.00,
        background = rgb(0, 50, 130),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T3 BUS",
        contents = {},
        price = 10.00,
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T1 Card",
        contents = {},
        price = 10.00,
        background = rgb(0, 40, 95),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T2 Card",
        contents = {},
        price = 25.00,
        background = rgb(0, 50, 130),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "T3 Card",
        contents = {},
        price = 50.00,
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "Term Srvr",
        contents = {},
        price = 1000.00,
        background = rgb(0, 0, 0),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "Adapter",
        contents = {},
        price = 25.00,
        background = rgb(0, 0, 0),
        defaultCode = true,
        code = function()
            --code here
        end
    },
    {
        itemName = "Cable",
        contents = {},
        price = 0.05,
        background = rgb(0, 0, 0),
        defaultCode = true,
        code = function()
            --code here
        end
    }
}

function getMenu()
    return(items)
end
