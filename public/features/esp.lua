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
    box.Thickness = 1
    box.Filled = false
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false

    self.Objects[player] = {
        Box = box,
        Name = name
    }

end

function ESP:Remove(player)

    local objects = self.Objects[player]

    if not objects then
        return
    end

    for _, drawing in pairs(objects) do
        drawing:Remove()
    end

    self.Objects[player] = nil

end

function ESP:Hide()

    for _, objects in pairs(self.Objects) do
        for _, drawing in pairs(objects) do
            drawing.Visible = false
        end
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

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if not humanoidRootPart or not humanoid then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        self:Create(player)

        local objects = self.Objects[player]

        local position, visible = Camera:WorldToViewportPoint(
            humanoidRootPart.Position
        )

        if not visible then
            objects.Box.Visible = false
            objects.Name.Visible = false
            continue
        end

        local scale = 1 / (position.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000

        local width = 35 * scale
        local height = 55 * scale

        -- BOX
        objects.Box.Size = Vector2.new(width, height)
        objects.Box.Position = Vector2.new(
            position.X - width / 2,
            position.Y - height / 2
        )

        objects.Box.Color = self.Flags.visuals_esp_color
        objects.Box.Visible = self.Flags.visuals_boxes

        -- NAME
        objects.Name.Text = player.Name
        objects.Name.Position = Vector2.new(
            position.X,
            position.Y - height / 2 - 16
        )

        objects.Name.Color = self.Flags.visuals_esp_color
        objects.Name.Visible = self.Flags.visuals_names

    end

end

Players.PlayerRemoving:Connect(function(player)

    if ESP.Objects[player] then
        ESP:Remove(player)
    end

end)

return ESP
