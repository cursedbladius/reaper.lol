local Arsenal = {}

Arsenal.MeleeSkins = {
    "Crucible", "Fish", "The Windforce", "Coral Blade", "Machete", "Mop",
    "Peppermint Slicer", "Brick", "Big Sip", "Bloxy", "Coal Sword",
    "ACT Trophy S6", "Roughian's Pipe", "Da Melee", "Endbringer",
    "The Scrambler", "Space Katana", "Egg", "Katana", "Pipe Wrench Shank",
    "Halberd", "Synthlight Greatsword", "SuperSpaceKatana", "Skele Scythe",
    "Space KatanaOLD", "The Firebrand", "Candy Cane Claws", "Fire Poker",
    "Digi-Blade", "Handblades", "Racket", "Harvester", "The Ice Dagger",
    "Calculator", "Katar", "Chainsaw", "Frog", "Blast Hammer", "Assimilator",
    "Handy Candy", "Blossoming Femur", "Makeshift Saw", "Loaf", "Swordfish",
    "Toy Tree", "The Darkheart", "Wrench", "Silver Bell", "Peppermint Hammer",
    "Butterfly Knife", "Gaster Blaster", "Candy Cane Sword", "Spring Greatsword",
    "Pan", "Pencil", "Crowbar", "Doublade", "Garlic Kebab", "Aged Shovel",
    "Sickle", "Seal", "Banana", "Pumpkin Staff", "Drill-Shear Skewer",
    "Literal Melee", "Candle Sword", "Reclaimer", "Bone Karambit",
    "Earth Cleaver", "R.A.M", "Stranger's Handblades", "Shovel", "Bat Axe",
    "Karambit", "Wooden Spoon", "Electric Flail", "Energy Blade", "Blade",
    "Rapier", "OG Space Katana", "Electronic Stake", "Smug Egg", "Heart Break",
    "Bat", "Grumpy Hammer", "FOAM BLADE 3000", "Makeshift Axe", "Wired Bat",
    "Candleabra", "Rusty Pipe", "Kunai", "Saber", "Naginata", "Carrot",
    "Energy Katar", "Divine Medallions", "Scythe", "Delinquent Pop",
    "Tactical Knife", "Annihilator's Broken Sword", "Beast Hammer", "Divinity",
    "Sledgehammer", "Fisticuffs", "Moai", "Hero's Sword", "Killbrick Melee",
    "The Fool's Tool", "Slicecicle", "Sabre", "Glacier Blade", "Doodle Sign",
    "Dagger", "Paddle", "Daito", "Combat Knife", "Kitchen Knife", "Stop Sign",
    "Frostweaver's Wand", "Leader's Axe", "Sip O' Stink", "Death's Blade",
    "Guitar", "Bouquet", "Gingerbread Knife", "The Illumina", "Bunny Staff",
    "Pumpkin Bucket", "Nomad's Blade", "Paint Brush", "Rubber Hammer",
    "When Day Breaks", "Tomahawk", "Swift End", "Brass Knuckles", "Plane",
    "Skull Pal", "Let The Skies Fall", "Newspaper", "Coal Scythe",
    "Starfire Staff", "Can Mace", "Pitchfork", "Balloon Sword", "Electro Axe",
    "Claws", "Khopesh", "Stinger", "Rebel's Bat", "The Ghostwalker",
    "Golden Rings", "Easter Cleaver", "Icicle", "Classic Sword", "Slappy",
    "Hallow's Scythe", "Merry Masher", "The Venomshank", "Night's Edge",
    "Candy Cane", "Ban Hammer", "Pumpkin Axe", "Ghost Ripper", "Baton",
    "Mittens", "Moderation Hammer", "Bone Club", "Reliable Hammer", "Crab Claw",
    "Kukri", "Rokia Hammer", "ACT Trophy"
}

function Arsenal:GetItemNames(category)
    local names = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local itemData = nil
    for _, child in pairs(repStorage:GetChildren()) do
        if child.Name == "ItemData" then itemData = child break end
    end
    if not itemData then return names end
    local images = nil
    for _, child in pairs(itemData:GetChildren()) do
        if child.Name == "Images" then images = child break end
    end
    if not images then return names end
    local folder = nil
    for _, child in pairs(images:GetChildren()) do
        if child.Name == category then folder = child break end
    end
    if not folder then return names end
    for _, child in pairs(folder:GetChildren()) do
        table.insert(names, child.Name)
    end
    table.sort(names)
    return names
