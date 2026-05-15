local LoadStart = os.clock()
local Library = loadstring(game:HttpGet("https://reaper-lol.pages.dev/ui/library.lua"))()

local ESP = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/visuals/esp.lua"))()
ESP:Initialize()

local ToolModifier = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/visuals/tool_modifier.lua"))()
local BulletTracers = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/visuals/bullet_tracers.lua"))()

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
local VisualsTab = Window:Page({Name = "Visuals", Columns = 2, Subtabs = false})
local MovementTab = Window:Page({Name = "Movement", Columns = 2, Subtabs = false})
local SettingsTab = Library:CreateSettingsPage(Window, Watermark, KeybindList)

local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = 1})
local SilentAimSection = CombatTab:Section({Name = "Silent Aim", Side = 1})
local TargetSection = CombatTab:Section({Name = "Target", Side = 2})
local WeaponSection = CombatTab:Section({Name = "Weapon", Side = 2})

local ESPSection = VisualsTab:Section({Name = "ESP", Side = 1})

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

local OptionsSection = VisualsTab:Section({Name = "Options", Side = 2})

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

local ExtrasSection = VisualsTab:Section({Name = "Weapon Modifier", Side = 2})

ExtrasSection:Toggle({Name = "Tool Modifier", Flag = "ToolModifier", Default = false, Callback = function(Value)
    ToolModifier.Enabled = Value
    if not Value then
        ToolModifier:Reset()
    end
end}):Colorpicker({Name = "", Flag = "ToolModifierColor", Default = Color3.fromRGB(255, 0, 0), DefaultAlpha = 0.4, Callback = function(Value, Alpha)
    ToolModifier.Color = Value
    ToolModifier.Alpha = Alpha or 0
end})

local OutlineToggle = ExtrasSection:Toggle({Name = "Outline", Flag = "ToolOutlineToggle", Default = true, Callback = function(Value)
    ToolModifier.OutlineEnabled = Value
end})
OutlineToggle:Colorpicker({Name = "", Flag = "ToolModifierOutline", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ToolModifier.OutlineColor = Value
end})

local ToolMaterialDropdown
ToolMaterialDropdown = ExtrasSection:Dropdown({
    Name = "Tool Material",
    Flag = "ToolModifierMaterial",
    Default = "Highlight",
    Items = {"Highlight", "ForceField", "Neon"},
    Callback = function(Value)
        if Value == nil then
            ToolMaterialDropdown:Set("Highlight")
            return
        end
        ToolModifier.Material = Value
        pcall(function()
            OutlineToggle:SetVisiblity(Value == "Highlight")
        end)
    end
})

local _toolModFrame = 0
game:GetService("RunService").RenderStepped:Connect(function()
    _toolModFrame = _toolModFrame + 1
    if _toolModFrame % 5 == 0 then
        ToolModifier:Apply()
    end
end)

if game.GameId == 111958650 or game.PlaceId == 286090429 then
    ArsenalAdapter:StartActor()
    local GunModSection = WeaponSection
    GunModSection:Toggle({Name = "No Recoil", Flag = "ArsenalNoRecoil", Default = false, Callback = function(Value)
        if Value then ArsenalAdapter:NoRecoil() end
    end})
    GunModSection:Toggle({Name = "No Spread", Flag = "ArsenalNoSpread", Default = false, Callback = function(Value)
        if Value then ArsenalAdapter:NoSpread() end
    end})
    GunModSection:Toggle({Name = "Fast Reload", Flag = "ArsenalFastReload", Default = false, Callback = function(Value)
        if Value then ArsenalAdapter:FastReload() end
    end})
    GunModSection:Toggle({Name = "Fast Fire Rate", Flag = "ArsenalFireRate", Default = false, Callback = function(Value)
        if Value then ArsenalAdapter:FastFireRate() end
    end})
    GunModSection:Toggle({Name = "Infinite Ammo", Flag = "ArsenalInfAmmo", Default = false, Callback = function(Value)
        if Value then ArsenalAdapter:InfiniteAmmo() end
    end})

    local ArmSection = VisualsTab:Section({Name = "Arm Modifier", Side = 2})
    ArmSection:Toggle({Name = "Arm Modifier", Flag = "ArmModifier", Default = false, Callback = function(Value)
        ToolModifier.ArmEnabled = Value
        if not Value then
            ToolModifier:ResetArms()
        end
    end}):Colorpicker({Name = "", Flag = "ArmModColor", Default = Color3.fromRGB(0, 255, 0), DefaultAlpha = 0.4, Callback = function(Value, Alpha)
        ToolModifier.ArmColor = Value
        ToolModifier.ArmAlpha = Alpha or 0
    end})

    local ArmOutlineToggle = ArmSection:Toggle({Name = "Outline", Flag = "ArmOutlineToggle", Default = true, Callback = function(Value)
        ToolModifier.ArmOutlineEnabled = Value
    end})
    ArmOutlineToggle:Colorpicker({Name = "", Flag = "ArmOutlineColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
        ToolModifier.ArmOutlineColor = Value
    end})

    local ArmMaterialDropdown
    ArmMaterialDropdown = ArmSection:Dropdown({
        Name = "Arm Material",
        Flag = "ArmMaterial",
        Default = "Highlight",
        Items = {"Highlight", "ForceField", "Neon"},
        Callback = function(Value)
            if Value == nil then
                ArmMaterialDropdown:Set("Highlight")
                return
            end
            ToolModifier.ArmMaterial = Value
            pcall(function()
                ArmOutlineToggle:SetVisiblity(Value == "Highlight")
            end)
        end
    })

    local TracerSection = VisualsTab:Section({Name = "Bullet Tracers", Side = 2})
    TracerSection:Toggle({Name = "Bullet Tracers", Flag = "BulletTracers", Default = false, Callback = function(Value)
        BulletTracers.Enabled = Value
        if Value then
            BulletTracers:StartHook()
        end
    end}):Colorpicker({Name = "", Flag = "TracerColor", Default = Color3.fromRGB(255, 0, 0), Callback = function(Value)
        BulletTracers.Color = Value
    end})
    TracerSection:Slider({Name = "Width", Flag = "TracerWidth", Default = 0.15, Min = 0.01, Max = 1, Decimals = 0.01, Callback = function(Value)
        BulletTracers.Width = Value
    end})
    TracerSection:Slider({Name = "Lifetime", Flag = "TracerLifetime", Default = 0.5, Min = 0.1, Max = 3, Decimals = 0.1, Callback = function(Value)
        BulletTracers.Lifetime = Value
    end})
    TracerSection:Textbox({Name = "Texture ID", Flag = "TracerTexture", Default = "", Callback = function(Value)
        BulletTracers.TextureId = Value
    end})

    local SkinSection = VisualsTab:Section({Name = "Skin-Changer", Side = 1})
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
    BulletTracers:Unload()
    OriginalUnload(self)
end

Library:Notification(string.format("reaper.lol loaded in %.4f seconds", os.clock() - LoadStart), 5, Library.Theme.Accent, {"rbxassetid://135757045959142", Color3.fromRGB(149, 255, 139)})

Library:Init()
