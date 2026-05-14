local RunService = game:GetService("RunService")
local chamsToggle = elementsSection:toggle({
    name = "Chams",
    flag = "visuals_chams",
    default = true
})

chamsToggle:colorpicker({
    flag = "visuals_chams_color",
    color = Color3.fromRGB(255, 0, 0)
})

elementsSection:dropdown({
    name = "Cham Material",
    flag = "visuals_chams_material",
    items = {
        "Plastic",
        "ForceField",
        "Neon",
        "Glass",
        "SmoothPlastic"
    },
    multi = false,
    callback = function(option)
        print(option)
    end
})

optionsSection:toggle({
    name = "Team Check",
    flag = "visuals_teamcheck",
    default = false
})

optionsSection:toggle({
    name = "Occluded Check",
    flag = "visuals_occluded",
    default = false
})

optionsSection:slider({
    name = "Render Distance",
    suffix = " studs",
    flag = "visuals_distance",
    default = 2500,
    min = 1,
    max = 5000,
    interval = 1
})

settingsSection:button({
    name = "Unload",
    callback = function()

        for _, connection in pairs(getgenv().reaper_connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        for _, object in pairs(getgenv().reaper_objects) do
            pcall(function()
                object:Destroy()
            end)
        end

        if library.base then
            library.base:Destroy()
        end

        getgenv().reaper_connections = {}
        getgenv().reaper_objects = {}

    end
})

local ESP = loadstring(game:HttpGet(
    "https://reaper-lol.pages.dev/features/esp.lua"
))()

ESP:Init(flags)

local connection = RunService.RenderStepped:Connect(function()

    if flags.visuals_esp then
        ESP:Update()
    else
        ESP:Hide()
    end

end)

table.insert(getgenv().reaper_connections, connection)
