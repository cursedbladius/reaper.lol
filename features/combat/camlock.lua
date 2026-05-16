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
    Smoothness = 0,
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
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
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
    local referencePoint = GetTargetPoint(settings.Targeting)
    local fov = settings.FOV
    local closestPlayer = nil
    local closestDist = fov

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsAlive(player) then continue end

        local character = GetCharacter(player)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local screenPos, onScreen = WorldToScreen(hrp.Position)
        if not onScreen then continue end

        local dist = (screenPos - referencePoint).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end

    return closestPlayer
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
        if self.Settings.StickyAim then
            self.Target = nil
        end
        return
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

    -- Apply method
    if self.Settings.Method == "Camera" then
        local smoothness = self.Settings.Smoothness
        if smoothness > 0 then
            local currentCF = Camera.CFrame
            local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(targetCF, 1 - (smoothness / 100))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        end
    elseif self.Settings.Method == "Mouse" then
        local screenPos, onScreen = WorldToScreen(targetPos)
        if onScreen then
            local center = GetScreenCenter()
            local smoothness = self.Settings.Smoothness
            local targetMouse
            if smoothness > 0 then
                local currentMouse = GetMousePosition()
                targetMouse = currentMouse:Lerp(screenPos, 1 - (smoothness / 100))
            else
                targetMouse = screenPos
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

    self.Connection = RunService.RenderStepped:Connect(function()
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
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if self.FOVCircle then
        self.FOVCircle:Remove()
        self.FOVCircle = nil
    end
    self.Target = nil
end

return Camlock
