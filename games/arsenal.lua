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

Arsenal._unlockConnection = nil

function Arsenal:UnlockAll(enabled)
    if self._unlockConnection then
        self._unlockConnection:Disconnect()
        self._unlockConnection = nil
    end
    if not enabled then return end

    local repStorage = game:GetService("ReplicatedStorage")
    local itemData = nil
    for _, child in pairs(repStorage:GetChildren()) do
        if child.Name == "ItemData" then itemData = child break end
    end
    if not itemData then warn("[Arsenal] ItemData not found") return end
    local images = nil
    for _, child in pairs(itemData:GetChildren()) do
        if child.Name == "Images" then images = child break end
    end
    if not images then warn("[Arsenal] Images not found") return end

    local function doUnlock()
        local inventoryData = nil
        for _, v in next, getgc(true) do
            if typeof(v) == "table" and rawget(v, "Loadout") and typeof(rawget(v, "Items")) == "table" then
                inventoryData = rawget(v, "Items")
                break
            end
        end
        if not inventoryData then return end

        for _, category in next, images:GetChildren() do
            if inventoryData[category.Name] then
                for _, item in next, category:GetChildren() do
                    if not inventoryData[category.Name][item.Name] then
                        inventoryData[category.Name][item.Name] = 1
                    end
                end
            end
        end
    end

    doUnlock()
    self._unlockConnection = game:GetService("RunService").Heartbeat:Connect(doUnlock)
    warn("[Arsenal] Unlock All active")
end

function Arsenal:SetMeleeSkin(skinName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.Melee.Value = skinName
    end)
    pcall(function()
        for _, v in next, getgc(true) do
            if typeof(v) == "table" and rawget(v, "Loadout") then
                local loadout = rawget(v, "Loadout")
                if typeof(loadout) == "table" then
                    loadout.Melee = skinName
                end
                break
            end
        end
    end)
end

function Arsenal:SetGunSkin(skinName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Equipped.Value = skinName
    end)
    pcall(function()
        for _, v in next, getgc(true) do
            if typeof(v) == "table" and rawget(v, "Loadout") then
                local loadout = rawget(v, "Loadout")
                if typeof(loadout) == "table" then
                    loadout.WeaponSkins = skinName
                end
                break
            end
        end
    end)
end

Arsenal._killEffectHooked = false
Arsenal._equippedKillEffect = nil

function Arsenal:HookKillEffect()
    if self._killEffectHooked then return end

    local effectFunc = nil
    for _, v in next, getgc() do
        if typeof(v) == "function" and islclosure(v) then
            local info = debug.info(v, "l")
            if info == 54994 then
                effectFunc = v
                break
            end
        end
    end

    if not effectFunc then
        warn("[Arsenal] Could not find kill effect function")
        return
    end

    local playerName = game:GetService("Players").LocalPlayer.Name
    local original
    original = hookfunction(effectFunc, newcclosure(function(...)
        local args = {...}
        if args[11] and tostring(args[11]):find(playerName) then
            if Arsenal._equippedKillEffect then
                args[12] = Arsenal._equippedKillEffect
            end
        end
        return original(unpack(args))
    end))
    self._killEffectHooked = true
    warn("[Arsenal] Kill effect hook active")
end

function Arsenal:SetKillEffect(effectName)
    self._equippedKillEffect = effectName
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.KillEffect.Value = effectName
    end)
    pcall(function()
        for _, v in next, getgc(true) do
            if typeof(v) == "table" and rawget(v, "Loadout") then
                local loadout = rawget(v, "Loadout")
                if typeof(loadout) == "table" then
                    loadout.KillEffect = effectName
                end
                break
            end
        end
    end)
    self:HookKillEffect()
end

function Arsenal:SetAnnouncer(announcerName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.Announcer.Value = announcerName
    end)
    pcall(function()
        for _, v in next, getgc(true) do
            if typeof(v) == "table" and rawget(v, "Loadout") then
                local loadout = rawget(v, "Loadout")
                if typeof(loadout) == "table" then
                    loadout.Announcer = announcerName
                end
                break
            end
        end
    end)
end

function Arsenal:SetCharacterSkin(skinName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.Skin.Value = skinName
    end)
    pcall(function()
        for _, v in next, getgc(true) do
            if typeof(v) == "table" and rawget(v, "Loadout") then
                local loadout = rawget(v, "Loadout")
                if typeof(loadout) == "table" then
                    loadout.Skin = skinName
                end
                break
            end
        end
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
    if not wrap then return targets end

    for _, child in pairs(wrap:GetChildren()) do
        if child.Name == "Gun" then
            table.insert(targets, child)
            break
        end
    end

    return targets
end

return Arsenal
