local RunService = game:GetService("RunService")

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

-- ESP
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

-- MENU KEYBIND
miscSection:keybind({
    name = "UI Bind",
    flag = "menu_bind",
    default = Enum.KeyCode.End,

    callback = function(state)
        print("Menu keybind:", state)
    end
})

-- LOAD ESP MODULE
local ESP = loadstring(game:HttpGet(
    "https://reaper-lol.pages.dev/features/esp.lua"
))()

ESP:Init(flags)

-- LOOP
RunService.RenderStepped:Connect(function()

    if flags.visuals_esp then
        ESP:Update()
    else
        ESP:Hide()
    end

end)
