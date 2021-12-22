local component = require("component")
local sides = require("sides")
local colors = require("colors")
--local serialization = require("serialization")
local rs = component.redstone

-- redstone side
local side = sides.right

-- Class ManaPool
ManaPool = {
    colorQuantity = colors.white,
    colorDropper = colors.white,
    colorEnchantedItemDrawer = colors.white,
    itemToEnchantName = "notDefined"
}
function ManaPool:new (o, colorQuantity, colorDropper, colorEnchantedItemDrawer, itemToEnchantName)
    o = o or {}
    setmetatable(o, { __index = self })
    o.colorQuantity = colorQuantity or colors.white
    o.colorDropper = colorDropper or colors.white
    o.colorEnchantedItemDrawer = colorEnchantedItemDrawer or colors.white
    o.itemToEnchantName = itemToEnchantName or "notDefined";
    return o
end
function ManaPool:getQuantity()
    return rs.getBundledInput(side, self.colorQuantity)
end
function ManaPool:isManaFull()
    return rs.getBundledInput(side, self.colorQuantity) >= 240
end
function ManaPool:isManaEnoughToEnchantItem()
    return rs.getBundledInput(side, self.colorQuantity) >= 50
end
function ManaPool:dropItemToEnchant()
    rs.setBundledOutput(side, self.colorDropper, 0)
    rs.setBundledOutput(side, self.colorDropper, 250)
end
function ManaPool:getDrawerQuantity()
    return rs.getBundledInput(side, self.colorEnchantedItemDrawer)
end
function ManaPool:isEnchantedItemDrawerFull()
    return rs.getBundledInput(side, self.colorEnchantedItemDrawer) >= 240
end

-- colors
local coalDropperColor = colors.black
local pressurePlateColor = colors.lime
local manaPool1 = ManaPool:new(nil, colors.red, colors.cyan, colors.lightBlue, "Pearl")
local manaPool2 = ManaPool:new(nil, colors.blue, colors.purple, colors.yellow, "Diamond")
local manaPool3 = ManaPool:new(nil, colors.brown, colors.orange, colors.pink, "Iron -> ManaSteel")
local manaPools = { manaPool1, manaPool2, manaPool3 }

-- interactions
function isPressureOnPlate()
    return rs.getBundledInput(side, pressurePlateColor) > 0
end
function isManaPoolFull()
    return manaPool1:isManaFull() and manaPool2:isManaFull() and manaPool3:isManaFull()
end
function sendCoal()
    rs.setBundledOutput(side, coalDropperColor, 0)
    rs.setBundledOutput(side, coalDropperColor, 250)
end

function feedCoalIfNeeded()
    print("Check the side " .. sides[side])
    --print("entry "  .. serialization.serialize(rs.getInput()))
    print("Plate pressure: " .. tostring(isPressureOnPlate()))
    for i, manaPool in ipairs(manaPools) do
        print("ManaPool " .. i .. " mana quantity: " .. manaPool:getQuantity() .. ", full: " .. tostring(manaPool:isManaFull()) .. " drawer quantity " .. manaPool:getDrawerQuantity())
    end

    if isPressureOnPlate() or isManaPoolFull() then
        print("Coal already there (" .. tostring(isPressureOnPlate()) .. ") or mana already full (" .. tostring(isManaPoolFull()) .. ")")
    else
        print("Send a coal")
        sendCoal()
    end
end

function enchantItemsIfNeeded()
    for i, manaPool in ipairs(manaPools) do
        if  manaPool:isManaEnoughToEnchantItem() and not manaPool:isEnchantedItemDrawerFull() then
            print("ManaPool " .. i .. " send " .. manaPool.itemToEnchantName)
            manaPool:dropItemToEnchant()
        else
            print("ManaPool " .. i .. " should not enchant " .. manaPool.itemToEnchantName .. tostring(manaPool:isManaEnoughToEnchantItem()) .. tostring(manaPool:isEnchantedItemDrawerFull()))
        end
    end
end

-- main
print("The Great Mana Pool Program v1.1")
print("")

while true do
    feedCoalIfNeeded()
    enchantItemsIfNeeded()
    os.sleep(0.3)
end
