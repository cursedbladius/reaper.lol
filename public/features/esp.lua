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
    Box = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxType = "Dynamic",
    Name = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameType = "DisplayName",
    HealthBar = false,
    HealthColor = Color3.fromRGB(0, 255, 0),
    HealthGradient = false,
    HealthGradientColor = Color3.fromRGB(255, 0, 0),
    Distance = false,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    Chams = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    Tool = false,
    ToolColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 1000,
    Font = "Tahoma",
    VisibleOnly = false,
    TeamCheck = true,
}

-- Cache of ESP objects per player
ESP.Objects = {}
ESP.Connection = nil

-- Font mapping
local FontMap = {
    ["Tahoma"] = 2,
    ["Monospace"] = 3,
}

local function GetFont(name)
    return FontMap[name] or 2
end

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

local function NewText(properties)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = properties.Color or Color3.new(1, 1, 1)
    text.Size = properties.Size or 13
    text.Center = properties.Center or false
    text.Outline = properties.Outline or false
    text.OutlineColor = properties.OutlineColor or Color3.new(0, 0, 0)
    text.Font = properties.Font or 2
    text.Transparency = properties.Transparency or 1
    return text
end

-- Create ESP drawings for a player
local function CreateESPObject()
    local obj = {}

    -- Box outline (black, thickness 3 to create a 1px border around the 1px main box)
    obj.BoxOutline = NewSquare({Thickness = 3, Color = Color3.new(0, 0, 0)})

    -- Box main (1px crisp line)
    obj.Box = NewSquare({Thickness = 1, Color = Color3.new(1, 1, 1)})

    -- Name text (centered above box, with outline for readability)
    obj.Name = NewText({Size = 13, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0)})

    -- Health bar (left side of box)
    obj.HealthBarOutline = NewSquare({Thickness = 1, Color = Color3.new(0, 0, 0), Filled = true})
    obj.HealthBarBackground = NewSquare({Thickness = 1, Color = Color3.new(0, 0, 0), Filled = true})
    obj.HealthBar = NewSquare({Thickness = 1, Color = Color3.new(0, 1, 0), Filled = true})

    -- Gradient segments (filled squares that tile the bar height)
    local GRADIENT_SEGMENTS = 24
    obj.GradientLines = {}
    for i = 1, GRADIENT_SEGMENTS do
        obj.GradientLines[i] = Drawing.new("Square")
        obj.GradientLines[i].Visible = false
        obj.GradientLines[i].Filled = true
        obj.GradientLines[i].Thickness = 0
        obj.GradientLines[i].Transparency = 1
    end

    -- Distance text (centered below box)
    obj.Distance = NewText({Size = 13, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0)})

    -- Skeleton lines (outline + colored for each bone)
    local MAX_BONES = 14
    obj.SkeletonOutlines = {}
    obj.SkeletonLines = {}
    for i = 1, MAX_BONES do
        local outline = Drawing.new("Line")
        outline.Visible = false
        outline.Thickness = 3
        outline.Color = Color3.new(0, 0, 0)
        outline.Transparency = 0.65
        obj.SkeletonOutlines[i] = outline

        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        line.Color = Color3.new(1, 1, 1)
        line.Transparency = 1
        obj.SkeletonLines[i] = line
    end

    -- Smoothed health value for animation
    obj.SmoothedHealth = 1

    return obj
end

-- Destroy ESP drawings for a player
local function DestroyESPObject(obj)
    if not obj then return end
    if obj.Highlight then
        pcall(function() obj.Highlight:Destroy() end)
        obj.Highlight = nil
    end
    for key, val in pairs(obj) do
        if type(val) == "table" then
            for _, drawing in ipairs(val) do
                pcall(function() drawing:Remove() end)
            end
        elseif typeof(val) ~= "number" then
            pcall(function() val:Remove() end)
        end
    end
end

-- Hide all drawings in an ESP object
local function HideESPObject(obj)
    if not obj then return end
    if obj.Highlight then
        pcall(function() obj.Highlight.Enabled = false end)
    end
    for key, val in pairs(obj) do
        if type(val) == "table" then
            for _, drawing in ipairs(val) do
                pcall(function() drawing.Visible = false end)
            end
        elseif typeof(val) ~= "number" then
            pcall(function() val.Visible = false end)
        end
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

