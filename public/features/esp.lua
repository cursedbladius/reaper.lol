local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP = {}
ESP.Objects = {}

local MaterialMap = {
    Plastic = Enum.Material.Plastic,
    ForceField = Enum.Material.ForceField,
    Neon = Enum.Material.Neon,
    Glass = Enum.Material.Glass,
    SmoothPlastic = Enum.Material.SmoothPlastic
}

function ESP:Init(flagsTable)
    self.Flags = flagsTable
end

function ESP:IsVisible(character)

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = (root.Position - origin)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        character
    }

    local result = Workspace:Raycast(origin, direction, params)

    return result == nil

end

function ESP:Create(player)

    if self.Objects[player] then
        return
    end

    local character = player.Character

    if not character then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "reaper_highlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = game.CoreGui
    highlight.Adornee = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "reaper_billboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = game.CoreGui
    billboard.Adornee = character:FindFirstChild("Head")

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1,0,1,0)
    text.Font = Enum.Font.Code
    text.TextScaled = true
    text.TextStrokeTransparency = 0
    text.Parent = billboard

    self.Objects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Text = text
    }

    table.insert(getgenv().reaper_objects, highlight)
    table.insert(getgenv().reaper_objects, billboard)

end

function ESP:Remove(player)

    local objects = self.Objects[player]

    if not objects then
        return
    end

    for _, object in pairs(objects) do
        object:Destroy()
    end

    self.Objects[player] = nil

end

function ESP:Hide()

    for _, objects in pairs(self.Objects) do
        objects.Highlight.Enabled = false
        objects.Billboard.Enabled = false
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

        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not root then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        if self.Flags.visuals_teamcheck then
            if player.Team == LocalPlayer.Team then

                local existing = self.Objects[player]

                if existing then
                    existing.Highlight.Enabled = false
                    existing.Billboard.Enabled = false
                end

                continue
            end
        end

        local localCharacter = LocalPlayer.Character

        if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then

            local distance = (
                localCharacter.HumanoidRootPart.Position - root.Position
            ).Magnitude

            if distance > (self.Flags.visuals_distance or 2500) then

                local existing = self.Objects[player]

                if existing then
                    existing.Highlight.Enabled = false
                    existing.Billboard.Enabled = false
                end

                continue
            end

        end

        self:Create(player)

        local objects = self.Objects[player]

        if self.Flags.visuals_occluded then

            if not self:IsVisible(character) then
                objects.Highlight.Enabled = false
                objects.Billboard.Enabled = false
                continue
            end

        end

        objects.Highlight.Enabled = self.Flags.visuals_chams
        objects.Highlight.FillColor = self.Flags.visuals_chams_color or Color3.fromRGB(255,0,0)
        objects.Highlight.OutlineColor = self.Flags.visuals_boxes_color or Color3.fromRGB(255,255,255)

        local materialName = self.Flags.visuals_chams_material or "Plastic"
        local material = MaterialMap[materialName]

        if material then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = material
                end
            end
        end

        objects.Billboard.Enabled = self.Flags.visuals_names
        objects.Text.Text = player.Name
        objects.Text.TextColor3 = self.Flags.visuals_names_color or Color3.fromRGB(255,255,255)

    end

end

Players.PlayerRemoving:Connect(function(player)

    if ESP.Objects[player] then
        ESP:Remove(player)
    end

end)

return ESP
