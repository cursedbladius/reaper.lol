local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}

function ESP:Init(flagsTable)
    self.Flags = flagsTable
end

function ESP:Create(player)

    if self.Objects[player] then
        return
    end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Filled = false
    box.Thickness = 1

    local name = Drawing.new("Text")
    name.Visible = false
    name.Center = true
    name.Outline = true
    name.Size = 13

    self.Objects[player] = {
        Box = box,
        Name = name
    }

end

function ESP:Hide()

    for _, drawings in pairs(self.Objects) do
        drawings.Box.Visible = false
        drawings.Name.Visible = false
    end

end

function ESP:Update()

    for _, player in pairs(Players:GetPlayers()) do

        if player == LocalPlayer then
            continue
        end

        local character = player.Character

        if not character then
            continue
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if not root or not humanoid then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        self:Create(player)

        local drawings = self.Objects[player]

        local position, visible = Camera:WorldToViewportPoint(root.Position)

        if not visible then
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            continue
        end

        local width = 60
        local height = 100

        -- BOX
        drawings.Box.Size = Vector2.new(width, height)

        drawings.Box.Position = Vector2.new(
            position.X - width / 2,
            position.Y - height / 2
        )

        drawings.Box.Color = self.Flags.visuals_esp_color or Color3.fromRGB(255,0,0)
        drawings.Box.Visible = self.Flags.visuals_boxes

        -- NAME
        drawings.Name.Text = player.Name

        drawings.Name.Position = Vector2.new(
            position.X,
            position.Y - height / 2 - 15
        )

        drawings.Name.Color = Color3.fromRGB(255,255,255)
        drawings.Name.Visible = self.Flags.visuals_names

    end

end

return ESP
