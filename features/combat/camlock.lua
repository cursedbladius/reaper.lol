local Camlock = {}
Camlock.__index = Camlock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

Camlock.Settings = {
    Enabled = false,
    StickyAim = false,
    Method = "Camera",
    Hitpart = "Head",
    Targeting = "Crosshair",
    SmoothEnabled = false,
    Smoothness = 50,
    Prediction = 0,
    FOV = 100,
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 89, 89),
}

Camlock.Target = nil
Camlock.Connection = nil
Camlock.FOVCircle = nil

local HITPARTS_MAP = {
    ["Head"] = {"Head"},
    ["Upper Torso"] = {"UpperTorso", "Torso"},
    ["HumanoidRootPart"] = {"HumanoidRootPart"},
    ["Lower Torso"] = {"LowerTorso", "Torso"},
    ["Left Arm"] = {"LeftUpperArm", "Left Arm"},
    ["Right Arm"] = {"RightUpperArm", "Right Arm"},
    ["Left Leg"] = {"LeftUpperLeg", "Left Leg"},
    ["Right Leg"] = {"RightUpperLeg", "Right Leg"},
}

local CLOSEST_PARTS = {
    "Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart",
    "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerArm", "RightLowerArm", "LeftLowerLeg", "RightLowerLeg",
    "LeftHand", "RightHand", "LeftFoot", "RightFoot",
    "Left Arm", "Right Arm", "Left Leg", "Right Leg"
}

local function GetCharacter(player)
    return player and player.Character
end

local function IsAlive(player)
    local char = GetCharacter(player)
    if not char then return false end
    if not char.Parent or char.Parent ~= workspace then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    -- Reject characters teleported underground (respawning)
    if hrp.Position.Y < -50 then return false end
    -- Arsenal-specific: check NRPBS.Health
    local nrpbs = player:FindFirstChild("NRPBS")
    if nrpbs then
        local hp = nrpbs:FindFirstChild("Health")
        if hp and hp.Value <= 0 then return false end
    end
    return true
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function GetMousePosition()
    return UserInputService:GetMouseLocation()
end

local function GetScreenCenter()
    local viewport = Camera.ViewportSize
    return Vector2.new(viewport.X / 2, viewport.Y / 2)
end

local function GetTargetPoint(targeting)
    if targeting == "Crosshair" then
        return GetScreenCenter()
    elseif targeting == "Mouse" then
        return GetMousePosition()
    end
    return GetScreenCenter()
end

local function GetClosestPartOnCharacter(character, referencePoint)
    local closestPart = nil
    local closestDist = math.huge

    for _, partName in ipairs(CLOSEST_PARTS) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local screenPos, onScreen = WorldToScreen(part.Position)
            if onScreen then
                local dist = (screenPos - referencePoint).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPart = part
                end
            end
        end
    end

    return closestPart
end

local function GetClosestPointOnCharacter(character, referencePoint)
    local closestPos = nil
    local closestDist = math.huge

    for _, partName in ipairs(CLOSEST_PARTS) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local size = part.Size
            local cf = part.CFrame
            -- Sample points on the surface of the part
            local offsets = {
                Vector3.new(0, 0, 0),
                Vector3.new(size.X/2, 0, 0), Vector3.new(-size.X/2, 0, 0),
                Vector3.new(0, size.Y/2, 0), Vector3.new(0, -size.Y/2, 0),
                Vector3.new(0, 0, size.Z/2), Vector3.new(0, 0, -size.Z/2),
                Vector3.new(size.X/4, size.Y/4, 0), Vector3.new(-size.X/4, -size.Y/4, 0),
                Vector3.new(size.X/4, -size.Y/4, 0), Vector3.new(-size.X/4, size.Y/4, 0),
            }
            for _, offset in ipairs(offsets) do
                local worldPos = cf:PointToWorldSpace(offset)
                local screenPos, onScreen = WorldToScreen(worldPos)
                if onScreen then
                    local dist = (screenPos - referencePoint).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPos = worldPos
                    end
                end
            end
        end
    end

    return closestPos
end

local function GetHitPosition(character, hitpart, referencePoint)
    if hitpart == "Closest Part" then
        local part = GetClosestPartOnCharacter(character, referencePoint)
        return part and part.Position
    elseif hitpart == "Closest Point" then
        return GetClosestPointOnCharacter(character, referencePoint)
    else
        local partNames = HITPARTS_MAP[hitpart]
        if partNames then
            for _, name in ipairs(partNames) do
                local part = character:FindFirstChild(name)
                if part and part:IsA("BasePart") then
                    return part.Position
                end
            end
        end
    end
    return nil
end

