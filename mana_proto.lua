-- wget -f 'https://pastebin.com/raw/3HhQgnWb' mana.lua

local component = require("component")
local sides = require("sides")
local colors = require("colors")
local rs = component.redstone

-- sides & colors
local dispenserColor = colors.red
local pressurePlateColor = colors.lime
local manaPoolColor = colors.blue

-- interactions
function isPressureOnPlate(side) return rs.getBundledInput(side, pressurePlateColor) > 0 end
function getManaQuantity(side) return rs.getBundledInput(side, manaPoolColor) end
function isManaPoolFull(side) return rs.getBundledInput(side, manaPoolColor) >= 240 end
function sendCoal(side)
    rs.setBundledOutput(side, dispenserColor, 0)
    rs.setBundledOutput(side, dispenserColor, 250)
end

function feedCoalIfNeeded(side)
    print("Check the side " .. sides[side])
    print("Plate pressure: " .. tostring(isPressureOnPlate(side)))
    print("Mana quantity: " .. getManaQuantity(side) .. ", full: " .. tostring(isManaPoolFull(side)))
    if isPressureOnPlate(side) or isManaPoolFull(side) then
        print("Coal already there (" .. tostring(isPressureOnPlate(side)) .. ") or mana already full (" .. tostring(isManaPoolFull(side)) .. ")")
    else
        print("Send a coal")
        sendCoal(side)
    end
end

-- main
print("The Great Mana Pool Program v1")
print("")

while true do
    feedCoalIfNeeded(sides.front)
    os.sleep(0.5)
end