end

function Arsenal:GetAllCategories()
    local categories = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local itemData = nil
    for _, child in pairs(repStorage:GetChildren()) do
        if child.Name == "ItemData" then itemData = child break end
    end
    if not itemData then return categories end
    local images = nil
    for _, child in pairs(itemData:GetChildren()) do
        if child.Name == "Images" then images = child break end
    end
    if not images then return categories end
    for _, child in pairs(images:GetChildren()) do
        categories[child.Name] = {}
        for _, item in pairs(child:GetChildren()) do
            table.insert(categories[child.Name], item.Name)
        end
        table.sort(categories[child.Name])
    end
    return categories
end

Arsenal._actorStarted = false

function Arsenal:StartActor()
    if self._actorStarted then return end
    self._actorStarted = true

    local rep = game:GetService("ReplicatedStorage")

    local unlockFlag = Instance.new("StringValue")
    unlockFlag.Name = "_ArsenalUnlockAll"
    unlockFlag.Value = "0"
    unlockFlag.Parent = rep
    self._unlockFlag = unlockFlag

    local selectedFlag = Instance.new("StringValue")
    selectedFlag.Name = "_ArsenalSelected"
    selectedFlag.Value = ""
    selectedFlag.Parent = rep
    self._selectedFlag = selectedFlag

    local actor = getactors()[1]
    if not actor then
        warn("[Arsenal] No actor found")
        return
    end

    run_on_actor(actor, [=[
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        local Items = ReplicatedStorage.ItemData.Images

        local unlockFlag = ReplicatedStorage:WaitForChild("_ArsenalUnlockAll", 5)
        local selectedFlag = ReplicatedStorage:WaitForChild("_ArsenalSelected", 5)

        local InventoryData = nil
        local Loadout = nil
        local DataTable = nil
        local EquippedKillEffect = nil
        local originalInventory = {}
        local loadoutHooked = false
        local effectHooked = false

        local function FindTables()
            for i, v in next, getgc(true) do
                if typeof(v) == "table" and rawget(v, "Loadout") and typeof(rawget(v, "Items")) == "table" then
                    if v.Items ~= InventoryData then
                        InventoryData = v.Items
                        Loadout = v.Loadout
                        DataTable = v
                        originalInventory = {}
                        for catName, catData in next, InventoryData do
                            if typeof(catData) == "table" then
                                originalInventory[catName] = {}
                                for itemName, itemVal in next, catData do
                                    originalInventory[catName][itemName] = itemVal
                                end
                            end
                        end
                        return true
                    end
                    return false
                end
            end
            return false
        end

        FindTables()
        if not InventoryData then
            warn("[Arsenal] Could not find inventory data")
            return
        end

        local function ChangeSkin(skinname)
            pcall(function() LocalPlayer.Data.Skin.Value = skinname end)
        end

        local function ChangeGunSkin(name)
            pcall(function() LocalPlayer.Equipped.Value = name end)
        end

        local function ChangeMelee(skinname)
            pcall(function() LocalPlayer.Data.Melee.Value = skinname end)
        end

        local function ChangeKillEffect(skinname)
            pcall(function() LocalPlayer.Data.KillEffect.Value = skinname end)
            EquippedKillEffect = skinname
        end

        local function ChangeAnnouncer(skinname)
            pcall(function() LocalPlayer.Data.Announcer.Value = skinname end)
        end

        local function AddEveryItem()
            if not InventoryData then return end
            for _, v in next, Items:GetChildren() do
                if InventoryData[v.Name] then
                    for _, f in next, v:GetChildren() do
                        if not InventoryData[v.Name][f.Name] then
                            InventoryData[v.Name][f.Name] = 1
                        end
                    end
                end
            end
        end

        local function ParseSelected()
            local result = {}
            if not selectedFlag or selectedFlag.Value == "" then return result end
            for entry in string.gmatch(selectedFlag.Value, "[^;]+") do
                local cat, item = string.match(entry, "(.+):(.+)")
                if cat and item then
                    if not result[cat] then result[cat] = {} end
                    result[cat][item] = true
                end
            end
            return result
        end

        local function SyncSelectedItems()
            if not InventoryData then return end
            local selected = ParseSelected()
            for cat, items in next, selected do
                if InventoryData[cat] then
                    for itemName, _ in next, items do
                        InventoryData[cat][itemName] = InventoryData[cat][itemName] or 1
                    end
                end
            end
            for catName, catData in next, InventoryData do
                if typeof(catData) == "table" then
                    for itemName, _ in next, catData do
                        local isOriginal = originalInventory[catName] and originalInventory[catName][itemName]
                        local isSelected = selected[catName] and selected[catName][itemName]
                        if not isOriginal and not isSelected then
                            catData[itemName] = nil
                        end
                    end
                end
            end
        end

        local function RemoveUnlockedItems()
            if not InventoryData then return end
            local selected = ParseSelected()
            for catName, catData in next, InventoryData do
                if typeof(catData) == "table" then
                    for itemName, _ in next, catData do
                        local isOriginal = originalInventory[catName] and originalInventory[catName][itemName]
                        local isSelected = selected[catName] and selected[catName][itemName]
                        if not isOriginal and not isSelected then
                            catData[itemName] = nil
                        end
                    end
                end
            end
        end

        local function HookLoadout()
            if not Loadout or loadoutHooked then return end
            loadoutHooked = true
            local rl = table.clone(Loadout)
            setmetatable(Loadout, {
                __index = rl,
                __newindex = function(s, i, v)
                    if i == "Skin" then
                        ChangeSkin(v)
                    elseif i == "Melee" then
                        ChangeMelee(v)
                    elseif i == "WeaponSkins" then
                        ChangeGunSkin(v)
                    elseif i == "KillEffect" then
                        EquippedKillEffect = v
                        ChangeKillEffect(v)
                    elseif i == "Announcer" then
                        ChangeAnnouncer(v)
                    end
                    rl[i] = v
                end
            })
            table.clear(Loadout)
        end

        local function HookKillEffect()
            if effectHooked then return end
            for _, v in next, getgc() do
                if typeof(v) == "function" and islclosure(v) then
                    if debug.info(v, "l") == 54994 then
                        effectHooked = true
                        local PlayerName = LocalPlayer.Name
                        local KillEffect
                        KillEffect = hookfunction(v, newcclosure(function(...)
                            local args = {...}
                            if args[11] and tostring(args[11]):find(PlayerName) then
                                local ke = nil
                                pcall(function()
                                    ke = LocalPlayer.Data.KillEffect.Value
                                end)
                                if ke and ke ~= "" and ke ~= "None" then
                                    args[12] = ke
                                end
                            end
                            return KillEffect(unpack(args))
                        end))
                        warn("[Arsenal] Kill effect hook active")
                        break
                    end
                end
            end
        end

        HookLoadout()
        HookKillEffect()

        local wasUnlocked = false
        local refreshTimer = 0

        RunService.Heartbeat:Connect(function()
            refreshTimer = refreshTimer + 1
            if refreshTimer >= 300 then
                refreshTimer = 0
                local changed = FindTables()
                if changed then
                    loadoutHooked = false
                    HookLoadout()
                    warn("[Arsenal] Tables refreshed")
                end
            end

            if not InventoryData then
                FindTables()
                if InventoryData then
                    loadoutHooked = false
                    HookLoadout()
                end
                return
            end

            local isUnlocked = unlockFlag and unlockFlag.Value == "1"
            if isUnlocked then
                AddEveryItem()
                wasUnlocked = true
            else
                if wasUnlocked then
                    wasUnlocked = false
                end
                SyncSelectedItems()
            end
        end)
        warn("[Arsenal] Actor fully initialized")
    ]=])
