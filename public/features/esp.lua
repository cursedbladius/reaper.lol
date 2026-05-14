local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local ESP = {}
ESP.Objects = {}

-- ── PlayerGui container ───────────────────────────────────────────────────────
-- Parenting here + setting Adornee explicitly is the ONLY reliable way to show
-- Highlights on ALL players simultaneously. Parenting inside the character model
-- conflicts with any Highlight the game itself places on characters, causing
-- only one player to be highlighted at a time.
local Container do
    Container = LocalPlayer.PlayerGui:FindFirstChild("reaper_esp")
    if not Container then
        Container = Instance.new("ScreenGui")
        Container.Name         = "reaper_esp"
        Container.ResetOnSpawn = false
        Container.Parent       = LocalPlayer.PlayerGui
    end
    table.insert(getgenv().reaper_objects, Container)
end

local MaterialMap = {
    Plastic       = Enum.Material.Plastic,
    ForceField    = Enum.Material.ForceField,
    Neon          = Enum.Material.Neon,
    Glass         = Enum.Material.Glass,
    SmoothPlastic = Enum.Material.SmoothPlastic,
}

local MatFillAlpha = {
    Plastic       = 0.55,
    ForceField    = 0.35,
    Neon          = 0.88,
    Glass         = 0.65,
    SmoothPlastic = 0.55,
}

function ESP:Init(flags) self.Flags = flags end

-- ── Occlusion ─────────────────────────────────────────────────────────────────
function ESP:IsVisible(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, character }
    return Workspace:Raycast(Camera.CFrame.Position, root.Position - Camera.CFrame.Position, params) == nil
end

