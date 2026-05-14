local Players = game:GetService("Players")

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

    local character = player.Character

    if not character then
        return
    end

    local highlight = Instance.new("Highlight")

    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.OutlineColor = Color3.fromRGB(255,255,255)

    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Adornee = character
    highlight.Parent = game.CoreGui

    self.Objects[player] = highlight

end

function ESP:Hide()

    for _, highlight in pairs(self.Objects) do
        highlight.Enabled = false
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

        if not self.Objects[player] then
            self:Create(player)
        end

        local highlight = self.Objects[player]

        if highlight then
            highlight.Enabled = self.Flags.visuals_esp
        end

    end

end

Players.PlayerRemoving:Connect(function(player)

    local obj = ESP.Objects[player]

    if obj then
        obj:Destroy()
        ESP.Objects[player] = nil
    end

end)

return ESP
