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

    local applyFlag = Instance.new("StringValue")
    applyFlag.Name = "_ArsenalApply"
    applyFlag.Value = ""
    applyFlag.Parent = rep
    self._applyFlag = applyFlag

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
        local applyFlag = ReplicatedStorage:WaitForChild("_ArsenalApply", 5)

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
            pcall(function()
                LocalPlayer.Data.Skin.Value = skinname
                if LocalPlayer.Data.Skin:FindFirstChild("Sleeve") then
                    LocalPlayer.Data.Skin.Sleeve.Value = skinname
                end
            end)
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
            local targetFunc = nil

            -- Method 1: Search by line number range (game updates shift this)
            for _, v in next, getgc() do
                if typeof(v) == "function" and islclosure(v) then
                    local lineNum = debug.info(v, "l")
                    if lineNum and lineNum >= 54900 and lineNum <= 55100 then
                        local ok, consts = pcall(getconstants, v)
                        if ok and consts then
                            for _, c in next, consts do
                                if c == "KillEffect" or c == "killEffect" then
                                    targetFunc = v
                                    break
                                end
                            end
                        end
                        if targetFunc then break end
                    end
                end
            end

            -- Method 2: Broader search by constants pattern
            if not targetFunc then
                for _, v in next, getgc() do
                    if typeof(v) == "function" and islclosure(v) then
                        local ok, consts = pcall(getconstants, v)
                        if ok and consts then
                            local hasKE = false
                            local hasEmit = false
                            local hasClone = false
                            for _, c in next, consts do
                                if c == "KillEffect" or c == "killEffect" then hasKE = true end
                                if c == "Emit" or c == "ParticleEmitter" then hasEmit = true end
                                if c == "Clone" or c == "clone" then hasClone = true end
                            end
                            if hasKE and (hasEmit or hasClone) then
                                targetFunc = v
                                break
                            end
                        end
                    end
                end
            end

            -- Method 3: Search for function that has many params and references kill effects
            if not targetFunc then
                for _, v in next, getgc() do
                    if typeof(v) == "function" and islclosure(v) then
                        local ok, ups = pcall(getupvalues, v)
                        if ok and ups then
                            for _, up in next, ups do
                                if typeof(up) == "table" and rawget(up, "KillEffect") then
                                    targetFunc = v
                                    break
                                end
                            end
                        end
                        if targetFunc then break end
                    end
                end
            end

            if not targetFunc then
                warn("[Arsenal] Could not find kill effect function - effects will use Value fallback")
                return
            end

            effectHooked = true
            local PlayerName = LocalPlayer.Name
            local OrigKillEffect
            OrigKillEffect = hookfunction(targetFunc, newcclosure(function(...)
                local args = {...}
                if args[11] and tostring(args[11]):find(PlayerName) then
                    if EquippedKillEffect and EquippedKillEffect ~= "" and EquippedKillEffect ~= "None" then
                        args[12] = EquippedKillEffect
                    end
                end
                return OrigKillEffect(unpack(args))
            end))
            warn("[Arsenal] Kill effect hook active")
        end

        -- Sync EquippedKillEffect when Value changes (from main thread SetKillEffect)
        pcall(function()
            if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("KillEffect") then
                LocalPlayer.Data.KillEffect.Changed:Connect(function(newVal)
                    if newVal and newVal ~= "" then
                        EquippedKillEffect = newVal
                    end
                end)
                -- Initialize from current value
                if LocalPlayer.Data.KillEffect.Value ~= "" then
                    EquippedKillEffect = LocalPlayer.Data.KillEffect.Value
                end
            end
        end)

        HookLoadout()
        HookKillEffect()

        -- Listen for loadout apply commands from main thread
        if applyFlag then
            applyFlag.Changed:Connect(function(val)
                if val == "" then return end
                local key, value = string.match(val, "(.+):(.+)")
                if not key or not value then return end
                -- Write to internal Loadout table (triggers __newindex → visual change)
                if Loadout then
                    Loadout[key] = value
                else
                    -- Fallback: set Values directly
                    if key == "Skin" then ChangeSkin(value)
                    elseif key == "Melee" then ChangeMelee(value)
                    elseif key == "WeaponSkins" then ChangeGunSkin(value)
                    elseif key == "KillEffect" then ChangeKillEffect(value)
                    elseif key == "Announcer" then ChangeAnnouncer(value)
                    end
                end
            end)
        end

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

function Arsenal:_applyLoadout(key, value)
    if self._applyFlag then
        -- Clear first to ensure Changed fires even if same value
        self._applyFlag.Value = ""
        self._applyFlag.Value = key .. ":" .. value
    end
end

function Arsenal:SetMeleeSkin(skinName)
    self:_applyLoadout("Melee", skinName)
end

function Arsenal:SetGunSkin(skinName)
    self:_applyLoadout("WeaponSkins", skinName)
end

function Arsenal:SetKillEffect(effectName)
    self:_applyLoadout("KillEffect", effectName)
end

function Arsenal:SetAnnouncer(announcerName)
    self:_applyLoadout("Announcer", announcerName)
end

function Arsenal:SetCharacterSkin(skinName)
    self:_applyLoadout("Skin", skinName)
end

Arsenal._origFOV = nil