-- ── Part snapshot (store originals so we can restore later) ──────────────────
local function snapshotParts(character)
    local list = {}
    for _, d in ipairs(character:GetDescendants()) do
        if d:IsA("BasePart") then
            list[#list+1] = { p=d, mat=d.Material, col=d.Color, tr=d.Transparency }
        end
    end
    return list
end

local function applyParts(list, mat, col)
    for _, e in ipairs(list) do
        pcall(function() e.p.Material=mat; e.p.Color=col; e.p.Transparency=0 end)
    end
end

local function restoreParts(list)
    for _, e in ipairs(list) do
        pcall(function() e.p.Material=e.mat; e.p.Color=e.col; e.p.Transparency=e.tr end)
    end
end

-- ── Effect instance management ────────────────────────────────────────────────
local function clearFx(obj)
    for _, inst in ipairs(obj.Fx) do pcall(function() inst:Destroy() end) end
    obj.Fx    = {}
    obj.Light = nil
end

local function buildFx(obj, effect, color, character)
    clearFx(obj)
    local root  = character:FindFirstChild("HumanoidRootPart")
    local head  = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

    local function addLight(parent, range, brightness)
        if not parent then return end
        local l = Instance.new("PointLight")
        l.Color = color; l.Range = range; l.Brightness = brightness
        l.Parent = parent
        obj.Light = l
        obj.Fx[#obj.Fx+1] = l
    end

    if effect == "Pulse" then
        addLight(root, 22, 5)

    elseif effect == "Sparkles" then
        for _, part in ipairs({ head, root, torso }) do
            if part then
                local s = Instance.new("Sparkles")
                s.SparkleColor = color; s.Enabled = true; s.Parent = part
                obj.Fx[#obj.Fx+1] = s
            end
        end
        addLight(root, 14, 3)

    elseif effect == "Fire" then
        for _, part in ipairs({ root, torso }) do
            if part then
                local f = Instance.new("Fire")
                f.Color = color
                f.SecondaryColor = Color3.fromRGB(15, 15, 15)
                f.Size = 4; f.Heat = 6; f.Parent = part
                obj.Fx[#obj.Fx+1] = f
            end
        end
        addLight(root, 20, 4)

    elseif effect == "Rainbow" then
        addLight(root, 18, 4)
    end
end

-- ── Create ESP for a character ────────────────────────────────────────────────
function ESP:CreateForCharacter(player, character)
    self:Remove(player)

    local hl = Instance.new("Highlight")
    hl.Name                = "reaper_cham"
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency    = 0.50
    hl.OutlineTransparency = 1
    hl.Adornee             = character   -- explicit adornee
    hl.Parent              = Container   -- lives in PlayerGui, not inside character

    self.Objects[player] = {
        Highlight      = hl,
        Character      = character,
        Parts          = snapshotParts(character),
        Fx             = {},
        Light          = nil,
        _partsModified = false,
        _stateKey      = "",
    }
    table.insert(getgenv().reaper_objects, hl)
end

function ESP:Remove(player)
    local obj = self.Objects[player]
    if not obj then return end
    clearFx(obj)
    if obj._partsModified then restoreParts(obj.Parts) end
    pcall(function() obj.Highlight:Destroy() end)
    self.Objects[player] = nil
end

function ESP:Hide()
    for _, obj in pairs(self.Objects) do
        pcall(function() obj.Highlight.Enabled = false end)
        if obj.Light then pcall(function() obj.Light.Enabled = false end) end
        for _, inst in ipairs(obj.Fx) do
            pcall(function()
                if inst:IsA("Sparkles") or inst:IsA("Fire") then inst.Enabled = false end
            end)
        end
    end
end

-- ── Per-frame update ──────────────────────────────────────────────────────────
function ESP:Update()
    local flags = self.Flags
    local t     = os.clock()

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character
        if not character then
            if self.Objects[player] then self:Remove(player) end
            continue
        end

        local humanoid = character:FindFirstChild("Humanoid")
        local root     = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then continue end

        if humanoid.Health <= 0 then
            if self.Objects[player] then self:Remove(player) end
            continue
        end

        -- Respawn detection
        local obj = self.Objects[player]
        if obj and obj.Character ~= character then
            self:Remove(player); obj = nil
        end

        -- Team check
        if flags.visuals_teamcheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
            if self.Objects[player] then self.Objects[player].Highlight.Enabled = false end
            continue
        end

        -- Distance check
        local lc = LocalPlayer.Character
        if lc then
            local lr = lc:FindFirstChild("HumanoidRootPart")
            if lr and (lr.Position - root.Position).Magnitude > (flags.visuals_distance or 2500) then
                if self.Objects[player] then self.Objects[player].Highlight.Enabled = false end
                continue
            end
        end

        if not self.Objects[player] then self:CreateForCharacter(player, character) end
        obj = self.Objects[player]
        if not obj then continue end

        -- Occlusion
        if flags.visuals_occluded and not self:IsVisible(character) then
            obj.Highlight.Enabled = false; continue
        end

        local chamType   = flags.visuals_chams_type    or "Highlight"
        local chamEffect = flags.visuals_chams_effect   or "Static"
        local chamColor  = flags.visuals_chams_color    or Color3.fromRGB(255, 50, 50)
        local matName    = flags.visuals_chams_material or "Plastic"
        local mat        = MaterialMap[matName] or Enum.Material.Plastic

        local stateKey = chamType.."|"..chamEffect.."|"..matName.."|"..tostring(chamColor)
        local changed  = obj._stateKey ~= stateKey

        obj.Highlight.Enabled           = true
        obj.Highlight.OutlineTransparency = 1

        -- ══ TYPE: Highlight ═══════════════════════════════════════════════════
        if chamType == "Highlight" then
            if changed then
                obj._stateKey = stateKey
                if obj._partsModified then restoreParts(obj.Parts); obj._partsModified = false end
                clearFx(obj)
            end
            obj.Highlight.FillColor        = chamColor
            obj.Highlight.FillTransparency = 0.45

        -- ══ TYPE: Custom ══════════════════════════════════════════════════════
        elseif chamType == "Custom" then
            if changed then
                obj._stateKey = stateKey
                applyParts(obj.Parts, mat, chamColor)
                obj._partsModified = true
                buildFx(obj, chamEffect, chamColor, character)
                obj.Highlight.FillTransparency = MatFillAlpha[matName] or 0.55
            end

            -- Re-enable effect instances each frame (in case Hide() disabled them)
            for _, inst in ipairs(obj.Fx) do
                pcall(function()
                    if inst:IsA("Sparkles") or inst:IsA("Fire") then inst.Enabled = true end
                    if inst:IsA("PointLight") then inst.Enabled = true end
                end)
            end

            if chamEffect == "Static" then
                obj.Highlight.FillColor = chamColor

            elseif chamEffect == "Pulse" then
                local wave = math.sin(t * 3.5)
                obj.Highlight.FillColor        = chamColor
                obj.Highlight.FillTransparency = 0.52 + 0.33 * wave
                if obj.Light then obj.Light.Brightness = 3 + 4 * (0.5 + 0.5 * wave) end

            elseif chamEffect == "Sparkles" then
                obj.Highlight.FillColor        = chamColor
                obj.Highlight.FillTransparency = 0.70
                if obj.Light then
                    obj.Light.Brightness = 2 + 2 * math.abs(math.sin(t * 2))
                end

            elseif chamEffect == "Fire" then
                obj.Highlight.FillColor        = chamColor
                obj.Highlight.FillTransparency = 0.65
                -- Flicker light like real fire
                if obj.Light then
                    obj.Light.Brightness = 3 + 2 * math.sin(t * 11.3) * math.sin(t * 7.1)
                end

            elseif chamEffect == "Rainbow" then
                local hue   = (t * 0.12) % 1
                local rcol  = Color3.fromHSV(hue, 0.90, 1.00)
                obj.Highlight.FillColor        = rcol
                obj.Highlight.FillTransparency = 0.40
                -- Apply rainbow color to parts every frame
                for _, e in ipairs(obj.Parts) do
                    pcall(function() e.p.Color = rcol end)
                end
                if obj.Light then obj.Light.Color = rcol end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if ESP.Objects[player] then ESP:Remove(player) end
end)

return ESP
