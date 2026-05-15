local ESP = {
    Enabled = false,
    Players = {},
    Connections = {},
    Cache = {},
    Settings = {
        -- Box Settings
        Box = true,
        BoxType = "Full", -- "Full" or "Corner"
        BoxColor = Color3.fromRGB(255, 255, 255),
        -- Filled Box
        BoxFilled = false,
        BoxFillGradient = true,
        BoxFillColorStart = Color3.fromRGB(255, 255, 255),
        BoxFillColorEnd = Color3.fromRGB(0, 255, 0),
        BoxFillTransparency = 0.5,
        -- Text Settings
        Name = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        Distance = false,
        DistanceColor = Color3.fromRGB(255, 255, 255),
        Tool = false,
        ToolColor = Color3.fromRGB(255, 255, 255),
        -- Health Bar
        HealthBar = true,
        HealthBarLerp = true,
        HealthColor1 = Color3.fromRGB(255, 0, 0),     -- Low
        HealthColor2 = Color3.fromRGB(255, 255, 0),   -- Mid
        HealthColor3 = Color3.fromRGB(0, 255, 0),     -- High
        -- Armor Bar
        ArmorBar = false,
        ArmorBarLerp = true,
        ArmorColor1 = Color3.fromRGB(0, 0, 255),      -- Full
        ArmorColor2 = Color3.fromRGB(135, 206, 235),  -- Mid
        ArmorColor3 = Color3.fromRGB(1, 0, 0),        -- Low
        -- General
        MaxDistance = 2000,
        TeamCheck = true,
        VisibleOnly = false,
        TextSize = 11,
        Font = Enum.Font.SourceSansBold
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local guiInset = GuiService:GetGuiInset()

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

local function GetHealth(Character)
    local Humanoid = GetHumanoid(Character)
    if Humanoid then
        return Humanoid.Health, Humanoid.MaxHealth
    end
    return 100, 100
end

local function GetArmor(Character)
    local BodyEffects = Character:FindFirstChild("BodyEffects")
    if BodyEffects then
        local Armor = BodyEffects:FindFirstChild("Armor")
        if Armor then
            return Armor.Value, 130
        end
    end
    return 0, 130
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

-- Create Text Label
local function CreateTextLabel(Name, Parent)
    local Label = Instance.new("TextLabel")
    Label.Name = Name
    Label.Parent = Parent
    Label.Size = UDim2.new(0, 100, 0, 15)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextStrokeTransparency = 0
    Label.TextScaled = false
    Label.TextSize = ESP.Settings.TextSize
    Label.Font = ESP.Settings.Font
    Label.Text = ""
    Label.Visible = false
    return Label
end

-- Initialize ESP for Player
function ESP:InitPlayer(Player)
    if self.Cache[Player] then return end
    
    self.Cache[Player] = {
        Box = {},
        Bars = {},
        Text = {}
    }
    
    local cache = self.Cache[Player]
    
    -- Box Drawing Objects
    cache.Box.Square = Drawing.new("Square")
    cache.Box.Outline = Drawing.new("Square")
    cache.Box.Inline = Drawing.new("Square")
    
    -- Filled Box (ScreenGui)
    local filledGui = Instance.new("ScreenGui")
    filledGui.Name = Player.Name .. "_BoxFill"
    filledGui.Parent = CoreGui
    filledGui.ResetOnSpawn = false
    
    local filledFrame = Instance.new("Frame")
    filledFrame.Name = "Fill"
    filledFrame.Parent = filledGui
    filledFrame.BorderSizePixel = 0
    filledFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    filledFrame.Visible = false
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Parent = filledFrame
    
    cache.Box.Filled = {
        Gui = filledGui,
        Frame = filledFrame,
        Gradient = fillGradient
    }
    
    -- Text ScreenGuis
    local nameGui = Instance.new("ScreenGui")
    nameGui.Name = Player.Name .. "_Name"
    nameGui.Parent = CoreGui
    nameGui.ResetOnSpawn = false
    cache.Text.Name = CreateTextLabel("Name", nameGui)
    cache.Text.Name.TextColor3 = ESP.Settings.NameColor
    
    local toolGui = Instance.new("ScreenGui")
    toolGui.Name = Player.Name .. "_Tool"
    toolGui.Parent = CoreGui
    toolGui.ResetOnSpawn = false
    cache.Text.Tool = CreateTextLabel("Tool", toolGui)
    cache.Text.Tool.TextColor3 = ESP.Settings.ToolColor
    
    local distGui = Instance.new("ScreenGui")
    distGui.Name = Player.Name .. "_Distance"
    distGui.Parent = CoreGui
    distGui.ResetOnSpawn = false
    cache.Text.Distance = CreateTextLabel("Distance", distGui)
    cache.Text.Distance.TextColor3 = ESP.Settings.DistanceColor
    
    -- Health Bar
    local healthGui = Instance.new("ScreenGui")
    healthGui.Name = Player.Name .. "_HealthBar"
    healthGui.Parent = CoreGui
    healthGui.ResetOnSpawn = false
    
    local healthOutline = Instance.new("Frame")
    healthOutline.Name = "Outline"
    healthOutline.Parent = healthGui
    healthOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthOutline.BorderSizePixel = 0
    healthOutline.Visible = false
    
    local healthFill = Instance.new("Frame")
    healthFill.Name = "Fill"
    healthFill.Parent = healthOutline
    healthFill.BackgroundTransparency = 0
    healthFill.BorderSizePixel = 0
    
    local healthGradient = Instance.new("UIGradient")
    healthGradient.Parent = healthFill
    healthGradient.Rotation = 90
    
    cache.Bars.Health = {
        Gui = healthGui,
        Outline = healthOutline,
        Frame = healthFill,
        Gradient = healthGradient,
        LastHealth = 1
    }
    
    -- Armor Bar
    local armorGui = Instance.new("ScreenGui")
    armorGui.Name = Player.Name .. "_ArmorBar"
    armorGui.Parent = CoreGui
    armorGui.ResetOnSpawn = false
    
    local armorOutline = Instance.new("Frame")
    armorOutline.Name = "Outline"
    armorOutline.Parent = armorGui
    armorOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    armorOutline.BorderSizePixel = 0
    armorOutline.Visible = false
    
    local armorFill = Instance.new("Frame")
    armorFill.Name = "Fill"
    armorFill.Parent = armorOutline
    armorFill.BackgroundTransparency = 0
    armorFill.BorderSizePixel = 0
    
    local armorGradient = Instance.new("UIGradient")
    armorGradient.Parent = armorFill
    armorGradient.Rotation = 90
    
    cache.Bars.Armor = {
        Gui = armorGui,
        Outline = armorOutline,
        Frame = armorFill,
        Gradient = armorGradient,
        LastArmor = 1
    }
end

-- Clear ESP for Player
function ESP:ClearPlayer(Player)
    local cache = self.Cache[Player]
    if not cache then return end
    
    -- Hide Box
    if cache.Box then
        if cache.Box.Square then cache.Box.Square.Visible = false end
        if cache.Box.Outline then cache.Box.Outline.Visible = false end
        if cache.Box.Inline then cache.Box.Inline.Visible = false end
        if cache.Box.Filled and cache.Box.Filled.Frame then
            cache.Box.Filled.Frame.Visible = false
        end
    end
    
    -- Hide Text
    if cache.Text then
        if cache.Text.Name then cache.Text.Name.Visible = false end
        if cache.Text.Tool then cache.Text.Tool.Visible = false end
        if cache.Text.Distance then cache.Text.Distance.Visible = false end
    end
    
    -- Hide Bars
    if cache.Bars then
        if cache.Bars.Health and cache.Bars.Health.Outline then
            cache.Bars.Health.Outline.Visible = false
        end
        if cache.Bars.Armor and cache.Bars.Armor.Outline then
            cache.Bars.Armor.Outline.Visible = false
        end
    end
end

-- Remove ESP for Player
function ESP:RemovePlayer(Player)
    self:ClearPlayer(Player)
    local cache = self.Cache[Player]
    if cache then
        -- Remove Drawing objects
        if cache.Box then
            if cache.Box.Square then cache.Box.Square:Remove() end
            if cache.Box.Outline then cache.Box.Outline:Remove() end
            if cache.Box.Inline then cache.Box.Inline:Remove() end
            if cache.Box.Filled and cache.Box.Filled.Gui then
                cache.Box.Filled.Gui:Destroy()
            end
        end
        
        -- Remove ScreenGuis
        if cache.Text then
            if cache.Text.Name and cache.Text.Name.Parent then
                cache.Text.Name.Parent:Destroy()
            end
            if cache.Text.Tool and cache.Text.Tool.Parent then
                cache.Text.Tool.Parent:Destroy()
            end
            if cache.Text.Distance and cache.Text.Distance.Parent then
                cache.Text.Distance.Parent:Destroy()
            end
        end
        
        if cache.Bars then
            if cache.Bars.Health and cache.Bars.Health.Gui then
                cache.Bars.Health.Gui:Destroy()
            end
            if cache.Bars.Armor and cache.Bars.Armor.Gui then
                cache.Bars.Armor.Gui:Destroy()
            end
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
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = GetHumanoid(Character)
    
    if not HumanoidRootPart or not Humanoid then
        self:ClearPlayer(Player)
        return
    end
    
    local Position, OnScreen, Distance = WorldToScreen(HumanoidRootPart.Position)
    
    if not OnScreen or Distance > self.Settings.MaxDistance then
        self:ClearPlayer(Player)
        return
    end
    
    if not IsEnemy(Player) then
        self:ClearPlayer(Player)
        return
    end
    
    if not IsVisible(Character) then
        self:ClearPlayer(Player)
        return
    end
    
    -- Calculate box dimensions
    local rootPos = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
    local charSize = (Camera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 1, 0)).Y - Camera:WorldToViewportPoint(HumanoidRootPart.Position + Vector3.new(0, 3, 0)).Y) / 2
    local size = Vector2.new(math.floor(charSize * 1.5), math.floor(charSize * 3.2))
    local position = Vector2.new(math.floor(rootPos.X - charSize * 1.5 / 2), math.floor(rootPos.Y - charSize * 3 / 2))
    
    local posX = position.X
    local posY = position.Y - guiInset.Y
    
    -- Update Box
    if self.Settings.Box then
        if self.Settings.BoxType == "Full" then
            local square = cache.Box.Square
            local outline = cache.Box.Outline
            local inline = cache.Box.Inline
            
            -- Main square
            square.Visible = true
            square.Position = position
            square.Size = size
            square.Color = self.Settings.BoxColor
            square.Thickness = 2
            square.Filled = false
            square.ZIndex = 9
            
            -- Outline (black outer)
            outline.Visible = true
            outline.Position = position - Vector2.new(1, 1)
            outline.Size = size + Vector2.new(2, 2)
            outline.Color = Color3.fromRGB(0, 0, 0)
            outline.Thickness = 1
            outline.Filled = false
            outline.ZIndex = 8
            
            -- Inline (black inner)
            inline.Visible = true
            inline.Position = position + Vector2.new(1, 1)
            inline.Size = size - Vector2.new(2, 2)
            inline.Color = Color3.fromRGB(0, 0, 0)
            inline.Thickness = 1
            inline.Filled = false
            inline.ZIndex = 10
            
            -- Filled Box with Gradient
            if self.Settings.BoxFilled then
                local filled = cache.Box.Filled.Frame
                filled.Position = UDim2.new(0, posX, 0, posY)
                filled.Size = UDim2.new(0, size.X, 0, size.Y)
                filled.BackgroundTransparency = self.Settings.BoxFillTransparency
                filled.Visible = true
                filled.ZIndex = -9
                
                if self.Settings.BoxFillGradient then
                    local gradient = cache.Box.Filled.Gradient
                    gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, self.Settings.BoxFillColorStart),
                        ColorSequenceKeypoint.new(1, self.Settings.BoxFillColorEnd)
                    })
                else
                    cache.Box.Filled.Gradient.Color = ColorSequence.new(self.Settings.BoxFillColorStart)
                end
            else
                cache.Box.Filled.Frame.Visible = false
            end
        else
            -- Corner Box - hide full box elements
            cache.Box.Square.Visible = false
            cache.Box.Outline.Visible = false
            cache.Box.Inline.Visible = false
            cache.Box.Filled.Frame.Visible = false
            -- TODO: Implement corner box drawing
        end
    else
        cache.Box.Square.Visible = false
        cache.Box.Outline.Visible = false
        cache.Box.Inline.Visible = false
        cache.Box.Filled.Frame.Visible = false
    end
    
    -- Update Health Bar
    if self.Settings.HealthBar then
        local Health, MaxHealth = GetHealth(Character)
        local targetHealth = math.clamp(Health / MaxHealth, 0, 1)
        
        -- Lerp for smooth animation
        local lastHealth = cache.Bars.Health.LastHealth or targetHealth
        local lerpedHealth = self.Settings.HealthBarLerp 
            and (lastHealth + (targetHealth - lastHealth) * 0.1) 
            or targetHealth
        cache.Bars.Health.LastHealth = lerpedHealth
        
        local barWidth = 3
        local barHeight = size.Y
        local barX = posX - (barWidth + 4)
        
        local outline = cache.Bars.Health.Outline
        local fill = cache.Bars.Health.Frame
        local gradient = cache.Bars.Health.Gradient
        
        outline.Visible = true
        outline.Position = UDim2.new(0, barX - 1, 0, posY - 1)
        outline.Size = UDim2.new(0, barWidth + 2, 0, barHeight + 2)
        outline.BackgroundTransparency = 0.2
        
        fill.Visible = true
        fill.Position = UDim2.new(0, 1, 0, (1 - lerpedHealth) * barHeight + 1)
        fill.Size = UDim2.new(0, barWidth, 0, lerpedHealth * barHeight)
        
        -- 3-color gradient
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Settings.HealthColor1),
            ColorSequenceKeypoint.new(0.5, self.Settings.HealthColor2),
            ColorSequenceKeypoint.new(1, self.Settings.HealthColor3)
        })
    else
        cache.Bars.Health.Outline.Visible = false
    end
    
    -- Update Armor Bar
    if self.Settings.ArmorBar then
        local Armor, MaxArmor = GetArmor(Character)
        local targetArmor = math.clamp(Armor / MaxArmor, 0, 1)
        
        -- Lerp for smooth animation
        local lastArmor = cache.Bars.Armor.LastArmor or targetArmor
        local lerpedArmor = self.Settings.ArmorBarLerp 
            and (lastArmor + (targetArmor - lastArmor) * 0.1) 
            or targetArmor
        cache.Bars.Armor.LastArmor = lerpedArmor
        
        local barWidth = 3
        local barHeight = size.Y
        local barX = posX - (barWidth * 2 + 8)
        
        local outline = cache.Bars.Armor.Outline
        local fill = cache.Bars.Armor.Frame
        local gradient = cache.Bars.Armor.Gradient
        
        outline.Visible = true
        outline.Position = UDim2.new(0, barX - 1, 0, posY - 1)
        outline.Size = UDim2.new(0, barWidth + 2, 0, barHeight + 2)
        outline.BackgroundTransparency = 0.2
        
        fill.Visible = true
        fill.Position = UDim2.new(0, 1, 0, (1 - lerpedArmor) * barHeight + 1)
        fill.Size = UDim2.new(0, barWidth, 0, lerpedArmor * barHeight)
        
        -- 3-color gradient
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Settings.ArmorColor1),
            ColorSequenceKeypoint.new(0.5, self.Settings.ArmorColor2),
            ColorSequenceKeypoint.new(1, self.Settings.ArmorColor3)
        })
    else
        cache.Bars.Armor.Outline.Visible = false
    end
    
    -- Update Text
    if self.Settings.Name or self.Settings.Tool or self.Settings.Distance then
        local baseX = posX + (size.X / 2)
        local textOffset = 15
        
        -- Name
        if self.Settings.Name then
            cache.Text.Name.Visible = true
            cache.Text.Name.Text = Player.Name
            cache.Text.Name.TextColor3 = self.Settings.NameColor
            cache.Text.Name.Position = UDim2.new(0, baseX - 50, 0, posY - textOffset)
        else
            cache.Text.Name.Visible = false
        end
        
        -- Tool
        if self.Settings.Tool then
            local tool = Character:FindFirstChildOfClass("Tool")
            cache.Text.Tool.Visible = true
            cache.Text.Tool.Text = tool and tool.Name or "None"
            cache.Text.Tool.TextColor3 = self.Settings.ToolColor
            cache.Text.Tool.Position = UDim2.new(0, baseX - 50, 0, posY + size.Y + 15)
        else
            cache.Text.Tool.Visible = false
        end
        
        -- Distance
        if self.Settings.Distance then
            local meters = Distance * 0.28
            cache.Text.Distance.Visible = true
            cache.Text.Distance.Text = string.format("[%.0fm]", meters)
            cache.Text.Distance.TextColor3 = self.Settings.DistanceColor
            cache.Text.Distance.Position = UDim2.new(0, baseX - 50, 0, posY + size.Y + 2)
        else
            cache.Text.Distance.Visible = false
        end
    else
        cache.Text.Name.Visible = false
        cache.Text.Tool.Visible = false
        cache.Text.Distance.Visible = false
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

-- Player Added
local function PlayerAdded(Player)
    if Player ~= LocalPlayer then
        ESP:InitPlayer(Player)
    end
end

-- Player Removing
local function PlayerRemoving(Player)
    ESP:RemovePlayer(Player)
end

-- ESP Control Functions
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
    -- Connect to existing players
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            self:InitPlayer(Player)
        end
    end
    
    -- Connect events
    table.insert(self.Connections, Players.PlayerAdded:Connect(PlayerAdded))
    table.insert(self.Connections, Players.PlayerRemoving:Connect(PlayerRemoving))
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        self:Update()
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
