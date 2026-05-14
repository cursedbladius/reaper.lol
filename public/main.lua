local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("main loaded")

-- UI LIBRARY
local library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"
))()

print("library loaded")

local flags = library.flags

-- WINDOW
local window = library:window({
    name = "reaper.lol",
    size = UDim2.fromOffset(500, 650)
})

print("window created")

-- TABS
local visuals = window:tab({
    name = "Visuals"
})

local combat = window:tab({
    name = "Combat"
})

local misc = window:tab({
    name = "Misc"
})

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
    default = false,

    callback = function(bool)
        print("ESP:", bool)
    end
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

-- KEYBIND
miscSection:keybind({
    name = "UI Bind",
    flag = "menu_bind",
    default = Enum.KeyCode.End,

    callback = function(state)
        print("Keybind pressed:", state)
    end
})

-- LOAD ESP MODULE
local ESP = loadstring(game:HttpGet(
    "https://cdn.getbliss.win/features/esp.lua"
))()

print("esp module loaded")

ESP:Init(flags)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()

    if flags.visuals_esp then
        ESP:Update()
    else
        ESP:Hide()
    end

end)

print("script fully loaded")
