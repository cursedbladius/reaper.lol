local LoadStart = os.clock()
local Library = loadstring(game:HttpGet("https://reaper-lol.pages.dev/ui/library.lua"))()

local ESP = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/visuals/esp.lua"))()
ESP:Initialize()

local ToolModifier = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/visuals/tool_modifier.lua"))()
local ParticleAura = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/visuals/particle_aura.lua"))()

local GameRegistry = loadstring(game:HttpGet("https://reaper-lol.pages.dev/games/registry.lua"))()
local DaHoodAdapter = loadstring(game:HttpGet("https://reaper-lol.pages.dev/games/da_hood.lua"))()
local CriminalityAdapter = loadstring(game:HttpGet("https://reaper-lol.pages.dev/games/criminality.lua"))()
local ArsenalAdapter = loadstring(game:HttpGet("https://reaper-lol.pages.dev/games/arsenal.lua"))()
GameRegistry:Register(4588604953, DaHoodAdapter)
GameRegistry:Register(2788229376, DaHoodAdapter)
GameRegistry:Register(15169303036, CriminalityAdapter)
GameRegistry:Register(1494262959, CriminalityAdapter)
GameRegistry:Register(286090429, ArsenalAdapter)
GameRegistry:Register(111958650, ArsenalAdapter)

local _adapter = GameRegistry:Get()
ToolModifier:Initialize(_adapter)

local Window = Library:Window({
    Name = "reaper.lol",
    FadeSpeed = 0.25
})

