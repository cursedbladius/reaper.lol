local ESP = {
    Enabled = false,
    Players = {},
    Connections = {},
    Settings = {
        Box = true,
        HealthBar = true,
        Name = true,
        MaxDistance = 2000,
        TeamCheck = true,
        VisibleOnly = false
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Utility functions
local function WorldToScreen(Position)
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen, ScreenPos.Z
end

local function GetCharacter(Player)
    return Player.Character
end

local function GetHumanoid(Character)
    return Character:FindFirstChildOfClass("Humanoid")
end

local function GetHealth(Character)
    local Humanoid = GetHumanoid(Character)
    if Humanoid then
        return Humanoid.Health, Humanoid.MaxHealth
    end
    return 100, 100
end

local function IsEnemy(Player)
    if not ESP.Settings.TeamCheck then return true end
    if not LocalPlayer.Team then return true end
    return Player.Team ~= LocalPlayer.Team
end

local function IsVisible(Character)
    if not ESP.Settings.VisibleOnly then return true end
    local Head = Character:FindFirstChild("Head")
    if not Head then return false end
    local Origin = Camera.CFrame.Position
    local Direction = (Head.Position - Origin).Unit * (Head.Position - Origin).Magnitude
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Character}
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local Result = workspace:Raycast(Origin, Direction, RaycastParams)
    return not Result
end

-- Drawing objects management
local function CreateDrawing(Type, Properties)
    local Drawing = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        Drawing[Property] = Value
    end
    return Drawing
end

local function CreateESPObject(Player)
    return {
        Player = Player,
        Box = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1
        }),
        BoxFilled = CreateDrawing("Square", {
            Visible = false,
            Filled = true,
            Thickness = 0,
            Color = Color3.fromRGB(0, 0, 0),
            Transparency = 0.5
        }),
        HealthBar = CreateDrawing("Square", {
            Visible = false,
            Filled = true,
            Thickness = 0,
            Color = Color3.fromRGB(0, 255, 0),
            Transparency = 1
        }),
        HealthBarOutline = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Thickness = 1,
            Color = Color3.fromRGB(0, 0, 0),
            Transparency = 1
        }),
        Name = CreateDrawing("Text", {
            Visible = false,
            Text = Player.Name,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 13,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = 2
        })
    }
end

local function RemoveESPObject(Player)
    if ESP.Players[Player] then
        for _, Drawing in pairs(ESP.Players[Player]) do
            if typeof(Drawing) == "table" and Drawing.Remove then
                Drawing:Remove()
            end
        end
        ESP.Players[Player] = nil
    end
end

-- Health bar gradient colors
local function GetHealthColor(HealthPercent)
    -- Gradient from red (0%) to yellow (50%) to green (100%)
    if HealthPercent > 0.5 then
        -- Yellow to Green
        local t = (HealthPercent - 0.5) * 2
        return Color3.fromRGB(255 * (1 - t) + 0 * t, 255, 0)
    else
        -- Red to Yellow
        local t = HealthPercent * 2
        return Color3.fromRGB(255, 255 * t, 0)
    end
end

-- Main ESP update function
local function UpdateESP()
    if not ESP.Enabled then
        for _, Data in pairs(ESP.Players) do
            for _, Drawing in pairs(Data) do
                if typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
        end
        return
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character = GetCharacter(Player)
        if not Character then
            if ESP.Players[Player] then
                for _, Drawing in pairs(ESP.Players[Player]) do
                    if typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                        Drawing.Visible = false
                    end
                end
            end
            continue
        end

        if not ESP.Players[Player] then
            ESP.Players[Player] = CreateESPObject(Player)
        end

        local Data = ESP.Players[Player]
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        local Head = Character:FindFirstChild("Head")

        if not HumanoidRootPart or not Head then
            for _, Drawing in pairs(Data) do
                if typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        local Position, OnScreen, Distance = WorldToScreen(HumanoidRootPart.Position)
        
        if not OnScreen or Distance > ESP.Settings.MaxDistance then
            for _, Drawing in pairs(Data) do
                if typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        if not IsEnemy(Player) then
            for _, Drawing in pairs(Data) do
                if typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        if not IsVisible(Character) then
            for _, Drawing in pairs(Data) do
                if typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        -- Calculate box dimensions
        local TopPos = WorldToScreen(Head.Position + Vector3.new(0, 0.5, 0))
        local BottomPos = WorldToScreen(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
        
        local Height = math.abs(BottomPos.Y - TopPos.Y)
        local Width = Height / 2

        -- Update Box
        if ESP.Settings.Box then
            Data.Box.Size = Vector2.new(Width, Height)
            Data.Box.Position = Vector2.new(Position.X - Width / 2, TopPos.Y)
            Data.Box.Visible = true

            Data.BoxFilled.Size = Vector2.new(Width, Height)
            Data.BoxFilled.Position = Vector2.new(Position.X - Width / 2, TopPos.Y)
            Data.BoxFilled.Visible = true
        else
            Data.Box.Visible = false
            Data.BoxFilled.Visible = false
        end

        -- Update Health Bar
        if ESP.Settings.HealthBar then
            local Health, MaxHealth = GetHealth(Character)
            local HealthPercent = math.clamp(Health / MaxHealth, 0, 1)
            
            local BarWidth = 4
            local BarHeight = Height * 0.8
            local BarX = Position.X - Width / 2 - BarWidth - 3
            local BarY = TopPos.Y + (Height - BarHeight) / 2

            -- Outline
            Data.HealthBarOutline.Size = Vector2.new(BarWidth + 2, BarHeight + 2)
            Data.HealthBarOutline.Position = Vector2.new(BarX - 1, BarY - 1)
            Data.HealthBarOutline.Visible = true

            -- Health bar
            Data.HealthBar.Size = Vector2.new(BarWidth, BarHeight * HealthPercent)
            Data.HealthBar.Position = Vector2.new(BarX, BarY + BarHeight * (1 - HealthPercent))
            Data.HealthBar.Color = GetHealthColor(HealthPercent)
            Data.HealthBar.Visible = true
        else
            Data.HealthBar.Visible = false
            Data.HealthBarOutline.Visible = false
        end

        -- Update Name
        if ESP.Settings.Name then
            Data.Name.Position = Vector2.new(Position.X, TopPos.Y - 16)
            Data.Name.Visible = true
        else
            Data.Name.Visible = false
        end
    end
end

-- Player management
local function PlayerAdded(Player)
    ESP.Players[Player] = CreateESPObject(Player)
end

local function PlayerRemoving(Player)
    RemoveESPObject(Player)
end

-- ESP Control functions
function ESP:Toggle(State)
    self.Enabled = State
    if not State then
        for Player, _ in pairs(self.Players) do
            for _, Drawing in pairs(self.Players[Player]) do
                if typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
        end
    end
end

function ESP:SetSetting(Name, Value)
    if self.Settings[Name] ~= nil then
        self.Settings[Name] = Value
    end
end

function ESP:Initialize()
    -- Connect to existing players
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            PlayerAdded(Player)
        end
    end

    -- Connect events
    table.insert(self.Connections, Players.PlayerAdded:Connect(PlayerAdded))
    table.insert(self.Connections, Players.PlayerRemoving:Connect(PlayerRemoving))
    table.insert(self.Connections, RunService.RenderStepped:Connect(UpdateESP))
end

function ESP:Unload()
    for _, Connection in ipairs(self.Connections) do
        Connection:Disconnect()
    end
    self.Connections = {}

    for Player, _ in pairs(self.Players) do
        RemoveESPObject(Player)
    end
    self.Players = {}
end

return ESP
