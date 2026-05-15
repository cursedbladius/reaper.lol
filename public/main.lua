local LoadStart = os.clock()

local Library = loadstring(game:HttpGet("https://reaper-lol.pages.dev/ui/library.lua"))()

-- Load ESP Module
local ESP = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/esp.lua"))()
ESP:Initialize()

-- Create Window
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
local SettingsTab = Library:CreateSettingsPage(Window, Watermark, KeybindList)

-- Combat Tab (Empty sections)
local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = 1})
local SilentAimSection = CombatTab:Section({Name = "Silent Aim", Side = 1})
local TargetSection = CombatTab:Section({Name = "Target", Side = 2})
local WeaponSection = CombatTab:Section({Name = "Weapon", Side = 2})

-- Visuals Tab - Left Side (ESP Section)
local ESPSection = VisualsTab:Section({Name = "ESP", Side = 1})

-- ESP Toggles with Colorpickers
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

-- Visuals Tab - Right Side (Options Section)
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

-- Visuals Tab - Right Side (Extras Section)
local ExtrasSection = VisualsTab:Section({Name = "Extras", Side = 2})

local ToolModifierEnabled = false
local ToolModifierColor = Color3.fromRGB(255, 255, 255)
local ToolModifierAlpha = 0
local ToolModifierMaterial = "Default"
local CurrentTool = nil

local MaterialMap = {
    ["Default"] = nil,
    ["ForceField"] = Enum.Material.ForceField,
}

local ToolHighlight = nil
local ToolOriginalMaterials = {}

local function ResetToolModifier()
    if ToolHighlight then
        pcall(function() ToolHighlight:Destroy() end)
        ToolHighlight = nil
    end
    for part, mat in pairs(ToolOriginalMaterials) do
        pcall(function() part.Material = mat end)
    end
    ToolOriginalMaterials = {}
    CurrentTool = nil
end

local function ApplyToolModifier()
    local character = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        if ToolHighlight then
            ToolHighlight.Enabled = false
        end
        return
    end

    -- Reset when switching tools
    if tool ~= CurrentTool then
        ResetToolModifier()
        CurrentTool = tool
    end

    -- Handle Highlight for color tinting
    if ToolModifierMaterial ~= "ForceField" then
        if not ToolHighlight or not ToolHighlight.Parent then
            ToolHighlight = Instance.new("Highlight")
            ToolHighlight.OutlineTransparency = 1
            ToolHighlight.Parent = tool
        end
        ToolHighlight.Adornee = tool
        ToolHighlight.FillColor = ToolModifierColor
        ToolHighlight.FillTransparency = 1 - ToolModifierAlpha
        ToolHighlight.Enabled = true
    else
        if ToolHighlight then
            ToolHighlight.Enabled = false
        end
        -- Apply ForceField material to all visible parts
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                if not ToolOriginalMaterials[part] then
                    ToolOriginalMaterials[part] = part.Material
                end
                part.Material = Enum.Material.ForceField
            end
        end
    end
end

ExtrasSection:Toggle({Name = "Tool Modifier", Flag = "ToolModifier", Default = false, Callback = function(Value)
    ToolModifierEnabled = Value
    if not Value then
        ResetToolModifier()
    end
end}):Colorpicker({Name = "", Flag = "ToolModifierColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value, Alpha)
    ToolModifierColor = Value
    ToolModifierAlpha = Alpha or 0
end})

local ToolMaterialDropdown
ToolMaterialDropdown = ExtrasSection:Dropdown({
    Name = "Tool Material",
    Flag = "ToolModifierMaterial",
    Default = "Default",
    Items = {"Default", "ForceField"},
    Callback = function(Value)
        if Value == nil then
            ToolMaterialDropdown:Set("Default")
            return
        end
        ToolModifierMaterial = Value
        if Value == "Default" and ToolModifierEnabled then
            -- Restore ForceField materials back to original
            for part, mat in pairs(ToolOriginalMaterials) do
                pcall(function() part.Material = mat end)
            end
            ToolOriginalMaterials = {}
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if ToolModifierEnabled then
        ApplyToolModifier()
    end
end)

-- Movement Tab (Empty sections)
local WalkSection = MovementTab:Section({Name = "Walk", Side = 1})
local FlySection = MovementTab:Section({Name = "Fly", Side = 1})
local JumpSection = MovementTab:Section({Name = "Jump", Side = 2})
local SpeedSection = MovementTab:Section({Name = "Speed", Side = 2})

-- Hook ESP unload into Library unload
local OriginalUnload = Library.Unload
Library.Unload = function(self)
    -- Unload ESP first
    if ESP then
        ESP:Unload()
    end
    -- Reset tool modifier
    ResetToolModifier()
    ToolModifierEnabled = false
    -- Call original unload
    OriginalUnload(self)
end

-- Initialization
Library:Notification(string.format("reaper.lol loaded in %.4f seconds", os.clock() - LoadStart), 5, Library.Theme.Accent, {"rbxassetid://135757045959142", Color3.fromRGB(149, 255, 139)})

Library:Init()