-- Occlusion check via raycast
local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsVisible(character, hrp)
    local origin = Camera.CFrame.Position
    local target = hrp.Position
    local direction = (target - origin)

    -- Exclude local player's character and the target character from the ray
    local filterInstances = {character}
    local localChar = LocalPlayer.Character
    if localChar then
        table.insert(filterInstances, localChar)
    end

    RaycastParams.FilterDescendantsInstances = filterInstances

    local result = workspace:Raycast(origin, direction, RaycastParams)
    return result == nil
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

        -- Occlusion check (VisibleOnly = show only non-occluded players)
        if ESP.Settings.VisibleOnly and not IsVisible(character, hrp) then
            HideESPObject(obj)
            continue
        end

        -- Compute bounding box
        local bounds = GetBoundingBox(character)
        if not bounds or bounds.Width < 2 or bounds.Height < 2 then
            HideESPObject(obj)
            continue
        end

        -- ═══════════════════════ NAME ESP ═══════════════════════
        if ESP.Settings.Name then
            obj.Name.Text = ESP.Settings.NameType == "Username" and player.Name or player.DisplayName
            obj.Name.Position = Vector2.new(bounds.X + bounds.Width / 2, bounds.Y - 16)
            obj.Name.Color = ESP.Settings.NameColor
            obj.Name.Font = GetFont(ESP.Settings.Font)
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
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

        -- ═══════════════════════ HEALTH BAR ═══════════════════════
        if ESP.Settings.HealthBar then
            local healthFraction = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)

            -- Smooth lerp toward actual health (0.1 = speed, lower = smoother)
            obj.SmoothedHealth = obj.SmoothedHealth + (healthFraction - obj.SmoothedHealth) * 0.1
            if math.abs(obj.SmoothedHealth - healthFraction) < 0.001 then
                obj.SmoothedHealth = healthFraction
            end
            local smoothed = obj.SmoothedHealth

            local barWidth = 2
            local padding = 4
            local barX = bounds.X - padding - barWidth
            local barY = bounds.Y
            local barHeight = bounds.Height
            local fillHeight = math.floor(barHeight * smoothed)

            -- Outline (1px black border around the full bar)
            obj.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
            obj.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
            obj.HealthBarOutline.Color = Color3.new(0, 0, 0)
            obj.HealthBarOutline.Transparency = 0.65
            obj.HealthBarOutline.Visible = true

            -- Dark background
            obj.HealthBarBackground.Position = Vector2.new(barX, barY)
            obj.HealthBarBackground.Size = Vector2.new(barWidth, barHeight)
            obj.HealthBarBackground.Color = Color3.fromRGB(20, 20, 20)
            obj.HealthBarBackground.Transparency = 1
            obj.HealthBarBackground.Visible = true

            -- Colored fill (grows from bottom)
            if ESP.Settings.HealthGradient and fillHeight > 0 then
                -- Hide solid bar, use gradient segments
                obj.HealthBar.Visible = false

                local topColor = ESP.Settings.HealthColor
                local bottomColor = ESP.Settings.HealthGradientColor
                local segments = obj.GradientLines
                local segCount = #segments
                local fillTop = barY + (barHeight - fillHeight)

                local segHeight = fillHeight / segCount
                for i = 1, segCount do
                    local t = (i - 1) / (segCount - 1)
                    local segY = fillTop + (i - 1) * segHeight
                    local segH = math.ceil(segHeight)

                    -- Blend: top of fill = topColor, bottom of fill = bottomColor
                    local r = math.floor(topColor.R * 255 * (1 - t) + bottomColor.R * 255 * t)
                    local g = math.floor(topColor.G * 255 * (1 - t) + bottomColor.G * 255 * t)
                    local b = math.floor(topColor.B * 255 * (1 - t) + bottomColor.B * 255 * t)

                    segments[i].Position = Vector2.new(barX, math.floor(segY))
                    segments[i].Size = Vector2.new(barWidth, segH)
                    segments[i].Color = Color3.fromRGB(r, g, b)
                    segments[i].Visible = true
                end
            else
                -- Solid color mode
                for _, line in ipairs(obj.GradientLines) do
                    line.Visible = false
                end

                obj.HealthBar.Position = Vector2.new(barX, barY + (barHeight - fillHeight))
                obj.HealthBar.Size = Vector2.new(barWidth, fillHeight)
                obj.HealthBar.Color = ESP.Settings.HealthColor
                obj.HealthBar.Transparency = 1
                obj.HealthBar.Visible = fillHeight > 0
            end
        else
            obj.HealthBarOutline.Visible = false
            obj.HealthBarBackground.Visible = false
            obj.HealthBar.Visible = false
            for _, line in ipairs(obj.GradientLines) do
                line.Visible = false
            end
        end

        -- ═══════════════════════ SKELETON ESP ═══════════════════════
        if ESP.Settings.Skeleton then
            local bones = {}

            -- Detect R15 vs R6
            local isR15 = character:FindFirstChild("UpperTorso") ~= nil

            if isR15 then
                bones = {
                    {"Head", "UpperTorso"},
                    {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"},
                    {"LeftUpperArm", "LeftLowerArm"},
                    {"LeftLowerArm", "LeftHand"},
                    {"UpperTorso", "RightUpperArm"},
                    {"RightUpperArm", "RightLowerArm"},
                    {"RightLowerArm", "RightHand"},
                    {"LowerTorso", "LeftUpperLeg"},
                    {"LeftUpperLeg", "LeftLowerLeg"},
                    {"LeftLowerLeg", "LeftFoot"},
                    {"LowerTorso", "RightUpperLeg"},
                    {"RightUpperLeg", "RightLowerLeg"},
                    {"RightLowerLeg", "RightFoot"},
                }
            else
                -- R6: compute joint positions manually for a proper stick figure
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("Torso")
                local lArm = character:FindFirstChild("Left Arm")
                local rArm = character:FindFirstChild("Right Arm")
                local lLeg = character:FindFirstChild("Left Leg")
                local rLeg = character:FindFirstChild("Right Leg")

                if head and torso then
                    local torsoTop = (torso.CFrame * CFrame.new(0, 1, 0)).Position
                    local torsoBot = (torso.CFrame * CFrame.new(0, -1, 0)).Position

                    -- Head → Torso top (neck)
                    bones[#bones + 1] = {head.Position, torsoTop}
                    -- Torso spine
                    bones[#bones + 1] = {torsoTop, torsoBot}

                    if lArm and rArm then
                        local lArmTop = (lArm.CFrame * CFrame.new(0, 0.5, 0)).Position
                        local rArmTop = (rArm.CFrame * CFrame.new(0, 0.5, 0)).Position
                        local lArmBot = (lArm.CFrame * CFrame.new(0, -1, 0)).Position
                        local rArmBot = (rArm.CFrame * CFrame.new(0, -1, 0)).Position

                        -- Shoulder line
                        bones[#bones + 1] = {lArmTop, rArmTop}
                        -- Left arm
                        bones[#bones + 1] = {lArmTop, lArmBot}
                        -- Right arm
                        bones[#bones + 1] = {rArmTop, rArmBot}
                    end

                    if lLeg and rLeg then
                        local lLegTop = (lLeg.CFrame * CFrame.new(0, 1, 0)).Position
                        local rLegTop = (rLeg.CFrame * CFrame.new(0, 1, 0)).Position
                        local lLegBot = (lLeg.CFrame * CFrame.new(0, -1, 0)).Position
                        local rLegBot = (rLeg.CFrame * CFrame.new(0, -1, 0)).Position

                        -- Hip diagonals
                        bones[#bones + 1] = {torsoBot, lLegTop}
                        bones[#bones + 1] = {torsoBot, rLegTop}
                        -- Legs
                        bones[#bones + 1] = {lLegTop, lLegBot}
                        bones[#bones + 1] = {rLegTop, rLegBot}
                    end
                end
            end

            local boneIndex = 0
            for _, bone in ipairs(bones) do
                local worldA, worldB

                -- R15 uses part name pairs, R6 uses pre-computed Vector3 pairs
                if type(bone[1]) == "string" then
                    local partA = character:FindFirstChild(bone[1])
                    local partB = character:FindFirstChild(bone[2])
                    if not partA or not partB then continue end
                    worldA = partA.Position
                    worldB = partB.Position
                else
                    worldA = bone[1]
                    worldB = bone[2]
                end

                local posA, visA = Camera:WorldToViewportPoint(worldA)
                local posB, visB = Camera:WorldToViewportPoint(worldB)

                if visA and visB then
                    boneIndex = boneIndex + 1
                    local from = Vector2.new(posA.X, posA.Y)
                    local to = Vector2.new(posB.X, posB.Y)

                    -- Outline
                    obj.SkeletonOutlines[boneIndex].From = from
                    obj.SkeletonOutlines[boneIndex].To = to
                    obj.SkeletonOutlines[boneIndex].Visible = true

                    -- Colored line
                    obj.SkeletonLines[boneIndex].From = from
                    obj.SkeletonLines[boneIndex].To = to
                    obj.SkeletonLines[boneIndex].Color = ESP.Settings.SkeletonColor
                    obj.SkeletonLines[boneIndex].Visible = true
                end
            end

            -- Hide unused lines
            for i = boneIndex + 1, #obj.SkeletonOutlines do
                obj.SkeletonOutlines[i].Visible = false
                obj.SkeletonLines[i].Visible = false
            end
        else
            for i = 1, #obj.SkeletonOutlines do
                obj.SkeletonOutlines[i].Visible = false
                obj.SkeletonLines[i].Visible = false
            end
        end

        -- ═══════════════════════ CHAMS ESP ═══════════════════════
        if ESP.Settings.Chams then
            if not obj.Highlight or not obj.Highlight.Parent then
                local highlight = Instance.new("Highlight")
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = character
                highlight.Parent = character
                obj.Highlight = highlight
            end

            obj.Highlight.FillColor = ESP.Settings.ChamsColor
            obj.Highlight.OutlineColor = ESP.Settings.ChamsOutlineColor
            obj.Highlight.Enabled = true
        else
            if obj.Highlight then
                obj.Highlight.Enabled = false
            end
        end

        -- ═══════════════════════ DISTANCE ESP ═══════════════════════
        if ESP.Settings.Distance then
            local meters = math.floor(distance / 3.5714 + 0.5)
            obj.Distance.Text = "[" .. meters .. "m]"
            obj.Distance.Position = Vector2.new(bounds.X + bounds.Width / 2, bounds.Y + bounds.Height + 2)
            obj.Distance.Color = ESP.Settings.DistanceColor
            obj.Distance.Font = GetFont(ESP.Settings.Font)
            obj.Distance.Visible = true
        else
            obj.Distance.Visible = false
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
