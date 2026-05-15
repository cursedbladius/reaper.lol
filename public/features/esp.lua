local ESP = {
    Enabled = false,
    Players = {},
    Connections = {},
    Settings = {
        Box = true,
        BoxType = "Corner", -- "Full" or "Corner"
        BoxFilled = false,
        BoxFillTransparency = 0.3,
        HealthBar = true,
        Name = true,
        MaxDistance = 2000,
        TeamCheck = true,
        VisibleOnly = false,
        -- Colors
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        -- Health bar colors (gradient)
        HealthColorLow = Color3.fromRGB(255, 0, 0),    -- Red (low health)
        HealthColorMid = Color3.fromRGB(255, 255, 0), -- Yellow (mid health)
        HealthColorHigh = Color3.fromRGB(0, 255, 0),  -- Green (high health)
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

-- Create corner box lines (4 lines for corners)
local function CreateCornerBox()
    local Lines = {}
    for i = 1, 8 do
        Lines[i] = CreateDrawing("Line", {
            Visible = false,
            Thickness = 1,
            Color = ESP.Settings.BoxColor,
            Transparency = 1
        })
    end
    return Lines
end

local function CreateESPObject(Player)
    return {
        Player = Player,
        -- Corner box lines (8 lines for 4 corners)
        CornerLines = CreateCornerBox(),
        -- Full box
        Box = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Thickness = 1,
            Color = ESP.Settings.BoxColor,
            Transparency = 1
        }),
        BoxFilled = CreateDrawing("Square", {
            Visible = false,
            Filled = true,
            Thickness = 0,
            Color = Color3.fromRGB(0, 0, 0),
            Transparency = ESP.Settings.BoxFillTransparency
        }),
        -- Health bar (thin, on left side)
        HealthBar = CreateDrawing("Square", {
            Visible = false,
            Filled = true,
            Thickness = 0,
            Transparency = 1
        }),
        HealthBarOutline = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Thickness = 1,
            Color = Color3.fromRGB(0, 0, 0),
            Transparency = 1
        }),
        -- Name text
        Name = CreateDrawing("Text", {
            Visible = false,
            Text = Player.Name,
            Color = ESP.Settings.NameColor,
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
        local Data = ESP.Players[Player]
        -- Remove corner lines
        if Data.CornerLines then
            for _, Line in ipairs(Data.CornerLines) do
                if Line.Remove then Line:Remove() end
            end
        end
        -- Remove other drawings
        for Key, Drawing in pairs(Data) do
            if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Remove then
                Drawing:Remove()
            end
        end
        ESP.Players[Player] = nil
    end
end

-- Health bar gradient color
local function GetHealthColor(HealthPercent)
    if HealthPercent > 0.5 then
        -- Yellow to Green
        local t = (HealthPercent - 0.5) * 2
        return ESP.Settings.HealthColorMid:Lerp(ESP.Settings.HealthColorHigh, t)
    else
        -- Red to Yellow
        local t = HealthPercent * 2
        return ESP.Settings.HealthColorLow:Lerp(ESP.Settings.HealthColorMid, t)
    end
end

-- Update corner box lines
local function UpdateCornerBox(Lines, Position, Width, Height, Color)
    local CornerSize = math.min(Width, Height) * 0.25 -- Corner length is 25% of box size
    local X, Y = Position.X, Position.Y
    local W, H = Width, Height
    
    -- Top left corner
    Lines[1].From = Vector2.new(X, Y)
    Lines[1].To = Vector2.new(X + CornerSize, Y)
    Lines[2].From = Vector2.new(X, Y)
    Lines[2].To = Vector2.new(X, Y + CornerSize)
    
    -- Top right corner
    Lines[3].From = Vector2.new(X + W, Y)
    Lines[3].To = Vector2.new(X + W - CornerSize, Y)
    Lines[4].From = Vector2.new(X + W, Y)
    Lines[4].To = Vector2.new(X + W, Y + CornerSize)
    
    -- Bottom left corner
    Lines[5].From = Vector2.new(X, Y + H)
    Lines[5].To = Vector2.new(X + CornerSize, Y + H)
    Lines[6].From = Vector2.new(X, Y + H)
    Lines[6].To = Vector2.new(X, Y + H - CornerSize)
    
    -- Bottom right corner
    Lines[7].From = Vector2.new(X + W, Y + H)
    Lines[7].To = Vector2.new(X + W - CornerSize, Y + H)
    Lines[8].From = Vector2.new(X + W, Y + H)
    Lines[8].To = Vector2.new(X + W, Y + H - CornerSize)
    
    -- Update color and visibility
    for i = 1, 8 do
        Lines[i].Color = Color
        Lines[i].Visible = true
    end
end

-- Main ESP update function
local function UpdateESP()
    if not ESP.Enabled then
        for _, Data in pairs(ESP.Players) do
            -- Hide corner lines
            if Data.CornerLines then
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
            end
            -- Hide other drawings
            for Key, Drawing in pairs(Data) do
                if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
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
                local Data = ESP.Players[Player]
                if Data.CornerLines then
                    for _, Line in ipairs(Data.CornerLines) do
                        Line.Visible = false
                    end
                end
                for Key, Drawing in pairs(Data) do
                    if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
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
            if Data.CornerLines then
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
            end
            for Key, Drawing in pairs(Data) do
                if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        local Position, OnScreen, Distance = WorldToScreen(HumanoidRootPart.Position)
        
        if not OnScreen or Distance > ESP.Settings.MaxDistance then
            if Data.CornerLines then
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
            end
            for Key, Drawing in pairs(Data) do
                if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        if not IsEnemy(Player) then
            if Data.CornerLines then
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
            end
            for Key, Drawing in pairs(Data) do
                if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        if not IsVisible(Character) then
            if Data.CornerLines then
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
            end
            for Key, Drawing in pairs(Data) do
                if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
                    Drawing.Visible = false
                end
            end
            continue
        end

        -- Calculate box dimensions with proper scaling
        local TopPos = WorldToScreen(Head.Position + Vector3.new(0, 0.5, 0))
        local BottomPos = WorldToScreen(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
        
        local Height = math.abs(BottomPos.Y - TopPos.Y)
        local Width = Height * 0.45 -- Slightly narrower for better proportions
        
        local BoxX = Position.X - Width / 2
        local BoxY = TopPos.Y

        -- Update Box
        if ESP.Settings.Box then
            if ESP.Settings.BoxType == "Corner" then
                -- Hide full box
                Data.Box.Visible = false
                Data.BoxFilled.Visible = false
                -- Show corner lines
                UpdateCornerBox(Data.CornerLines, Vector2.new(BoxX, BoxY), Width, Height, ESP.Settings.BoxColor)
            else
                -- Hide corner lines
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
                -- Show full box
                Data.Box.Size = Vector2.new(Width, Height)
                Data.Box.Position = Vector2.new(BoxX, BoxY)
                Data.Box.Color = ESP.Settings.BoxColor
                Data.Box.Visible = true

                if ESP.Settings.BoxFilled then
                    Data.BoxFilled.Size = Vector2.new(Width, Height)
                    Data.BoxFilled.Position = Vector2.new(BoxX, BoxY)
                    Data.BoxFilled.Visible = true
                else
                    Data.BoxFilled.Visible = false
                end
            end
        else
            -- Hide all box types
            if Data.CornerLines then
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
            end
            Data.Box.Visible = false
            Data.BoxFilled.Visible = false
        end

        -- Update Health Bar (thin, on left side with no outline)
        if ESP.Settings.HealthBar then
            local Health, MaxHealth = GetHealth(Character)
            local HealthPercent = math.clamp(Health / MaxHealth, 0, 1)
            
            local BarWidth = 2 -- Thin bar
            local BarHeight = Height * 0.9 -- Slightly shorter than box
            local BarX = BoxX - BarWidth - 4 -- Small gap from box
            local BarY = BoxY + (Height - BarHeight) / 2 -- Centered vertically
            
            -- No outline for cleaner look
            Data.HealthBarOutline.Visible = false
            
            -- Health bar with gradient color
            Data.HealthBar.Size = Vector2.new(BarWidth, BarHeight * HealthPercent)
            Data.HealthBar.Position = Vector2.new(BarX, BarY + BarHeight * (1 - HealthPercent))
            Data.HealthBar.Color = GetHealthColor(HealthPercent)
            Data.HealthBar.Visible = true
        else
            Data.HealthBar.Visible = false
            Data.HealthBarOutline.Visible = false
        end

        -- Update Name (above box, centered)
        if ESP.Settings.Name then
            Data.Name.Position = Vector2.new(Position.X, BoxY - 18)
            Data.Name.Color = ESP.Settings.NameColor
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
            local Data = self.Players[Player]
            if Data.CornerLines then
                for _, Line in ipairs(Data.CornerLines) do
                    Line.Visible = false
                end
            end
            for Key, Drawing in pairs(Data) do
                if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
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
