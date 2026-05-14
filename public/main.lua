local RunService = game:GetService("RunService")

-- ── Load UI library ───────────────────────────────────────────────────────────
local library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"
))()

local flags = library.flags

-- ── Global cleanup tables ─────────────────────────────────────────────────────
getgenv().reaper_connections = getgenv().reaper_connections or {}
getgenv().reaper_objects     = getgenv().reaper_objects     or {}

-- ── Window ────────────────────────────────────────────────────────────────────
local window = library:window({
    name = "reaper.lol",
    size = UDim2.fromOffset(500, 650),
})

-- ── Tabs ──────────────────────────────────────────────────────────────────────
local visuals  = window:tab({ name = "Visuals"  })
local settings = window:tab({ name = "Settings" })

-- ── Sections ──────────────────────────────────────────────────────────────────
local elementsSection = visuals:section({ name = "Elements" })
local optionsSection  = visuals:section({ name = "Options"  })
local settingsSection = settings:section({ name = "Client"  })

-- ══ ELEMENTS ══════════════════════════════════════════════════════════════════

-- Master toggle — enables/disables the whole ESP loop
local espToggle = elementsSection:toggle({
    name    = "ESP",
    flag    = "visuals_esp",
    default = false,
})

-- Chams color picker attached to the ESP toggle
espToggle:colorpicker({
    flag  = "visuals_esp_color",
    color = Color3.fromRGB(255, 80, 80),
})

-- Chams toggle + colorpicker
local chamsToggle = elementsSection:toggle({
    name    = "Chams",
    flag    = "visuals_chams",
    default = true,
})

chamsToggle:colorpicker({
    flag  = "visuals_chams_color",
    color = Color3.fromRGB(255, 50, 50),
})

-- Cham type: pure Roblox Highlight overlay vs custom part-mutation mode
elementsSection:dropdown({
    name    = "Type",
    flag    = "visuals_chams_type",
    items   = { "Highlight", "Custom" },
    multi   = false,
    default = "Highlight",
})

-- Effect: only active when Type = Custom
-- Static  → solid material + color
-- Pulse   → breathing transparency animation
-- Rainbow → HSV hue cycle through full spectrum
-- Glitch  → deterministic flicker between base color and complementary
elementsSection:dropdown({
    name    = "Effect",
    flag    = "visuals_chams_effect",
    items   = { "Static", "Pulse", "Rainbow", "Glitch" },
    multi   = false,
    default = "Static",
})

-- Material: sets the Enum.Material on character parts (visible in Custom mode)
elementsSection:dropdown({
    name  = "Material",
    flag  = "visuals_chams_material",
    items = { "Plastic", "ForceField", "Neon", "Glass", "SmoothPlastic" },
    multi = false,
})

-- ══ OPTIONS ═══════════════════════════════════════════════════════════════════

optionsSection:toggle({
    name    = "Team Check",
    flag    = "visuals_teamcheck",
    default = false,
})

optionsSection:toggle({
    name    = "Occluded Check",
    flag    = "visuals_occluded",
    default = false,
})

optionsSection:slider({
    name     = "Render Distance",
    suffix   = " studs",
    flag     = "visuals_distance",
    default  = 2500,
    min      = 1,
    max      = 5000,
    interval = 1,
})

-- ══ SETTINGS ══════════════════════════════════════════════════════════════════

settingsSection:button({
    name     = "Unload",
    callback = function()

        -- 1. Stop all registered event connections (includes the RenderStepped loop)
        for _, conn in pairs(getgenv().reaper_connections) do
            pcall(function() conn:Disconnect() end)
        end
        getgenv().reaper_connections = {}

        -- 2. Destroy all registered GUI / instance objects
        for _, obj in pairs(getgenv().reaper_objects) do
            pcall(function() obj:Destroy() end)
        end
        getgenv().reaper_objects = {}

        -- 3. Tear down the UI window
        if library.unload then
            pcall(function() library:unload() end)
        elseif library.base then
            pcall(function() library.base:Destroy() end)
        end

    end,
})

-- ══ LOAD FEATURES ════════════════════════════════════════════════════════════

local ESP = loadstring(game:HttpGet(
    "https://reaper-lol.pages.dev/features/esp.lua"
))()

ESP:Init(flags)

-- ── Render loop ───────────────────────────────────────────────────────────────
local connection = RunService.RenderStepped:Connect(function()
    if flags.visuals_esp then
        if flags.visuals_chams then
            ESP:Update()
        else
            ESP:Hide()
        end
    else
        ESP:Hide()
    end
end)

-- Register for cleanup on unload
table.insert(getgenv().reaper_connections, connection)
