local LoadStart = os.clock()

local Library = loadstring(game:HttpGet("https://reaper-lol.pages.dev/ui/library.lua"))()

-- Load ESP Module
local ESP = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/esp.lua"))()
ESP:Initialize()

--
local Window = Library:Window({
    Name = "reaper.lol",
    FadeSpeed = 0.25
})

local Watermark = Library:Watermark("reaper.lol ~ ".. os.date("%b %d %Y") .. " ~ ".. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
local KeybindList = Library:KeybindList()

Watermark:SetVisibility(true)
KeybindList:SetVisibility(false)

-- Tabs
local CombatTab = Window:Page({Name = "Combat", Columns = 2, Subtabs = false})
local VisualsTab = Window:Page({Name = "Visuals", Columns = 2, Subtabs = false})
local MovementTab = Window:Page({Name = "Movement", Columns = 2, Subtabs = false})
local MiscTab = Window:Page({Name = "Misc", Columns = 2, Subtabs = false})
local PlayersTab = Window:Page({Name = "Players", Columns = 2, Subtabs = false})
local SettingsTab = Library:CreateSettingsPage(Window, Watermark, KeybindList)

-- Combat Tab (Empty sections)
local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = 1})
local SilentAimSection = CombatTab:Section({Name = "Silent Aim", Side = 1})
local TargetSection = CombatTab:Section({Name = "Target", Side = 2})
local WeaponSection = CombatTab:Section({Name = "Weapon", Side = 2})

-- Visuals Tab (Multiple ESP Sections - Balanced)
local ESPSection = VisualsTab:Section({Name = "ESP Master", Side = 1})
local BoxSection = VisualsTab:Section({Name = "ESP Box", Side = 1})
local TextSection = VisualsTab:Section({Name = "ESP Text", Side = 1})
local BarSection = VisualsTab:Section({Name = "ESP Bars", Side = 2})
local VisualEffectsSection = VisualsTab:Section({Name = "Visual Effects", Side = 2})

-- ESP Master Section
ESPSection:Toggle({Name = "Enabled", Flag = "ESPEnabled", Default = false, Callback = function(Value)
    ESP:Toggle(Value)
end})

ESPSection:Slider({Name = "Max Distance", Min = 100, Max = 5000, Default = 2000, Decimals = 0, Flag = "MaxESPDistance", Callback = function(Value)
    ESP:SetSetting("MaxDistance", Value)
end})

ESPSection:Toggle({Name = "Team Check", Flag = "ESPTeamCheck", Default = true, Callback = function(Value)
    ESP:SetSetting("TeamCheck", Value)
end})

ESPSection:Toggle({Name = "Visible Only", Flag = "ESPVisibleOnly", Default = false, Callback = function(Value)
    ESP:SetSetting("VisibleOnly", Value)
end})

-- ESP Box Section
BoxSection:Toggle({Name = "Box", Flag = "ESPBox", Default = true, Callback = function(Value)
    ESP:SetSetting("Box", Value)
end}):Colorpicker({Name = "Box Color", Flag = "ESPBoxColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("BoxColor", Value)
end})

BoxSection:Dropdown({Name = "Box Type", Flag = "ESPBoxType", Default = "Full", Items = {"Corner", "Full"}, Callback = function(Value)
    ESP:SetSetting("BoxType", Value)
end})

BoxSection:Toggle({Name = "Filled", Flag = "ESPBoxFilled", Default = false, Callback = function(Value)
    ESP:SetSetting("BoxFilled", Value)
end})

BoxSection:Toggle({Name = "Gradient Fill", Flag = "ESPBoxGradient", Default = true, Callback = function(Value)
    ESP:SetSetting("BoxFillGradient", Value)
end}):Colorpicker({Name = "Gradient Start", Flag = "ESPBoxFillStart", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("BoxFillColorStart", Value)
end})

BoxSection:Label({Name = "Gradient End:"}):Colorpicker({Name = "", Flag = "ESPBoxFillEnd", Default = Color3.fromRGB(0, 255, 0), Callback = function(Value)
    ESP:SetSetting("BoxFillColorEnd", Value)
end})

BoxSection:Slider({Name = "Fill Transparency", Min = 0, Max = 1, Default = 0.5, Decimals = 2, Flag = "ESPFillTrans", Callback = function(Value)
    ESP:SetSetting("BoxFillTransparency", Value)
end})

-- ESP Text Section
TextSection:Toggle({Name = "Names", Flag = "ESPNames", Default = true, Callback = function(Value)
    ESP:SetSetting("Name", Value)
end}):Colorpicker({Name = "Name Color", Flag = "ESPNameColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("NameColor", Value)
end})

