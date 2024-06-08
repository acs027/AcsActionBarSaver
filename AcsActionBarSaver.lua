
AcsActionBarSaverDB = {}

local function compareActions(i, actionInfo)
    local type, id = GetActionInfo(i)

    if (type == actionInfo.type and id == actionInfo.id) then
        return false
    else 
        return true
    end
end

local function nilActionCompare(i)
    local action = GetActionInfo(i)

    if action == nil then 
        return false
    else
        return true
    end
end

local function changeActionBars(tab)
    ClearCursor()
    for i = 1, 180 do
        local temp = tab[i]
        if temp ~= nil then
            if compareActions(i, temp) then
                if temp.type == "macro" then
                    PickupMacro(temp.id)
                    PlaceAction(i)
                elseif temp.type == "spell" then
                    PickupSpell(temp.id)
                    PlaceAction(i)
                elseif temp.type == "item" then
                    PickupItem(temp.id)
                    PlaceAction(i)
                end
                ClearCursor()
            end
        else
            if nilActionCompare(i) then
                PickupAction(i)
                ClearCursor()
            end
        end
    end
    print("Action bar setup loaded successfully")
end

local function printKeys(tab)
    for k,v in pairs(tab) do
        print(k)
    end
end

local function saveActionBars(saveName)
    local saveTable = {}
    for i=1,180 do
        local type, globID = GetActionInfo(i)
        if type == "macro" then
            local macroName, _, macroContent = GetMacroInfo(globID)
            saveTable[i] = {type = type, id = macroName}
        elseif (type == "spell" or type == "item") then
            saveTable[i] = {type = type, id = globID}
        end 
    end
    print("Action bar setup saved as "..saveName)
    return saveTable
end

local function OnEvent(self, event, addOnName)
    if addOnName == "AcsActionBarSaver" then
        AcsActionBarSaverDB = AcsActionBarSaverDB or {}
        print(addOnName.." Loaded!")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)

SLASH_AABS1 = "/aabs"

SlashCmdList.AABS = function(msg)
    args = {}
    count = 0
    for word in msg:gmatch("%w+") do 
        table.insert(args, word) 
        count = count + 1
    end

    if count == 2 then
        if args[1] == "save" then
            if AcsActionBarSaverDB[args[2]] ~= nil then
                print("You already have a setup saved with this name. Please choose a different name.")
                return
            end
            AcsActionBarSaverDB[args[2]] = saveActionBars(args[2])
            return
            
        elseif args[1] == "load" then
            if AcsActionBarSaverDB[args[2]] == nil then
                print("The specified setup does not exist. Please check the name and try again.")
                return
            end
            changeActionBars(AcsActionBarSaverDB[args[2]])
            return

        elseif args[1] == "remove" then
            if AcsActionBarSaverDB[args[2]] == nil then
                print("The specified setup does not exist. Please check the name and try again.")
                return
            end
            AcsActionBarSaverDB[args[2]] = nil
            print("Setup "..args[2].." has been successfully removed!")
            return
        else
            print("\nPlease use one of the following commands:\n" ..
            "/aabs list\n" ..
            "/aabs load *savename*\n" ..
            "/aabs save *setname*\n" ..
            "/aabs remove *savename*")
        end

    elseif msg == "list" then
        print("---Saved Setups---")
        printKeys(AcsActionBarSaverDB)
        print("---------------------")
    else
        print("\nPlease use one of the following commands:\n" ..
            "/aabs list\n" ..
            "/aabs load *savename*\n" ..
            "/aabs save *setname*\n" ..
            "/aabs remove *savename*")
    end
end


