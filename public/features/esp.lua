local ESP = {
    Enabled = false,
    Players = {},
    Connections = {},
    Settings = {
        Box = true,
        BoxType = "Corner", -- "Full" or "Corner"
        BoxFilled = false,
        BoxFillTransparency = 0.3,
        BoxGradient = false,
        HealthBar = true,
        ArmorBar = false,
        Name = true,
        Distance = false,
        Tool = false,
        MaxDistance = 2000,
        TeamCheck = true,
        VisibleOnly = false,
        -- Colors
        BoxColor = Color3.fromRGB(255, 255, 255),
        BoxFillColor = Color3.fromRGB(0, 255, 0),
        NameColor = Color3.fromRGB(255, 255, 255),
        DistanceColor = Color3.fromRGB(255, 255, 255),
        ToolColor = Color3.fromRGB(255, 255, 255),
        -- Health bar colors (3-color gradient: Red -> Yellow -> Green)
        HealthColor1 = Color3.fromRGB(255, 0, 0),     -- Low health (red)
        HealthColor2 = Color3.fromRGB(255, 255, 0),   -- Mid health (yellow)
        HealthColor3 = Color3.fromRGB(0, 255, 0),    -- High health (green)
        -- Armor bar colors (Blue gradient)
        ArmorColor1 = Color3.fromRGB(0, 0, 255),      -- Full armor
        ArmorColor2 = Color3.fromRGB(135, 206, 235),  -- Mid armor
        ArmorColor3 = Color3.fromRGB(1, 0, 0),        -- Low armor
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

local function GetArmor(Character)
    -- Check for armor values in common locations
    local Humanoid = GetHumanoid(Character)
    if Humanoid then
        -- Try to find armor attribute or value
        if Humanoid:FindFirstChild("Armor") then
            return Humanoid.Armor.Value, 100
        end
        if Humanoid:GetAttribute("Armor") then
            return Humanoid:GetAttribute("Armor"), 100
        end
    end
    -- Check for body armor in accessories
    for _, child in ipairs(Character:GetChildren()) do
        if child.Name:lower():find("armor") or child.Name:lower():find("vest") then
            return 100, 100
        end
    end
    return 0, 100
end

local function GetToolName(Character)
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Tool") then
            return child.Name
        end
    end
    -- Check backpack
    local Player = Players:GetPlayerFromCharacter(Character)
    if Player and Player:FindFirstChild("Backpack") then
        for _, tool in ipairs(Player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                return tool.Name
            end
        end
    end
    return "None"
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

-- Create corner box lines with thickness/outlines
local function CreateCornerBox()
    local Lines = {}
    for i = 1, 8 do
        Lines[i] = CreateDrawing("Line", {
            Visible = false,
            Thickness = 2,
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
        -- Full box with outline
        Box = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Thickness = 2,
            Color = ESP.Settings.BoxColor,
            Transparency = 1
        }),
        BoxFilled = CreateDrawing("Square", {
            Visible = false,
            Filled = true,
            Thickness = 0,
            Color = ESP.Settings.BoxFillColor,
            Transparency = ESP.Settings.BoxFillTransparency
        }),
        -- Health bar (thicker with outline)
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
        -- Armor bar (below health bar)
        ArmorBar = CreateDrawing("Square", {
            Visible = false,
            Filled = true,
            Thickness = 0,
            Transparency = 1
        }),
        ArmorBarOutline = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Thickness = 1,
            Color = Color3.fromRGB(0, 0, 0),
            Transparency = 1
        }),
        -- Name text with outline
        Name = CreateDrawing("Text", {
            Visible = false,
            Text = Player.Name,
            Color = ESP.Settings.NameColor,
            Size = 13,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = 2
        }),
        -- Distance text
        Distance = CreateDrawing("Text", {
            Visible = false,
            Text = "0m",
            Color = ESP.Settings.DistanceColor,
            Size = 12,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = 2
        }),
        -- Tool text
        Tool = CreateDrawing("Text", {
            Visible = false,
            Text = "None",
            Color = ESP.Settings.ToolColor,
            Size = 12,
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

-- Health bar 3-color gradient
local function GetHealthColor(HealthPercent)
    if HealthPercent > 0.5 then
        -- Yellow to Green
        local t = (HealthPercent - 0.5) * 2
        return ESP.Settings.HealthColor2:Lerp(ESP.Settings.HealthColor3, t)
    else
        -- Red to Yellow
        local t = HealthPercent * 2
        return ESP.Settings.HealthColor1:Lerp(ESP.Settings.HealthColor2, t)
    end
end

-- Armor bar 3-color gradient
local function GetArmorColor(ArmorPercent)
    if ArmorPercent > 0.5 then
        -- Light blue to Blue
        local t = (ArmorPercent - 0.5) * 2
        return ESP.Settings.ArmorColor2:Lerp(ESP.Settings.ArmorColor1, t)
    else
        -- Dark red to Light blue
        local t = ArmorPercent * 2
        return ESP.Settings.ArmorColor3:Lerp(ESP.Settings.ArmorColor2, t)
    end
end

-- Update corner box lines
local function UpdateCornerBox(Lines, Position, Width, Height, Color)
    local CornerSize = math.min(Width, Height) * 0.3 -- 30% of box size
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

-- Helper function to hide all drawings for a player
local function HideAllDrawings(Data)
    if not Data then return end
    
    -- Hide corner lines
    if Data.CornerLines then
        for _, Line in ipairs(Data.CornerLines) do
            if typeof(Line) == "table" and Line.Visible ~= nil then
                Line.Visible = false
            end
        end
    end
    
    -- Hide other drawings
    for Key, Drawing in pairs(Data) do
        if Key ~= "CornerLines" and Key ~= "Player" and typeof(Drawing) == "table" and Drawing.Visible ~= nil then
            Drawing.Visible = false
        end
    end
end

-- Main ESP update function
local function UpdateESP()
    -- Hide everything if ESP is disabled
    if not ESP.Enabled then
        for _, Data in pairs(ESP.Players) do
            HideAllDrawings(Data)
        end
        return
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character = GetCharacter(Player)
        
        -- Hide if no character
        if not Character then
            if ESP.Players[Player] then
                HideAllDrawings(ESP.Players[Player])
            end
            continue
        end

        -- Create ESP object if needed
        if not ESP.Players[Player] then
            ESP.Players[Player] = CreateESPObject(Player)
        end

        local Data = ESP.Players[Player]
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        local Head = Character:FindFirstChild("Head")

        -- Hide if missing parts
        if not HumanoidRootPart or not Head then
            HideAllDrawings(Data)
            continue
        end

        local Position, OnScreen, Distance = WorldToScreen(HumanoidRootPart.Position)
        
        -- Hide if off screen or too far
        if not OnScreen or Distance > ESP.Settings.MaxDistance then
            HideAllDrawings(Data)
            continue
        end

        -- Hide if not enemy
        if not IsEnemy(Player) then
            HideAllDrawings(Data)
            continue
        end

        -- Hide if not visible (if visible only is enabled)
        if not IsVisible(Character) then
            HideAllDrawings(Data)
            continue
        end

        -- Calculate box dimensions
        local TopPos = WorldToScreen(Head.Position + Vector3.new(0, 0.5, 0))
        local BottomPos = WorldToScreen(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
        
        local Height = math.abs(BottomPos.Y - TopPos.Y)
        local Width = Height * 0.5 -- 50% of height for better proportions
        
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
                Data.Box.Thickness = 2
                Data.Box.Visible = true

                if ESP.Settings.BoxFilled then
                    Data.BoxFilled.Size = Vector2.new(Width, Height)
                    Data.BoxFilled.Position = Vector2.new(BoxX, BoxY)
                    Data.BoxFilled.Color = ESP.Settings.BoxFillColor
                    Data.BoxFilled.Transparency = ESP.Settings.BoxFillTransparency
                    Data.BoxFilled.Visible = true
                else
                    Data.BoxFilled.Visible = false
                end
            end
        else
            -- Hide all box types
            for _, Line in ipairs(Data.CornerLines) do
                Line.Visible = false
            end
            Data.Box.Visible = false
            Data.BoxFilled.Visible = false
        end

        -- Update Health Bar
        if ESP.Settings.HealthBar then
            local Health, MaxHealth = GetHealth(Character)
            local HealthPercent = math.clamp(Health / MaxHealth, 0, 1)
            
            local BarWidth = 4
            local BarHeight = Height * 0.4 -- Half height for health
            local BarX = BoxX - BarWidth - 4
            local BarY = BoxY + (Height - BarHeight * 2) / 2 -- Center both bars
            
            -- Outline
            Data.HealthBarOutline.Size = Vector2.new(BarWidth + 2, BarHeight + 2)
            Data.HealthBarOutline.Position = Vector2.new(BarX - 1, BarY - 1)
            Data.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
            Data.HealthBarOutline.Visible = true
            
            -- Health bar with gradient color
            Data.HealthBar.Size = Vector2.new(BarWidth, BarHeight * HealthPercent)
            Data.HealthBar.Position = Vector2.new(BarX, BarY + BarHeight * (1 - HealthPercent))
            Data.HealthBar.Color = GetHealthColor(HealthPercent)
            Data.HealthBar.Visible = true
            
            -- Update Armor Bar (below health bar)
            if ESP.Settings.ArmorBar then
                local Armor, MaxArmor = GetArmor(Character)
                local ArmorPercent = math.clamp(Armor / MaxArmor, 0, 1)
                
                local ArmorY = BarY + BarHeight + 2 -- Small gap between bars
                
                -- Outline
                Data.ArmorBarOutline.Size = Vector2.new(BarWidth + 2, BarHeight + 2)
                Data.ArmorBarOutline.Position = Vector2.new(BarX - 1, ArmorY - 1)
                Data.ArmorBarOutline.Color = Color3.fromRGB(0, 0, 0)
                Data.ArmorBarOutline.Visible = true
                
                -- Armor bar with gradient
                Data.ArmorBar.Size = Vector2.new(BarWidth, BarHeight * ArmorPercent)
                Data.ArmorBar.Position = Vector2.new(BarX, ArmorY + BarHeight * (1 - ArmorPercent))
                Data.ArmorBar.Color = GetArmorColor(ArmorPercent)
                Data.ArmorBar.Visible = true
            else
                Data.ArmorBar.Visible = false
                Data.ArmorBarOutline.Visible = false
            end
        else
            Data.HealthBar.Visible = false
            Data.HealthBarOutline.Visible = false
            Data.ArmorBar.Visible = false
            Data.ArmorBarOutline.Visible = false
        end

        -- Update Name (above box, centered)
        if ESP.Settings.Name then
            Data.Name.Position = Vector2.new(Position.X, BoxY - 18)
            Data.Name.Color = ESP.Settings.NameColor
            Data.Name.Outline = true
            Data.Name.Visible = true
        else
            Data.Name.Visible = false
        end

        -- Update Distance (below name)
        if ESP.Settings.Distance then
            Data.Distance.Text = math.floor(Distance) .. "m"
            Data.Distance.Position = Vector2.new(Position.X, BoxY - 30)
            Data.Distance.Color = ESP.Settings.DistanceColor
            Data.Distance.Visible = true
        else
            Data.Distance.Visible = false
        end

        -- Update Tool (below box)
        if ESP.Settings.Tool then
            local ToolName = GetToolName(Character)
            Data.Tool.Text = ToolName
            Data.Tool.Position = Vector2.new(Position.X, BoxY + Height + 5)
            Data.Tool.Color = ESP.Settings.ToolColor
            Data.Tool.Visible = true
        else
            Data.Tool.Visible = false
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
        for _, Data in pairs(self.Players) do
            HideAllDrawings(Data)
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