function Camlock:GetTarget()
    local settings = self.Settings
    local screenCenter = GetScreenCenter()
    local fov = settings.FOV
    local targeting = settings.Targeting
    local bestPlayer = nil
    local bestValue = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsAlive(player) then continue end

        local character = GetCharacter(player)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local screenPos, onScreen = WorldToScreen(hrp.Position)
        if not onScreen then continue end

        -- FOV check is always based on screen distance from center
        local screenDist = (screenPos - screenCenter).Magnitude
        if screenDist > fov then continue end

        local value
        if targeting == "Crosshair" then
            value = screenDist
        elseif targeting == "Distance" then
            value = (hrp.Position - Camera.CFrame.Position).Magnitude
        elseif targeting == "Health" then
            local hum = character:FindFirstChildOfClass("Humanoid")
            value = hum and hum.Health or math.huge
        else
            value = screenDist
        end

        if value < bestValue then
            bestValue = value
            bestPlayer = player
        end
    end

    return bestPlayer
end

function Camlock:Lock()
    if self.Settings.StickyAim and self.Target and IsAlive(self.Target) then
        return -- Keep current target
    end
    self.Target = self:GetTarget()
end

function Camlock:Unlock()
    self.Target = nil
end

function Camlock:Update()
    if not self.Settings.Enabled then
        self.Target = nil
        return
    end

    if not self.Target or not IsAlive(self.Target) then
        self.Target = nil
        -- Auto-acquire new target if not using sticky aim
        if not self.Settings.StickyAim then
            self.Target = self:GetTarget()
        end
        if not self.Target then return end
    end

    local character = GetCharacter(self.Target)
    if not character then
        self.Target = nil
        return
    end

    local referencePoint = GetTargetPoint(self.Settings.Targeting)
    local targetPos = GetHitPosition(character, self.Settings.Hitpart, referencePoint)
    if not targetPos then
        self.Target = nil
        return
    end

    -- Apply prediction
    local prediction = self.Settings.Prediction
    if prediction > 0 then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
            targetPos = targetPos + (velocity * prediction)
        end
    end

    -- Verify target is on screen before aiming
    local _, targetOnScreen = WorldToScreen(targetPos)
    if not targetOnScreen then return end

    -- Calculate lerp alpha (higher smoothness = slower tracking)
    local alpha = 1
    if self.Settings.SmoothEnabled and self.Settings.Smoothness > 0 then
        alpha = math.clamp(1 - (self.Settings.Smoothness / 100), 0.01, 1)
    end

    -- Apply method
    Camera = workspace.CurrentCamera
    if self.Settings.Method == "Camera" then
        local currentCF = Camera.CFrame
        local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
        if alpha >= 1 then
            Camera.CFrame = targetCF
        else
            Camera.CFrame = currentCF:Lerp(targetCF, alpha)
        end
    elseif self.Settings.Method == "Mouse" then
        local screenPos, onScreen = WorldToScreen(targetPos)
        if onScreen then
            local center = GetScreenCenter()
            local currentMouse = GetMousePosition()
            local targetMouse
            if alpha >= 1 then
                targetMouse = screenPos
            else
                targetMouse = currentMouse:Lerp(screenPos, alpha)
            end
            local delta = targetMouse - center
            mousemoverel(delta.X, delta.Y)
        end
    end
end

function Camlock:SetSetting(key, value)
    self.Settings[key] = value
end

function Camlock:Initialize()
    -- FOV circle
    self.FOVCircle = Drawing.new("Circle")
    self.FOVCircle.Visible = false
    self.FOVCircle.Thickness = 1
    self.FOVCircle.NumSides = 64
    self.FOVCircle.Radius = self.Settings.FOV
    self.FOVCircle.Color = self.Settings.FOVColor
    self.FOVCircle.Filled = false
    self.FOVCircle.Transparency = 1

    self.Connection = RunService:BindToRenderStep("CamlockUpdate", Enum.RenderPriority.Camera.Value + 1, function()
        -- Update FOV circle
        if self.Settings.ShowFOV then
            local center = GetTargetPoint(self.Settings.Targeting)
            self.FOVCircle.Position = center
            self.FOVCircle.Radius = self.Settings.FOV
            self.FOVCircle.Color = self.Settings.FOVColor
            self.FOVCircle.Visible = true
        else
            self.FOVCircle.Visible = false
        end

        -- Update camlock
        self:Update()
    end)
end

function Camlock:Unload()
    if self.Connection then
        pcall(function() RunService:UnbindFromRenderStep("CamlockUpdate") end)
        self.Connection = nil
    end
    if self.FOVCircle then
        self.FOVCircle:Remove()
        self.FOVCircle = nil
    end
    self.Target = nil
end

return Camlock