end

function Arsenal:UnlockAll(enabled)
    self:StartActor()
    if self._unlockFlag then
        self._unlockFlag.Value = enabled and "1" or "0"
    end
end

function Arsenal:SetSelectedItems(category, items)
    self._selectedItemsMap[category] = items
    self:StartActor()
    self:_updateSelectedFlag()
    if not items or #items == 0 then return end
    local last = items[#items]
    if category == "Melees" then
        self:SetMeleeSkin(last)
    elseif category == "WeaponSkins" then
        self:SetGunSkin(last)
    elseif category == "KillEffects" then
        self:SetKillEffect(last)
    elseif category == "Announcers" then
        self:SetAnnouncer(last)
    elseif category == "Skins" then
        self:SetCharacterSkin(last)
    end
end

Arsenal._selectedItemsMap = {}

function Arsenal:_updateSelectedFlag()
    local parts = {}
    for cat, items in next, self._selectedItemsMap do
        for _, name in next, items do
            table.insert(parts, cat .. ":" .. name)
        end
    end
    local encoded = table.concat(parts, ";")
    if self._selectedFlag then
        self._selectedFlag.Value = encoded
    end
end

function Arsenal:SetMeleeSkin(skinName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.Melee.Value = skinName
    end)
end

function Arsenal:SetGunSkin(skinName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Equipped.Value = skinName
    end)
end

function Arsenal:SetKillEffect(effectName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.KillEffect.Value = effectName
    end)
end

function Arsenal:SetAnnouncer(announcerName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.Announcer.Value = announcerName
    end)
end

function Arsenal:SetCharacterSkin(skinName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.Skin.Value = skinName
    end)
end

function Arsenal:NoRecoil()
    local Weapons = game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
    if not Weapons then
        for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if child.Name == "Weapons" then Weapons = child break end
        end
    end
    if not Weapons then return end
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            if v:FindFirstChild("RecoilControl") then
                v.RecoilControl.Value = 0
            end
        end)
    end