TextSection:Toggle({Name = "Distance", Flag = "ESPDistance", Default = false, Callback = function(Value)
    ESP:SetSetting("Distance", Value)
end}):Colorpicker({Name = "Distance Color", Flag = "ESPDistanceColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("DistanceColor", Value)
end})

TextSection:Toggle({Name = "Tool", Flag = "ESPTool", Default = false, Callback = function(Value)
    ESP:SetSetting("Tool", Value)
end}):Colorpicker({Name = "Tool Color", Flag = "ESPToolColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    ESP:SetSetting("ToolColor", Value)
end})

-- ESP Bars Section
BarSection:Toggle({Name = "Health Bar", Flag = "ESPHealthBar", Default = true, Callback = function(Value)
    ESP:SetSetting("HealthBar", Value)
end}):Colorpicker({Name = "Health Low", Flag = "ESPHealthLow", Default = Color3.fromRGB(255, 0, 0), Callback = function(Value)
    ESP:SetSetting("HealthColor1", Value)
end})

BarSection:Label({Name = "Health Mid:"}):Colorpicker({Name = "", Flag = "ESPHealthMid", Default = Color3.fromRGB(255, 255, 0), Callback = function(Value)
    ESP:SetSetting("HealthColor2", Value)
end})

BarSection:Label({Name = "Health High:"}):Colorpicker({Name = "", Flag = "ESPHealthHigh", Default = Color3.fromRGB(0, 255, 0), Callback = function(Value)
    ESP:SetSetting("HealthColor3", Value)
end})

BarSection:Toggle({Name = "Health Lerp", Flag = "ESPHealthLerp", Default = true, Callback = function(Value)
    ESP:SetSetting("HealthBarLerp", Value)
end})

BarSection:Toggle({Name = "Armor Bar", Flag = "ESPArmorBar", Default = false, Callback = function(Value)
    ESP:SetSetting("ArmorBar", Value)
end}):Colorpicker({Name = "Armor Low", Flag = "ESPArmorLow", Default = Color3.fromRGB(1, 0, 0), Callback = function(Value)
    ESP:SetSetting("ArmorColor3", Value)
end})

BarSection:Label({Name = "Armor Mid:"}):Colorpicker({Name = "", Flag = "ESPArmorMid", Default = Color3.fromRGB(135, 206, 235), Callback = function(Value)
    ESP:SetSetting("ArmorColor2", Value)
end})

BarSection:Label({Name = "Armor High:"}):Colorpicker({Name = "", Flag = "ESPArmorHigh", Default = Color3.fromRGB(0, 0, 255), Callback = function(Value)
    ESP:SetSetting("ArmorColor1", Value)
end})

BarSection:Toggle({Name = "Armor Lerp", Flag = "ESPArmorLerp", Default = true, Callback = function(Value)
    ESP:SetSetting("ArmorBarLerp", Value)
end})

-- Visual Effects Section
VisualEffectsSection:Toggle({Name = "Remove Fog", Flag = "RemoveFog", Default = false})
VisualEffectsSection:Toggle({Name = "Full Bright", Flag = "FullBright", Default = false})
VisualEffectsSection:Slider({Name = "Brightness", Min = 0, Max = 10, Default = 1, Decimals = 1, Flag = "Brightness"})
VisualEffectsSection:Toggle({Name = "FOV Changer", Flag = "FOVChanger", Default = false})
VisualEffectsSection:Slider({Name = "FOV", Min = 30, Max = 150, Default = 70, Decimals = 0, Flag = "FOVValue"})

-- Movement Tab (Empty sections)
local WalkSection = MovementTab:Section({Name = "Walk", Side = 1})
local FlySection = MovementTab:Section({Name = "Fly", Side = 1})
local JumpSection = MovementTab:Section({Name = "Jump", Side = 2})
local SpeedSection = MovementTab:Section({Name = "Speed", Side = 2})

-- Misc Tab (Empty sections)
local AntiSection = MiscTab:Section({Name = "Anti-Aim", Side = 1})
local ExploitsSection = MiscTab:Section({Name = "Exploits", Side = 1})
local WorldSection = MiscTab:Section({Name = "World", Side = 2})
local AutomationSection = MiscTab:Section({Name = "Automation", Side = 2})

-- Players Tab (Empty sections)
local TargetPlayerSection = PlayersTab:Section({Name = "Target Player", Side = 1})
local TrollingSection = PlayersTab:Section({Name = "Trolling", Side = 1})
local SpectateSection = PlayersTab:Section({Name = "Spectate", Side = 2})
local ServerSection = PlayersTab:Section({Name = "Server", Side = 2})

-- Initialization
Library:Notification(string.format("reaper.lol loaded in %.4f seconds", os.clock() - LoadStart), 5, Library.Theme.Accent, {"rbxassetid://135757045959142", Color3.fromRGB(149, 255, 139)})

Library:Init()
