local ESP = {
    Enabled = false,
    Connections = {},
    Cache = {},
    Settings = {
        -- Toggles
        Box = true,
        Name = true,
        HealthBar = true,
        Distance = false,
        Skeleton = false,
        Chams = false,
        Tool = false,
        -- Colors
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        HealthColor = Color3.fromRGB(0, 255, 0),
        DistanceColor = Color3.fromRGB(255, 255, 255),
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        ChamsColor = Color3.fromRGB(255, 0, 0),
        ToolColor = Color3.fromRGB(255, 255, 255),
        -- Options
        MaxDistance = 1000,
        BoxType = "Dynamic",
        Font = "Default (Tahoma)",
        VisibleOnly = false,
        TeamCheck = true,
        TextSize = 13
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Utility Functions
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

local function IsEnemy(Player)
    if not ESP.Settings.TeamCheck then return true end
    if not LocalPlayer.Team then return true end
    return Player.Team ~= LocalPlayer.Team
end

-- Initialize ESP for Player
function ESP:InitPlayer(Player)
    if self.Cache[Player] then return end
    
    self.Cache[Player] = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Tool = Drawing.new("Text"),
        Skeleton = {},
        Chams = nil
    }
    
    local cache = self.Cache[Player]
    
    -- Setup drawing objects
    cache.Box.Thickness = 1
    cache.Box.Filled = false
    cache.Box.ZIndex = 2
    
    cache.BoxOutline.Thickness = 3
    cache.BoxOutline.Filled = false
    cache.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    cache.BoxOutline.ZIndex = 1
    
    cache.Name.Size = self.Settings.TextSize
    cache.Name.Center = true
    cache.Name.Outline = true
    cache.Name.ZIndex = 3
    
    cache.HealthBar.Filled = true
    cache.HealthBar.ZIndex = 2
    
    cache.HealthBarOutline.Filled = false
    cache.HealthBarOutline.Thickness = 1
    cache.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    cache.HealthBarOutline.ZIndex = 1
    
    cache.Distance.Size = self.Settings.TextSize
    cache.Distance.Center = true
    cache.Distance.Outline = true
    cache.Distance.ZIndex = 3
    
    cache.Tool.Size = self.Settings.TextSize
    cache.Tool.Center = true
    cache.Tool.Outline = true
    cache.Tool.ZIndex = 3
    
    -- Skeleton lines
    for i = 1, 10 do
        cache.Skeleton[i] = Drawing.new("Line")
        cache.Skeleton[i].Thickness = 1
        cache.Skeleton[i].ZIndex = 2
    end
end

-- Clear ESP for Player
function ESP:ClearPlayer(Player)
    local cache = self.Cache[Player]
    if not cache then return end
    
    cache.Box.Visible = false
    cache.BoxOutline.Visible = false
    cache.Name.Visible = false
    cache.HealthBar.Visible = false
    cache.HealthBarOutline.Visible = false
    cache.Distance.Visible = false
    cache.Tool.Visible = false
    
    for _, line in ipairs(cache.Skeleton) do
        line.Visible = false
    end
    
    if cache.Chams then
        cache.Chams:Destroy()
        cache.Chams = nil
    end
end

-- Remove ESP for Player
function ESP:RemovePlayer(Player)
    self:ClearPlayer(Player)
    local cache = self.Cache[Player]
    if cache then
        cache.Box:Remove()
        cache.BoxOutline:Remove()
        cache.Name:Remove()
        cache.HealthBar:Remove()
        cache.HealthBarOutline:Remove()
        cache.Distance:Remove()
        cache.Tool:Remove()
        for _, line in ipairs(cache.Skeleton) do
            line:Remove()
        end
        if cache.Chams then
            cache.Chams:Destroy()
        end
    end
    self.Cache[Player] = nil
end

-- Update Player ESP
function ESP:UpdatePlayer(Player)
    if not self.Enabled then
        self:ClearPlayer(Player)
        return
    end
    
    if not self.Cache[Player] then
        self:InitPlayer(Player)
    end
    
    local cache = self.Cache[Player]
    local Character = GetCharacter(Player)
    
    if not Character then
        self:ClearPlayer(Player)
        return
    end
    
    local Humanoid = GetHumanoid(Character)
    if not Humanoid then
        self:ClearPlayer(Player)
        return
    end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then
        self:ClearPlayer(Player)
        return
    end
    
    local Position, OnScreen, Distance = WorldToScreen(RootPart.Position)
    
    if not OnScreen or Distance > self.Settings.MaxDistance then
        self:ClearPlayer(Player)
        return
    end
    
    if not IsEnemy(Player) then
        self:ClearPlayer(Player)
        return
    end
    
    -- Calculate box size based on character
    local head = Character:FindFirstChild("Head")
    local torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    
    if not head or not torso then
        self:ClearPlayer(Player)
        return
    end
    
    local headPos = WorldToScreen(head.Position)
    local torsoPos = WorldToScreen(torso.Position)
    local legPos = WorldToScreen(torso.Position - Vector3.new(0, 3, 0))
    
    if not headPos or not legPos then
        self:ClearPlayer(Player)
        return
    end
    
    local boxHeight = math.abs(legPos.Y - headPos.Y)
    local boxWidth = boxHeight * 0.5
    
    local boxX = Position.X - boxWidth / 2
    local boxY = headPos.Y
    
    -- Box ESP
    if self.Settings.Box then
        cache.Box.Visible = true
        cache.Box.Position = Vector2.new(boxX, boxY)
        cache.Box.Size = Vector2.new(boxWidth, boxHeight)
        cache.Box.Color = self.Settings.BoxColor
        
        cache.BoxOutline.Visible = true
        cache.BoxOutline.Position = Vector2.new(boxX, boxY)
        cache.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
    else
        cache.Box.Visible = false
        cache.BoxOutline.Visible = false
    end
    
    -- Name ESP
    if self.Settings.Name then
        cache.Name.Visible = true
        cache.Name.Text = Player.Name
        cache.Name.Position = Vector2.new(Position.X, boxY - 18)
        cache.Name.Color = self.Settings.NameColor
    else
        cache.Name.Visible = false
    end
    
    -- Health Bar
    if self.Settings.HealthBar then
        local health = Humanoid.Health
        local maxHealth = Humanoid.MaxHealth
        local healthPercent = math.clamp(health / maxHealth, 0, 1)
        
        local barWidth = 4
        local barHeight = boxHeight
        local barX = boxX - barWidth - 4
        
        cache.HealthBarOutline.Visible = true
        cache.HealthBarOutline.Position = Vector2.new(barX - 1, boxY - 1)
        cache.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
        
        cache.HealthBar.Visible = true
        cache.HealthBar.Position = Vector2.new(barX, boxY + (barHeight * (1 - healthPercent)))
        cache.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
        cache.HealthBar.Color = self.Settings.HealthColor
    else
        cache.HealthBar.Visible = false
        cache.HealthBarOutline.Visible = false
    end
    
    -- Distance ESP
    if self.Settings.Distance then
        local meters = math.floor(Distance * 0.28)
        cache.Distance.Visible = true
        cache.Distance.Text = string.format("[%dm]", meters)
        cache.Distance.Position = Vector2.new(Position.X, boxY + boxHeight + 2)
        cache.Distance.Color = self.Settings.DistanceColor
    else
        cache.Distance.Visible = false
    end
    
    -- Tool ESP
    if self.Settings.Tool then
        local tool = Character:FindFirstChildOfClass("Tool")
        cache.Tool.Visible = true
        cache.Tool.Text = tool and tool.Name or "None"
        cache.Tool.Position = Vector2.new(Position.X, boxY + boxHeight + 15)
        cache.Tool.Color = self.Settings.ToolColor
    else
        cache.Tool.Visible = false
    end
    
    -- Skeleton ESP (placeholder)
    if self.Settings.Skeleton then
        for _, line in ipairs(cache.Skeleton) do
            line.Visible = false
        end
    else
        for _, line in ipairs(cache.Skeleton) do
            line.Visible = false
        end
    end
    
    -- Chams ESP (placeholder)
    if self.Settings.Chams then
        -- Placeholder for chams implementation
    else
        if cache.Chams then
            cache.Chams:Destroy()
            cache.Chams = nil
        end
    end
end

-- Main Update Loop
function ESP:Update()
    if not self.Enabled then
        for Player, _ in pairs(self.Cache) do
            self:ClearPlayer(Player)
        end
        return
    end
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            self:UpdatePlayer(Player)
        end
    end
end

-- Control Functions
function ESP:Toggle(State)
    self.Enabled = State
    if not State then
        for Player, _ in pairs(self.Cache) do
            self:ClearPlayer(Player)
        end
    end
end

function ESP:SetSetting(Name, Value)
    if self.Settings[Name] ~= nil then
        self.Settings[Name] = Value
    end
end

function ESP:Initialize()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            self:InitPlayer(Player)
        end
    end
    
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(Player)
        if Player ~= LocalPlayer then
            ESP:InitPlayer(Player)
        end
    end))
    
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(Player)
        ESP:RemovePlayer(Player)
    end))
    
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        ESP:Update()
    end))
end

function ESP:Unload()
    for _, Connection in ipairs(self.Connections) do
        Connection:Disconnect()
    end
    self.Connections = {}
    
    for Player, _ in pairs(self.Cache) do
        self:RemovePlayer(Player)
    end
    self.Cache = {}
end

return ESP