end

function Arsenal:NoSpread()
    local Weapons = game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
    if not Weapons then
        for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if child.Name == "Weapons" then Weapons = child break end
        end
    end
    if not Weapons then return end
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            if v:FindFirstChild("MaxSpread") then
                v.MaxSpread.Value = 0.01
            end
            if v:FindFirstChild("SpreadRecovery") then
                v.SpreadRecovery.Value = 0.01
            end
        end)
    end
end

function Arsenal:FastReload()
    local Weapons = game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
    if not Weapons then
        for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if child.Name == "Weapons" then Weapons = child break end
        end
    end
    if not Weapons then return end
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            if v:FindFirstChild("ReloadTime") then
                v.ReloadTime.Value = 0.01
            end
        end)
    end
end

function Arsenal:FastFireRate()
    local Weapons = game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
    if not Weapons then
        for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if child.Name == "Weapons" then Weapons = child break end
        end
    end
    if not Weapons then return end
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            if v:FindFirstChild("FireRate") then
                v.FireRate.Value = 0.01
            end
            if v:FindFirstChild("BFireRate") then
                v.BFireRate.Value = 0.01
            end
        end)
    end
end

function Arsenal:InfiniteAmmo()
    pcall(function()
        local repStorage = game:GetService("ReplicatedStorage")
        local wkspc = nil
        for _, child in pairs(repStorage:GetChildren()) do
            if child.Name == "wkspc" then wkspc = child break end
        end
        if wkspc then
            local curse = nil
            for _, child in pairs(wkspc:GetChildren()) do
                if child.Name == "CurrentCurse" then curse = child break end
            end
            if curse then
                curse.Value = "Infinite Ammo"
            end
        end
    end)
end

function Arsenal:GetToolTargets(playerName)
    local targets = {}

    local wrapName = "HWRAP_" .. playerName
    local wrap = nil
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == wrapName then
            wrap = child
            break
        end
    end
    if wrap then
        for _, child in pairs(wrap:GetChildren()) do
            if child.Name == "Gun" then
                table.insert(targets, child)
                break
            end
        end
    end

    pcall(function()
        local localPlayer = game:GetService("Players").LocalPlayer
        local nrpbs = nil
        for _, child in pairs(localPlayer:GetChildren()) do
            if child.Name == "NRPBS" then nrpbs = child break end
        end
        if not nrpbs then return end

        local equippedTool = nil
        for _, child in pairs(nrpbs:GetChildren()) do
            if child.Name == "EquippedTool" then equippedTool = child break end
        end
        if not equippedTool then return end

        local toolName = ""
        if typeof(equippedTool.Value) == "string" then
            toolName = equippedTool.Value
        elseif typeof(equippedTool.Value) == "Instance" then
            toolName = equippedTool.Value.Name
        end
        if toolName == "" then return end

        local weapons = nil
        for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if child.Name == "Weapons" then weapons = child break end
        end
        if not weapons then return end

        for _, child in pairs(weapons:GetChildren()) do
            if child.Name == toolName then
                for _, sub in pairs(child:GetChildren()) do
                    if sub.Name == "Model" then
                        table.insert(targets, sub)
                        break
                    end
                end
                break
            end
        end
    end)

    return targets
end

return Arsenal
