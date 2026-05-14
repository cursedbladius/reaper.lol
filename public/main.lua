-- main.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- UI LIBRARY
local library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"
))()

local flags = library.flags

-- WINDOW
local window = library:window({
    name = "reaper.lol",
    size = UDim2.fromOffset(500, 650)
})

-- TABS
local visuals = window:tab({name = "Visuals"})
local combat = window:tab({name = "Combat"})
local misc = window:tab({name = "Misc"})

-- SECTIONS
local espSection = visuals:section({
    name = "ESP"
})

local aimSection = combat:section({
    name = "Aim"
})

local miscSection = misc:section({
    name = "Misc"
})

-- ESP TOGGLES
espSection:toggle({
    name = "Enable ESP",
    flag = "visuals_esp",
    default = false
})

espSection:toggle({
    name = "Boxes",
    flag = "visuals_boxes",
    default = true
})

espSection:toggle({
    name = "Names",
    flag = "visuals_names",
    default = true
})

espSection:toggle({
    name = "Tracers",
    flag = "visuals_tracers",
    default = false
})

espSection:colorpicker({
    name = "ESP Color",
    flag = "visuals_esp_color",
    color = Color3.fromRGB(255, 0, 0)
})

-- AIMBOT
aimSection:toggle({
    name = "Enable Aimbot",
    flag = "combat_aimbot",
    default = false
})

aimSection:slider({
    name = "FOV",
    flag = "combat_fov",
    default = 120,
    min = 0,
    max = 500,
    interval = 1
})

aimSection:slider({
    name = "Smoothness",
    flag = "combat_smoothness",
    default = 5,
    min = 1,
    max = 20,
    interval = 1
})

aimSection:dropdown({
    name = "Hit Part",
    flag = "combat_hitpart",
    items = {"Head", "HumanoidRootPart"},
    multi = false
})

-- MENU KEYBIND
miscSection:keybind({
    name = "UI Bind",
    flag = "menu_bind",
    default = Enum.KeyCode.End,

    callback = function()
        print("Menu toggled")
    end
})

-- LOAD MODULES
local ESP = loadstring(game:HttpGet(
    "https://reaper.lol/features/esp.lua"
))()

ESP:Init(flags)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()

    if flags.visuals_esp then
        ESP:Update()
    else
        ESP:Hide()
    end

end)