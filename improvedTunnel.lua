-- This is based on the turtle/tunnel program that is included.
-- It adds support for placing torches every 8 blocks, and dumping inventory of turtle to enderchest when full.

if not turtle then
    printError("Requires a Turtle")
    return
end

local tArgs = { ... }
if #tArgs ~= 1 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length>")
    return
end

-- Mine in a quarry pattern until we hit something we can't dig
local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
end
local collected = 0

local function collect()
    collected = collected + 1
    if math.fmod(collected, 25) == 0 then
        print("Mined " .. collected .. " items.")
    end
end

local function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            collect()
            sleep(0.1)
        else
            return false
        end
    end
    return true
end

local function tryDigUp()
    while turtle.detectUp() do
        if turtle.digUp() then
            collect()
            sleep(0.1)
        else
            return false
        end
    end
    return true
end

local function tryDigDown()
    while turtle.detectDown() do
        if turtle.digDown() then
            collect()
            sleep(0.1)
        else
            return false
        end
    end
    return true
end

local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 0 then
        return
    end

    local function tryRefuel()
        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                turtle.select(n)
                if turtle.refuel(1) then
                    turtle.select(1)
                    return true
                end
            end
        end
        turtle.select(1)
        return false
    end

    if not tryRefuel() then
        print("Add more fuel to continue.")
        while not tryRefuel() do
            os.pullEvent("turtle_inventory")
        end
        print("Resuming Tunnel.")
    end
end

local function tryUp()
    refuel()
    while not turtle.up() do
        if turtle.detectUp() then
            if not tryDigUp() then
                return false
            end
        elseif turtle.attackUp() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryDown()
    refuel()
    while not turtle.down() do
        if turtle.detectDown() then
            if not tryDigDown() then
                return false
            end
        elseif turtle.attackDown() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryForward()
    refuel()
    while not turtle.forward() do
        if turtle.detect() then
            if not tryDig() then
                return false
            end
        elseif turtle.attack() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end
local function goBackward()
    turtle.back()
end

local function placeTorch()
    local function tryPlaceTorch()
        refuel()
        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                if turtle.getItemDetail(n).name == "minecraft:torch"  then
                    turtle.select(n)
                    turtle.place()
                    return true
                end
            end
        end
        turtle.select(1)
        return false
    end

    if not tryPlaceTorch() then
        print("Add more torches to continue.")
        while not tryPlaceTorch() do
            os.pullEvent("turtle_inventory")
        end
        print("Resuming Tunnel.")
    end
end

local function dropItems()
    local function tryDropItems()
        refuel()

        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                if turtle.getItemDetail(n).name == "enderstorage:ender_chest"  then
                    turtle.turnLeft()
                    turtle.turnLeft()
                    turtle.select(n)
                    turtle.place()
                    sleep(0.5)
                    for n = 1, 16 do
                        if turtle.getItemCount(n) > 0 then
                            slotName = turtle.getItemDetail(n).name
                            if slotName ~= "enderstorage:ender_chest" and slotName ~= "minecraft:torch" and slotName ~= "minecraft:coal" and slotName ~= "minecraft:charcoal" then
                                turtle.select(n)
                                print(turtle.getItemDetail(n).name)
                                print(turtle.drop())
                                print("dropping")
                                print(n)
                            end
                        end
                    end
                    for n = 1, 16 do
                        if turtle.getItemCount(n) == 0 then
                            turtle.select(n)
                            break
                        end
                    end
                    tryDig()
                    turtle.turnRight()
                    turtle.turnRight()
                    return true
                end

        
            end

        end
        return false
    end
    if not tryDropItems() == true then
        print("Error in dropitems - Is there an available enderstorage ender_chest in turtles inventory?")
        while not tryDropItems() do
            os.pullEvent("turtle_inventory")
        end
        print("Resuming ...")
    end

end


print("Tunnelling...")
Depth = 0


for n = 1, length do
    Depth = Depth + 1
    turtle.placeDown()
    tryDigUp()
    turtle.turnLeft()
    tryDig()
    tryUp()
    tryDig()
    turtle.turnRight()
    turtle.turnRight()
    tryDig()
    if n % 8 == 0 then
        placeTorch()
    end
    tryDown()
    tryDig()
    turtle.turnLeft()

    -- Old function
    -- if n % 40 == 0 then
    --     dropItems()
    -- end

    -- New function
    if turtle.getItemCount(16) > 0 then
        dropItems()
    end

    if n < length then
        tryDig()
        if not tryForward() then
            print("Aborting Tunnel.")
            break
        end
    else
        print("Tunnel complete.")
    end
end


print( "Returning to start..." )

-- Return to where we started
turtle.turnLeft()
turtle.turnLeft()
while Depth > 0 do
    if turtle.forward() then
        Depth = Depth - 1
    else
        turtle.dig()
    end
end
turtle.turnRight()
turtle.turnRight()

print("Tunnel complete.")
print("Mined " .. collected .. " items total.")
