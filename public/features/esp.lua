local ESP = {}
ESP.__index = ESP

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Settings
ESP.Settings = {
    Enabled = false,
    Box = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxType = "Dynamic",
    Name = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthBar = true,
    HealthColor = Color3.fromRGB(0, 255, 0),
    Distance = false,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    Chams = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    Tool = false,
    ToolColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 1000,
    Font = "Default (Tahoma)",
    VisibleOnly = false,
    TeamCheck = true,
}

-- Cache of ESP objects per player
ESP.Objects = {}
ESP.Connection = nil

-- Drawing utility
local function NewSquare(properties)
    local square = Drawing.new("Square")
    square.Visible = false
    square.Thickness = properties.Thickness or 1
    square.Color = properties.Color or Color3.new(1, 1, 1)
    square.Transparency = properties.Transparency or 1
    square.Filled = properties.Filled or false
    return square
end

-- Create ESP drawings for a player
local function CreateESPObject()
    local obj = {}

    -- Box outline (black, thickness 3 to create a 1px border around the 1px main box)
    obj.BoxOutline = NewSquare({Thickness = 3, Color = Color3.new(0, 0, 0)})

    -- Box main (1px crisp line)
    obj.Box = NewSquare({Thickness = 1, Color = Color3.new(1, 1, 1)})

    return obj
end

-- Destroy ESP drawings for a player
local function DestroyESPObject(obj)
    if not obj then return end
    for _, drawing in pairs(obj) do
        pcall(function() drawing:Remove() end)
    end
end

-- Hide all drawings in an ESP object
local function HideESPObject(obj)
    if not obj then return end
    for _, drawing in pairs(obj) do
        pcall(function() drawing.Visible = false end)
    end
end

-- Get bounding box from character limbs (dynamic sizing)
-- Projects all part corners to screen space for accurate sizing
local function GetDynamicBoundingBox(character)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreen = false

    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local cf = part.CFrame
            local size = part.Size
            local sx, sy, sz = size.X / 2, size.Y / 2, size.Z / 2

            -- 8 corners of each limb/part bounding box
            local corners = {
                cf * Vector3.new(sx, sy, sz),
                cf * Vector3.new(sx, sy, -sz),
                cf * Vector3.new(sx, -sy, sz),
                cf * Vector3.new(sx, -sy, -sz),
                cf * Vector3.new(-sx, sy, sz),
                cf * Vector3.new(-sx, sy, -sz),
                cf * Vector3.new(-sx, -sy, sz),
                cf * Vector3.new(-sx, -sy, -sz),
            }

            for _, corner in ipairs(corners) do
                local screenPos, visible = Camera:WorldToViewportPoint(corner)
                if visible then
                    onScreen = true
                    if screenPos.X < minX then minX = screenPos.X end
                    if screenPos.Y < minY then minY = screenPos.Y end
                    if screenPos.X > maxX then maxX = screenPos.X end
                    if screenPos.Y > maxY then maxY = screenPos.Y end
                end
            end
        end
    end

    if not onScreen or minX == math.huge then
        return nil
    end

    return {
        X = math.floor(minX),
        Y = math.floor(minY),
        Width = math.floor(maxX - minX),
        Height = math.floor(maxY - minY)
    }
end

-- Get static bounding box (proportional from root, head-to-foot ratio)
local function GetStaticBoundingBox(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not hrp or not head then return nil end

    local topPos = head.Position + Vector3.new(0, head.Size.Y / 2 + 0.5, 0)
    local bottomPos = hrp.Position - Vector3.new(0, 3, 0)

    local screenTop, visibleTop = Camera:WorldToViewportPoint(topPos)
    local screenBottom, visibleBottom = Camera:WorldToViewportPoint(bottomPos)

    if not visibleTop or not visibleBottom then return nil end

    local height = math.abs(screenBottom.Y - screenTop.Y)
    local width = height * 0.55

    local centerX = (screenTop.X + screenBottom.X) / 2

    return {
        X = math.floor(centerX - width / 2),
        Y = math.floor(screenTop.Y),
        Width = math.floor(width),
        Height = math.floor(height)
    }
end

-- Get bounding box based on current type setting
local function GetBoundingBox(character)
    if ESP.Settings.BoxType == "Dynamic" then
        return GetDynamicBoundingBox(character)
    else
        return GetStaticBoundingBox(character)
    end
end

-- Team check
local function IsEnemy(player)
    if not ESP.Settings.TeamCheck then return true end
    if player.Team == nil or LocalPlayer.Team == nil then return true end
    return player.Team ~= LocalPlayer.Team
end

-- Main update loop
local function UpdateESP()
    Camera = workspace.CurrentCamera

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        -- Create object cache if missing
        if not ESP.Objects[player] then
            ESP.Objects[player] = CreateESPObject()
        end

        local obj = ESP.Objects[player]
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        -- Hide if conditions not met
        if not ESP.Settings.Enabled or not character or not humanoid or not hrp or humanoid.Health <= 0 then
            HideESPObject(obj)
            continue
        end

        -- Distance check
        local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
        if distance > ESP.Settings.MaxDistance then
            HideESPObject(obj)
            continue
        end

        -- Team check
        if not IsEnemy(player) then
            HideESPObject(obj)
            continue
        end

        -- Compute bounding box
        local bounds = GetBoundingBox(character)
        if not bounds or bounds.Width < 2 or bounds.Height < 2 then
            HideESPObject(obj)
            continue
        end

        -- ═══════════════════════ BOX ESP ═══════════════════════
        if ESP.Settings.Box then
            local pos = Vector2.new(bounds.X, bounds.Y)
            local size = Vector2.new(bounds.Width, bounds.Height)

            -- Outline (black, thickness 3 → creates 1px border around the 1px inner box)
            obj.BoxOutline.Position = pos
            obj.BoxOutline.Size = size
            obj.BoxOutline.Color = Color3.new(0, 0, 0)
            obj.BoxOutline.Transparency = 0.65
            obj.BoxOutline.Thickness = 3
            obj.BoxOutline.Visible = true

            -- Main box
            obj.Box.Position = pos
            obj.Box.Size = size
            obj.Box.Color = ESP.Settings.BoxColor
            obj.Box.Transparency = 1
            obj.Box.Thickness = 1
            obj.Box.Visible = true
        else
            obj.BoxOutline.Visible = false
            obj.Box.Visible = false
        end
    end
end

-- ════════════════════════ PUBLIC API ════════════════════════

function ESP:Initialize()
    for _, obj in pairs(self.Objects) do
        DestroyESPObject(obj)
    end
    self.Objects = {}

    Players.PlayerRemoving:Connect(function(player)
        if self.Objects[player] then
            DestroyESPObject(self.Objects[player])
            self.Objects[player] = nil
        end
    end)
end

function ESP:Toggle(value)
    self.Settings.Enabled = value
    if not value then
        for _, obj in pairs(self.Objects) do
            HideESPObject(obj)
        end
    end
end

function ESP:SetSetting(key, value)
    if self.Settings[key] ~= nil then
        self.Settings[key] = value
    end
end

function ESP:Unload()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end

    for _, obj in pairs(self.Objects) do
        DestroyESPObject(obj)
    end
    self.Objects = {}
end

-- Start render loop
ESP.Connection = RunService.RenderStepped:Connect(UpdateESP)

return ESP
