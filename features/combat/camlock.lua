local Camlock = {}
Camlock.__index = Camlock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local PI = math.pi
local TWOPI = PI * 2
local abs = math.abs
local clamp = math.clamp
local sqrt = math.sqrt
local asin = math.asin
local atan2 = math.atan2
local min = math.min
local max = math.max

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

-- Internal state
local _statePitch = 0
local _stateYaw = 0
local _hasState = false
local _lastTime = tick()
local _mouseAccumX = 0
local _mouseAccumY = 0
local _killCooldown = false
local _killCooldownTime = 0
local KILL_COOLDOWN_SEC = 0.15

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
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return true
end

local function WorldToScreen(pos)
    local cam = workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
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

-- Convert CFrame to pitch/yaw angles
local function CFrameToAngles(cf)
    local lookVector = cf.LookVector
    local pitch = asin(clamp(lookVector.Y, -1, 1))
    local yaw = atan2(-lookVector.X, -lookVector.Z)
    return pitch, yaw
end

-- Build CFrame from position + pitch/yaw
local function AnglesToCFrame(pos, pitch, yaw)
    local cosPitch = math.cos(pitch)
    local lookDir = Vector3.new(
        -math.sin(yaw) * cosPitch,
        math.sin(pitch),
        -math.cos(yaw) * cosPitch
    )
    return CFrame.lookAt(pos, pos + lookDir)
end

-- Wrap angle difference to [-pi, pi]
local function WrapAngle(a)
    while a > PI do a = a - TWOPI end
    while a < -PI do a = a + TWOPI end
    return a
end

function Camlock:Lock()
    if self.Settings.StickyAim and self.Target and IsAlive(self.Target) then
        return
    end
    self.Target = self:GetTarget()
    _hasState = false
    _mouseAccumX = 0
    _mouseAccumY = 0
end

function Camlock:Unlock()
    self.Target = nil
    _hasState = false
    _mouseAccumX = 0
    _mouseAccumY = 0
end

function Camlock:Update(dt)
    Camera = workspace.CurrentCamera
    if not Camera then return end

    if not self.Settings.Enabled then
        self.Target = nil
        _hasState = false
        return
    end

    -- Kill cooldown: prevent flicking to new target immediately after a kill
    if _killCooldown then
        if (tick() - _killCooldownTime) < KILL_COOLDOWN_SEC then
            _hasState = false
            return
        end
        _killCooldown = false
    end

    -- Target validation
    if not self.Target or not IsAlive(self.Target) then
        if self.Target then
            -- Target just died — activate cooldown
            _killCooldown = true
            _killCooldownTime = tick()
            _hasState = false
        end
        self.Target = nil
        if not self.Settings.StickyAim then
            self.Target = self:GetTarget()
        end
        if not self.Target then
            _hasState = false
            return
        end
    end

    local character = GetCharacter(self.Target)
    if not character then
        self.Target = nil
        _hasState = false
        return
    end

    local screenCenter = GetScreenCenter()
    local targetPos = GetHitPosition(character, self.Settings.Hitpart, screenCenter)
    if not targetPos then
        self.Target = nil
        _hasState = false
        return
    end

    -- Prediction: velocity * prediction_value * 0.05 (~3 frames at 60fps feel)
    local prediction = self.Settings.Prediction
    if prediction > 0 then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel then
                targetPos = targetPos + vel * (prediction * 0.05)
            end
        end
    end

    -- Compute target angles from camera position
    local camPos = Camera.CFrame.Position
    local dx = targetPos.X - camPos.X
    local dy = targetPos.Y - camPos.Y
    local dz = targetPos.Z - camPos.Z
    local dist = sqrt(dx*dx + dy*dy + dz*dz)
    if dist < 0.001 then return end

    local tgtPitch = asin(clamp(dy / dist, -1, 1))
    local tgtYaw = atan2(-dx, -dz)

    -- Smoothness: frame-rate independent exponential ease-out
    -- base = 2/smooth per 60fps frame, factor = 1 - (1-base)^(dt*60)
    local useSmooth = self.Settings.SmoothEnabled and self.Settings.Smoothness > 1
    local factor = 1
    if useSmooth then
        local base = 2 / self.Settings.Smoothness
        factor = 1 - math.pow(1 - base, dt * 60)
        factor = clamp(factor, 0, 1)
    end

    -- Camera method: angle-based state tracking
    if self.Settings.Method == "Camera" then
        if not _hasState then
            -- Seed state from current camera
            _statePitch, _stateYaw = CFrameToAngles(Camera.CFrame)
            _hasState = true
        else
            -- Detect user mouse input (difference between live camera and what we last wrote)
            local livePitch, liveYaw = CFrameToAngles(Camera.CFrame)
            local userDp = livePitch - _statePitch
            local userDy = WrapAngle(liveYaw - _stateYaw)
            -- Clamp to filter jitter/torn reads
            local kMaxDelta = 0.05
            userDp = clamp(userDp, -kMaxDelta, kMaxDelta)
            userDy = clamp(userDy, -kMaxDelta, kMaxDelta)
            -- Apply user mouse movement to tracked state
            _statePitch = _statePitch + userDp
            _stateYaw = _stateYaw + userDy
        end

        -- Pull state toward target
        if useSmooth then
            local dp = tgtPitch - _statePitch
            local dy = WrapAngle(tgtYaw - _stateYaw)
            _statePitch = _statePitch + dp * factor
            _stateYaw = _stateYaw + dy * factor
        else
            _statePitch = tgtPitch
            _stateYaw = tgtYaw
        end

        -- Write camera
        Camera.CFrame = AnglesToCFrame(camPos, _statePitch, _stateYaw)

    -- Mouse method: angular error → pixel movement with accumulator
    elseif self.Settings.Method == "Mouse" then
        _hasState = false
        local curPitch, curYaw = CFrameToAngles(Camera.CFrame)

        local errP = tgtPitch - curPitch
        local errY = WrapAngle(tgtYaw - curYaw)

        -- Scale by smoothness factor
        local moveP = errP * factor
        local moveY = errY * factor

        -- Convert angular movement to pixels (gain tuned for Roblox sensitivity)
        local kGain = 200
        local kMaxPx = 150

        _mouseAccumX = clamp(_mouseAccumX + (-moveY * kGain), -kMaxPx, kMaxPx)
        _mouseAccumY = clamp(_mouseAccumY + (-moveP * kGain), -kMaxPx, kMaxPx)

        local sendX = math.floor(_mouseAccumX)
        local sendY = math.floor(_mouseAccumY)

        if sendX ~= 0 or sendY ~= 0 then
            _mouseAccumX = _mouseAccumX - sendX
            _mouseAccumY = _mouseAccumY - sendY
            mousemoverel(sendX, sendY)
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

    _lastTime = tick()
    self.Connection = RunService:BindToRenderStep("CamlockUpdate", Enum.RenderPriority.Camera.Value + 1, function()
        -- Delta time calculation (clamped like the C++ version)
        local now = tick()
        local dt = now - _lastTime
        _lastTime = now
        if dt <= 0 then dt = 0 end
        if dt > 0.05 then dt = 0.05 end

        -- Update FOV circle
        if self.Settings.ShowFOV then
            local center = GetScreenCenter()
            self.FOVCircle.Position = center
            self.FOVCircle.Radius = self.Settings.FOV
            self.FOVCircle.Color = self.Settings.FOVColor
            self.FOVCircle.Visible = true
        else
            self.FOVCircle.Visible = false
        end

        -- Update camlock with dt
        self:Update(dt)
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