function Arsenal:SetFOV(value)
    pcall(function()
        local settings = game:GetService("Players").LocalPlayer.Settings
        if settings and settings:FindFirstChild("FOV") then
            if self._origFOV == nil then
                self._origFOV = settings.FOV.Value
            end
            settings.FOV.Value = value
        end
    end)
end

function Arsenal:ResetFOV()
    pcall(function()
        if self._origFOV ~= nil then
            local settings = game:GetService("Players").LocalPlayer.Settings
            if settings and settings:FindFirstChild("FOV") then
                settings.FOV.Value = self._origFOV
            end
            self._origFOV = nil
        end
    end)
end

local _origWeaponValues = {}
local _origCurse = nil

local function GetWeaponsFolder()
    local Weapons = nil
    pcall(function()
        for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if child.Name == "Weapons" then Weapons = child break end
        end
    end)
    return Weapons
end

local function SaveOriginal(weapon, prop)
    local key = weapon.Name .. "_" .. prop
    if _origWeaponValues[key] == nil then
        pcall(function()
            for _, child in pairs(weapon:GetChildren()) do
                if child.Name == prop then
                    _origWeaponValues[key] = child.Value
                    break
                end
            end
        end)
    end
end

local function RestoreOriginal(weapon, prop)
    local key = weapon.Name .. "_" .. prop
    if _origWeaponValues[key] ~= nil then
        pcall(function()
            for _, child in pairs(weapon:GetChildren()) do
                if child.Name == prop then
                    child.Value = _origWeaponValues[key]
                    break
                end
            end
        end)
    end
end

function Arsenal:NoRecoil(enabled)
    local Weapons = GetWeaponsFolder()
    if not Weapons then return end
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            for _, child in pairs(v:GetChildren()) do
                if child.Name == "RecoilControl" then
                    if enabled then
                        SaveOriginal(v, "RecoilControl")
                        child.Value = 0
                    else
                        RestoreOriginal(v, "RecoilControl")
                    end
                    break
                end
            end
        end)
    end
end

function Arsenal:NoSpread(enabled)
    local Weapons = GetWeaponsFolder()
    if not Weapons then return end
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            if enabled then
                SaveOriginal(v, "MaxSpread")
                SaveOriginal(v, "SpreadRecovery")
                for _, child in pairs(v:GetChildren()) do
                    if child.Name == "MaxSpread" then child.Value = 0.01
                    elseif child.Name == "SpreadRecovery" then child.Value = 0.01 end
                end
            else
                RestoreOriginal(v, "MaxSpread")
                RestoreOriginal(v, "SpreadRecovery")
            end
        end)
    end
end

function Arsenal:FastReload(enabled)
    local Weapons = GetWeaponsFolder()
    if not Weapons then return end
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            if enabled then
                SaveOriginal(v, "ReloadTime")
                for _, child in pairs(v:GetChildren()) do
                    if child.Name == "ReloadTime" then child.Value = 0.01 break end
                end
            else
                RestoreOriginal(v, "ReloadTime")
            end
        end)
    end
end

function Arsenal:FireRateModifier(enabled, multiplier)
    local Weapons = GetWeaponsFolder()
    if not Weapons then return end
    multiplier = multiplier or 1
    for _, v in pairs(Weapons:GetChildren()) do
        pcall(function()
            if enabled then
                SaveOriginal(v, "FireRate")
                SaveOriginal(v, "BFireRate")
                for _, child in pairs(v:GetChildren()) do
                    local key = v.Name .. "_" .. child.Name
                    if child.Name == "FireRate" and _origWeaponValues[key] then
                        child.Value = _origWeaponValues[key] / math.max(multiplier, 0.1)
                    elseif child.Name == "BFireRate" and _origWeaponValues[key] then
                        child.Value = _origWeaponValues[key] / math.max(multiplier, 0.1)
                    end
                end
            else
                RestoreOriginal(v, "FireRate")
                RestoreOriginal(v, "BFireRate")
            end
        end)
    end
end

function Arsenal:InfiniteAmmo(enabled)
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
                if enabled then
                    if _origCurse == nil then
                        _origCurse = curse.Value
                    end
                    curse.Value = "Infinite Ammo"
                else
                    if _origCurse ~= nil then
                        curse.Value = _origCurse
                        _origCurse = nil
                    end
                end
            end
        end
    end)
end

function Arsenal:GetToolTargets(playerName)
    local targets = {}

    pcall(function()
        local wrapName = "HWRAP_" .. playerName
        for _, child in pairs(workspace:GetChildren()) do
            if child.Name == wrapName then
                table.insert(targets, child)
                break
            end
        end
    end)

    pcall(function()
        local camera = workspace.CurrentCamera
        for _, child in pairs(camera:GetChildren()) do
            if child.Name == "Arms" and child:IsA("Model") then
                for _, sub in pairs(child:GetChildren()) do
                    if sub:IsA("BasePart") or sub:IsA("MeshPart") then
                        table.insert(targets, sub)
                    elseif sub:IsA("Model") and sub.Name ~= "CSSArms" then
                        table.insert(targets, sub)
                    end
                end
                break
            end
        end
    end)

    return targets
end

function Arsenal:GetArmTargets(playerName)
    return {}
end

return Arsenal