local Watermark = Library:Watermark("reaper.lol ~ ".. os.date("%b %d %Y") .. " ~ ".. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
local KeybindList = Library:KeybindList()

Watermark:SetVisibility(true)
KeybindList:SetVisibility(false)

local CombatTab = Window:Page({Name = "Combat", Columns = 2, Subtabs = false})
local VisualsTab = Window:Page({Name = "Visuals", Columns = 2, Subtabs = true})
local MovementTab = Window:Page({Name = "Movement", Columns = 2, Subtabs = false})
local SettingsTab = Library:CreateSettingsPage(Window, Watermark, KeybindList)

local CamlockSection = CombatTab:Section({Name = "Camlock", Side = 1})
local SilentAimSection = CombatTab:Section({Name = "Silent Aim", Side = 1})
local TargetAimSection = CombatTab:Section({Name = "Target Aim", Side = 2})
local WeaponModsSection = CombatTab:Section({Name = "Weapon Mods", Side = 2})

local PlayersSubTab = VisualsTab:SubPage({Icon = "115398113982385", Columns = 2})
local GeneralSubTab = VisualsTab:SubPage({Icon = "100033680381365", Columns = 2})

local ESPSection = PlayersSubTab:Section({Name = "ESP", Side = 1})

ESPSection:Toggle({Name = "Masterswitch", Flag = "ESPEnabled", Default = false, Callback = function(Value)
    ESP:Toggle(Value)
end})

ESPSection:Toggle({Name = "Box", Flag = "ESPBox", Default = false, Callback = function(Value)
    ESP:SetSetting("Box", Value)
end}):Colorpicker({Name = "", Flag = "ESPBoxColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("BoxColor", Value)
end})

local NameTypeDropdown
ESPSection:Toggle({Name = "Name", Flag = "ESPName", Default = false, Callback = function(Value)
    ESP:SetSetting("Name", Value)
    if NameTypeDropdown then
        NameTypeDropdown:SetVisibility(Value)
    end
end}):Colorpicker({Name = "", Flag = "ESPNameColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("NameColor", Value)
end})

NameTypeDropdown = ESPSection:Dropdown({Name = "Name Type", Flag = "ESPNameType", Default = "DisplayName", Items = {"DisplayName", "Username"}, Callback = function(Value)
    if Value == nil then
        NameTypeDropdown:Set("DisplayName")
        return
    end
    ESP:SetSetting("NameType", Value)
end})
NameTypeDropdown:SetVisibility(false)

ESPSection:Toggle({Name = "Health-bar", Flag = "ESPHealthBar", Default = false, Callback = function(Value)
    ESP:SetSetting("HealthBar", Value)
end}):Colorpicker({Name = "", Flag = "ESPHealthColor", Default = Color3.fromRGB(0, 255, 0), Callback = function(Value)
    ESP:SetSetting("HealthColor", Value)
end})

ESPSection:Toggle({Name = "Show Value", Flag = "ESPHealthValue", Default = false, Callback = function(Value)
    ESP:SetSetting("HealthValue", Value)
end})

ESPSection:Toggle({Name = "Health Gradient", Flag = "ESPHealthGradient", Default = false, Callback = function(Value)
    ESP:SetSetting("HealthGradient", Value)
end}):Colorpicker({Name = "", Flag = "ESPHealthGradientColor", Default = Color3.fromRGB(255, 0, 0), Callback = function(Value)
    ESP:SetSetting("HealthGradientColor", Value)
end})

ESPSection:Toggle({Name = "Distance", Flag = "ESPDistance", Default = false, Callback = function(Value)
    ESP:SetSetting("Distance", Value)
end}):Colorpicker({Name = "", Flag = "ESPDistanceColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("DistanceColor", Value)
end})

ESPSection:Toggle({Name = "Skeleton", Flag = "ESPSkeleton", Default = false, Callback = function(Value)
    ESP:SetSetting("Skeleton", Value)
end}):Colorpicker({Name = "", Flag = "ESPSkeletonColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("SkeletonColor", Value)
end})

ESPSection:Toggle({Name = "Highlight", Flag = "ESPChams", Default = false, Callback = function(Value)
    ESP:SetSetting("Chams", Value)
end}):Colorpicker({Name = "", Flag = "ESPChamsColor", Default = Color3.fromRGB(255, 0, 0), Callback = function(Value)
    ESP:SetSetting("ChamsColor", Value)
end})

ESPSection:Toggle({Name = "Highlight Outline", Flag = "ESPChamsOutline", Default = false, Callback = function(Value)
    ESP:SetSetting("ChamsOutline", Value)
end}):Colorpicker({Name = "", Flag = "ESPChamsOutlineColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("ChamsOutlineColor", Value)
end})

ESPSection:Toggle({Name = "Equipped Tool", Flag = "ESPTool", Default = false, Callback = function(Value)
    ESP:SetSetting("Tool", Value)
end}):Colorpicker({Name = "", Flag = "ESPToolColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("ToolColor", Value)
end})

local OptionsSection = PlayersSubTab:Section({Name = "Options", Side = 2})

OptionsSection:Slider({Name = "Render Distance", Min = 100, Max = 5000, Default = 1000, Decimals = 1, Suffix = " studs", Flag = "ESPDistanceSlider", Callback = function(Value)
    ESP:SetSetting("MaxDistance", Value)
end})

OptionsSection:Dropdown({Name = "ESP Type", Flag = "ESPType", Default = "Dynamic", Items = {"Dynamic", "Static", "2D", "3D"}, Callback = function(Value)
    ESP:SetSetting("BoxType", Value)
end})

OptionsSection:Dropdown({Name = "Name Font", Flag = "ESPNameFont", Default = "Tahoma", Items = {"Tahoma", "Monospace"}, Callback = function(Value)
    ESP:SetSetting("Font", Value)
end})

OptionsSection:Dropdown({Name = "Flags Font", Flag = "ESPFlagsFont", Default = "Default (Tahoma)", Items = {"Default (Tahoma)", "Bold", "Italic", "Source Sans"}})

OptionsSection:Toggle({Name = "Occluded-check", Flag = "ESPOccluded", Default = false, Callback = function(Value)
    ESP:SetSetting("VisibleOnly", Value)
end})

OptionsSection:Toggle({Name = "Team Check", Flag = "Team Check", Default = true, Callback = function(Value)
    ESP:SetSetting("TeamCheck", Value)
end})

local GameSection = GeneralSubTab:Section({Name = "Game", Side = 1})

local ToolModOutline, ToolModMaterial, ToolModColorPicker
local ToolModToggle = GameSection:Toggle({Name = "Tool Modifier", Flag = "ToolModifier", Default = false, Callback = function(Value)
    ToolModifier.Enabled = Value
    if not Value then
        ToolModifier:Reset()
    end
    pcall(function()
        if ToolModOutline then ToolModOutline:SetVisiblity(Value) end
        if ToolModMaterial then ToolModMaterial:SetVisibility(Value) end
    end)
end})
ToolModToggle:Colorpicker({Name = "", Flag = "ToolModifierColor", Default = Color3.fromRGB(255, 0, 0), DefaultAlpha = 0.4, Callback = function(Value, Alpha)
    ToolModifier.Color = Value
    ToolModifier.Alpha = Alpha or 0
end})

ToolModOutline = GameSection:Toggle({Name = "Outline", Flag = "ToolOutlineToggle", Default = true, Callback = function(Value)
    ToolModifier.OutlineEnabled = Value
end})
ToolModOutline:Colorpicker({Name = "", Flag = "ToolModifierOutline", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ToolModifier.OutlineColor = Value
end})
ToolModOutline:SetVisiblity(false)

ToolModMaterial = GameSection:Dropdown({
    Name = "Tool Material",
    Flag = "ToolModifierMaterial",
    Default = "Highlight",
    Items = {"Highlight", "ForceField", "Neon"},
    Callback = function(Value)
        if Value == nil then
            ToolModMaterial:Set("Highlight")
            return
        end
        ToolModifier.Material = Value
        pcall(function()
            ToolModOutline:SetVisiblity(Value == "Highlight" and ToolModifier.Enabled)
        end)
    end
})
ToolModMaterial:SetVisibility(false)

local _toolModFrame = 0
game:GetService("RunService").RenderStepped:Connect(function()
    _toolModFrame = _toolModFrame + 1
    if _toolModFrame % 3 == 0 then
        ToolModifier:Apply()
    end
end)

local ParticleDropdown
GameSection:Toggle({Name = "Particle Aura", Flag = "ParticleAura", Default = false, Callback = function(Value)
    ParticleAura:Toggle(Value)
    pcall(function()
        if ParticleDropdown then ParticleDropdown:SetVisibility(Value) end
    end)
end}):Colorpicker({Name = "", Flag = "ParticleAuraColor", Default = Color3.fromRGB(133, 220, 255), DefaultAlpha = 0.2, Callback = function(Value, Alpha)
    ParticleAura:SetColor(Value)
end})

ParticleDropdown = GameSection:Dropdown({
    Name = "Particle",
    Flag = "ParticleAuraType",
    Default = "angel",
    Items = ParticleAura:GetAuraNames(),
    Callback = function(Value)
        if Value then
            ParticleAura:SetAura(Value)
        end
    end
})
ParticleDropdown:SetVisibility(false)

if game.GameId == 111958650 or game.PlaceId == 286090429 then
    ArsenalAdapter:StartActor()

    WeaponModsSection:Toggle({Name = "No Recoil", Flag = "ArsenalNoRecoil", Default = false, Callback = function(Value)
        ArsenalAdapter:NoRecoil(Value)
    end})
    WeaponModsSection:Toggle({Name = "No Spread", Flag = "ArsenalNoSpread", Default = false, Callback = function(Value)
        ArsenalAdapter:NoSpread(Value)
    end})
    WeaponModsSection:Toggle({Name = "Fast Reload", Flag = "ArsenalFastReload", Default = false, Callback = function(Value)
        ArsenalAdapter:FastReload(Value)
    end})

    local _fireRateEnabled = false
    local _fireRateMultiplier = 2
    local FireRateSlider
    WeaponModsSection:Toggle({Name = "Fire Rate Modifier", Flag = "ArsenalFireRate", Default = false, Callback = function(Value)
        _fireRateEnabled = Value
        ArsenalAdapter:FireRateModifier(Value, _fireRateMultiplier)
        if FireRateSlider then
            pcall(function() FireRateSlider:SetVisibility(Value) end)
        end
    end})
    FireRateSlider = WeaponModsSection:Slider({Name = "Fire Rate Multiplier", Flag = "ArsenalFireRateMult", Default = 2, Min = 1, Max = 10, Increment = 0.5, Suffix = "x", Callback = function(Value)
        _fireRateMultiplier = Value
        if _fireRateEnabled then
            ArsenalAdapter:FireRateModifier(true, Value)
        end
    end})
    FireRateSlider:SetVisibility(false)

    WeaponModsSection:Toggle({Name = "Infinite Ammo", Flag = "ArsenalInfAmmo", Default = false, Callback = function(Value)
        ArsenalAdapter:InfiniteAmmo(Value)
    end})

    local _fovEnabled = false
    local _fovValue = 90
    local FovSlider
    GameSection:Toggle({Name = "FOV Changer", Flag = "ArsenalFOV", Default = false, Callback = function(Value)
        _fovEnabled = Value
        if Value then
            ArsenalAdapter:SetFOV(_fovValue)
        else
            ArsenalAdapter:ResetFOV()
        end
        if FovSlider then
            pcall(function() FovSlider:SetVisibility(Value) end)
        end
    end})
    FovSlider = GameSection:Slider({Name = "FOV", Flag = "ArsenalFOVValue", Default = 90, Min = 30, Max = 120, Increment = 1, Callback = function(Value)
        _fovValue = Value
        if _fovEnabled then
            ArsenalAdapter:SetFOV(Value)
        end
    end})
    FovSlider:SetVisibility(false)

    local SkinSection = GeneralSubTab:Section({Name = "Skin-Changer", Side = 2})
    SkinSection:Toggle({Name = "Unlock All Items", Flag = "ArsenalUnlockAll", Default = false, Callback = function(Value)
        ArsenalAdapter:UnlockAll(Value)
    end})
    SkinSection:Dropdown({
        Name = "Melee Skins",
        Flag = "ArsenalMeleeSkin",
        Multi = true,
        Items = ArsenalAdapter:GetItemNames("Melees"),
        Callback = function(Value)
            ArsenalAdapter:SetSelectedItems("Melees", Value)
        end
    })
    SkinSection:Dropdown({
        Name = "Gun Skins",
        Flag = "ArsenalGunSkin",
        Multi = true,
        Items = ArsenalAdapter:GetItemNames("WeaponSkins"),
        Callback = function(Value)
            ArsenalAdapter:SetSelectedItems("WeaponSkins", Value)
        end
    })
    SkinSection:Dropdown({
        Name = "Kill Effects",
        Flag = "ArsenalKillEffect",
        Multi = true,
        Items = ArsenalAdapter:GetItemNames("KillEffects"),
        Callback = function(Value)
            ArsenalAdapter:SetSelectedItems("KillEffects", Value)
        end
    })
    SkinSection:Dropdown({
        Name = "Announcers",
        Flag = "ArsenalAnnouncer",
        Multi = true,
        Items = ArsenalAdapter:GetItemNames("Announcers"),
        Callback = function(Value)
            ArsenalAdapter:SetSelectedItems("Announcers", Value)
        end
    })
    SkinSection:Dropdown({
        Name = "Character Skins",
        Flag = "ArsenalCharSkin",
        Multi = true,
        Items = ArsenalAdapter:GetItemNames("Skins"),
        Callback = function(Value)
            ArsenalAdapter:SetSelectedItems("Skins", Value)
        end
    })
end

local WalkSection = MovementTab:Section({Name = "Walk", Side = 1})
local FlySection = MovementTab:Section({Name = "Fly", Side = 1})
local JumpSection = MovementTab:Section({Name = "Jump", Side = 2})
local SpeedSection = MovementTab:Section({Name = "Speed", Side = 2})

local OriginalUnload = Library.Unload
Library.Unload = function(self)
    if ESP then
        ESP:Unload()
    end
    ToolModifier:Unload()
    ParticleAura:Unload()
    OriginalUnload(self)
end

Library:Notification(string.format("reaper.lol loaded in %.4f seconds", os.clock() - LoadStart), 5, Library.Theme.Accent, {"rbxassetid://135757045959142", Color3.fromRGB(149, 255, 139)})

Library:Init()
