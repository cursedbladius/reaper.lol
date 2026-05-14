local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local ESP = {}
ESP.Objects = {}

-- ── material name → enum ──────────────────────────────────────────────────────
local MaterialMap = {
    Plastic       = Enum.Material.Plastic,
    ForceField    = Enum.Material.ForceField,
    Neon          = Enum.Material.Neon,
    Glass         = Enum.Material.Glass,
    SmoothPlastic = Enum.Material.SmoothPlastic,
}

-- How much Highlight fill to leave per material in Custom/Static mode.
-- Neon glows through walls on its own so the overlay is nearly invisible.
local MaterialFillTransparency = {
    Plastic       = 0.55,
    ForceField    = 0.35,
    Neon          = 0.88,
    Glass         = 0.65,
    SmoothPlastic = 0.55,
}

-- ── init ──────────────────────────────────────────────────────────────────────
function ESP:Init(flagsTable)
    self.Flags = flagsTable
end

-- ── occlusion raycast ─────────────────────────────────────────────────────────
function ESP:IsVisible(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local origin    = Camera.CFrame.Position
    local direction = root.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, character }

    local result = Workspace:Raycast(origin, direction, params)
    return result == nil
end

-- ── collect all BaseParts from a character once at create-time ────────────────
local function collectParts(character)
    local parts = {}
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("BasePart") then
            parts[#parts + 1] = desc
        end
    end
    return parts
end

-- ── write material + color to cached part list ────────────────────────────────
local function applyToPartsStatic(parts, material, color)
    for _, part in ipairs(parts) do
        pcall(function()
            part.Material = material
            part.Color    = color
        end)
    end
end

-- ── write only color (for per-frame effects that don't change material) ───────
local function applyColorToParts(parts, color)
    for _, part in ipairs(parts) do
        pcall(function() part.Color = color end)
    end
end

-- ── write only transparency (for pulse effect) ────────────────────────────────
local function applyTransparencyToParts(parts, alpha)
    for _, part in ipairs(parts) do
        pcall(function() part.Transparency = alpha end)
    end
end

-- ── create a Highlight parented INSIDE the character ─────────────────────────
-- Parenting inside the character (no Adornee set) means Roblox auto-adorns
-- the ancestor Model. This avoids the CoreGui bug where only the most-recently-
-- added Adornee highlight renders when multiple players are present.
function ESP:CreateForCharacter(player, character)
    self:Remove(player)  -- destroy any old objects first (handles respawn)

    local highlight = Instance.new("Highlight")
    highlight.Name                = "reaper_cham"
    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency    = 0.50
    highlight.OutlineTransparency = 1      -- no outline, chams-fill only
    highlight.Parent              = character  -- auto-adorns the Model

    self.Objects[player] = {
        Highlight     = highlight,
        Character     = character,
        Parts         = collectParts(character),  -- cached; never rebuilt per-frame
        _stateKey     = "",    -- dirty-check: "type|material|color"
        _glitchPhase  = 0,    -- glitch effect state
    }

    table.insert(getgenv().reaper_objects, highlight)
end

-- ── remove a player's ESP objects ────────────────────────────────────────────
function ESP:Remove(player)
    local obj = self.Objects[player]
    if not obj then return end
    pcall(function() obj.Highlight:Destroy() end)
    self.Objects[player] = nil
end

-- ── hide all highlights without destroying ───────────────────────────────────
function ESP:Hide()
    for _, obj in pairs(self.Objects) do
        pcall(function() obj.Highlight.Enabled = false end)
    end
end

-- ── per-frame update ──────────────────────────────────────────────────────────
function ESP:Update()
    local flags = self.Flags
    local t     = os.clock()

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character

        -- No character → clean up
        if not character then
            if self.Objects[player] then self:Remove(player) end
            continue
        end

        local humanoid = character:FindFirstChild("Humanoid")
        local root     = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then continue end

        -- Dead → clean up
        if humanoid.Health <= 0 then
            if self.Objects[player] then self:Remove(player) end
            continue
        end

        -- Respawn: character reference changed → recreate
        local obj = self.Objects[player]
        if obj and obj.Character ~= character then
            self:Remove(player)
            obj = nil
        end

        -- Team check
        if flags.visuals_teamcheck then
            if player.Team ~= nil and player.Team == LocalPlayer.Team then
                if self.Objects[player] then
                    self.Objects[player].Highlight.Enabled = false
                end
                continue
            end
        end

        -- Distance check
        local localChar = LocalPlayer.Character
        if localChar then
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local dist = (localRoot.Position - root.Position).Magnitude
                if dist > (flags.visuals_distance or 2500) then
                    if self.Objects[player] then
                        self.Objects[player].Highlight.Enabled = false
                    end
                    continue
                end
            end
        end

        -- Ensure objects exist
        if not self.Objects[player] then
            self:CreateForCharacter(player, character)
        end

        obj = self.Objects[player]
        if not obj then continue end

        -- Occlusion check
        if flags.visuals_occluded and not self:IsVisible(character) then
            obj.Highlight.Enabled = false
            continue
        end

        -- ── read flags ────────────────────────────────────────────────────────
        local chamType   = flags.visuals_chams_type   or "Highlight"
        local chamEffect = flags.visuals_chams_effect  or "Static"
        local chamColor  = flags.visuals_chams_color   or Color3.fromRGB(255, 50, 50)
        local matName    = flags.visuals_chams_material or "Plastic"
        local mat        = MaterialMap[matName] or Enum.Material.Plastic

        -- Dirty-check key — part mutations only fire when something changes
        local stateKey = chamType .. "|" .. matName .. "|" .. tostring(chamColor)
        local stateChanged = obj._stateKey ~= stateKey

        obj.Highlight.Enabled           = true
        obj.Highlight.OutlineTransparency = 1

        -- ══ TYPE: Highlight ═══════════════════════════════════════════════════
        -- Pure Roblox Highlight — no character part mutations
        if chamType == "Highlight" then

            obj.Highlight.FillColor        = chamColor
            obj.Highlight.FillTransparency = 0.45

            if stateChanged then
                obj._stateKey = stateKey
            end

        -- ══ TYPE: Custom ══════════════════════════════════════════════════════
        -- Mutates character BasePart Material + Color directly.
        -- Effects animate the Highlight and/or part properties each frame.
        elseif chamType == "Custom" then

            -- Apply static material + color once when flags change.
            -- Effects that need per-frame color updates handle parts themselves.
            if stateChanged then
                obj._stateKey = stateKey
                if chamEffect == "Static" or chamEffect == "Pulse" then
                    applyToPartsStatic(obj.Parts, mat, chamColor)
                    obj.Highlight.FillTransparency =
                        MaterialFillTransparency[matName] or 0.55
                end
                -- Rainbow and Glitch update parts every frame so skip here
            end

            -- ── Effect: Static ────────────────────────────────────────────────
            -- Material + color on parts; subtle colored Highlight overlay.
            if chamEffect == "Static" then
                obj.Highlight.FillColor = chamColor

            -- ── Effect: Pulse ─────────────────────────────────────────────────
            -- Highlight transparency breathes in and out; parts follow.
            elseif chamEffect == "Pulse" then
                local wave  = math.sin(t * 3.5)          -- −1 … 1
                local alpha = 0.52 + 0.33 * wave         -- 0.19 … 0.85

                obj.Highlight.FillColor        = chamColor
                obj.Highlight.FillTransparency = alpha

                -- Parts pulse opacity in sync (half amplitude so they stay visible)
                local partAlpha = 0.10 + 0.20 * (0.5 + 0.5 * wave)
                applyTransparencyToParts(obj.Parts, partAlpha)

            -- ── Effect: Rainbow ───────────────────────────────────────────────
            -- HSV hue cycles through the full spectrum; saturation stays rich.
            elseif chamEffect == "Rainbow" then
                local hue          = (t * 0.12) % 1          -- full cycle ≈ 8 s
                local rainbowColor = Color3.fromHSV(hue, 0.90, 1.00)

                obj.Highlight.FillColor        = rainbowColor
                obj.Highlight.FillTransparency = 0.40

                -- Apply material (once on state change) and color (every frame)
                if stateChanged then
                    applyToPartsStatic(obj.Parts, mat, rainbowColor)
                else
                    applyColorToParts(obj.Parts, rainbowColor)
                end

            -- ── Effect: Glitch ────────────────────────────────────────────────
            -- Deterministic pseudo-random flicker using overlapping sine waves.
            -- No math.random() → no garbage per frame.
            elseif chamEffect == "Glitch" then
                -- Two incommensurate frequencies → appears random without RNG
                local glitched = math.sin(t * 17.3) * math.sin(t * 6.7) > 0.35

                local displayColor
                if glitched then
                    -- Shift hue by 0.5 (complementary color) and max brightness
                    local h, s, _ = Color3.toHSV(chamColor)
                    displayColor  = Color3.fromHSV((h + 0.5) % 1, s, 1.0)
                    obj.Highlight.FillTransparency = 0.15
                else
                    displayColor  = chamColor
                    obj.Highlight.FillTransparency = 0.60
                end

                obj.Highlight.FillColor = displayColor

                -- Apply material once; update color every frame for flicker
                if stateChanged then
                    applyToPartsStatic(obj.Parts, mat, displayColor)
                else
                    applyColorToParts(obj.Parts, displayColor)
                end
            end
        end
    end
end

-- ── auto-remove when player leaves ───────────────────────────────────────────
Players.PlayerRemoving:Connect(function(player)
    if ESP.Objects[player] then
        ESP:Remove(player)
    end
end)

return ESP
