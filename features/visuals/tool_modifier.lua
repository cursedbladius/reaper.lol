local ToolModifier = {}

ToolModifier.Enabled = false
ToolModifier.Color = Color3.fromRGB(255, 0, 0)
ToolModifier.Alpha = 0.4
ToolModifier.Material = "Highlight"
ToolModifier.OutlineColor = Color3.fromRGB(255, 255, 255)
ToolModifier.OutlineEnabled = true
ToolModifier.Effect = "None"
ToolModifier.EffectSpeed = 1

ToolModifier.ArmEnabled = false
ToolModifier.ArmColor = Color3.fromRGB(0, 255, 0)
ToolModifier.ArmAlpha = 0.4
ToolModifier.ArmMaterial = "Highlight"
ToolModifier.ArmOutlineColor = Color3.fromRGB(255, 255, 255)
ToolModifier.ArmOutlineEnabled = true
ToolModifier.ArmEffect = "None"
ToolModifier.ArmEffectSpeed = 1

local CurrentTool = nil
local ToolHighlight = nil
local ToolPartData = {}

local function LerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

local function GetEffectColors(effect, speed, baseColor, outlineColor, alpha)
    local t = tick() * (speed or 1)
    if effect == "Rainbow" then
        local hue = (t * 0.15) % 1
        local rainbow = Color3.fromHSV(hue, 1, 1)
        return rainbow, rainbow, alpha
    elseif effect == "Gradient" then
        local lerp = (math.sin(t * 2) + 1) / 2
        local fill = LerpColor(baseColor, outlineColor, lerp)
        local outline = LerpColor(outlineColor, baseColor, lerp)
        return fill, outline, alpha
    elseif effect == "Breathing" then
        local pulse = (math.sin(t * 2) + 1) / 2
        local a = alpha + (1 - alpha) * pulse * 0.6
        return baseColor, outlineColor, a
    elseif effect == "Rainbow Gradient" then
        local hue1 = (t * 0.15) % 1
        local hue2 = (hue1 + 0.5) % 1
        local lerp = (math.sin(t * 2) + 1) / 2
        local c1 = Color3.fromHSV(hue1, 1, 1)
        local c2 = Color3.fromHSV(hue2, 1, 1)
        return LerpColor(c1, c2, lerp), LerpColor(c2, c1, lerp), alpha
    end
    return baseColor, outlineColor, alpha
end

local GameAdapter = nil
local GameHighlights = {}
local GameOriginals = {}
local ArmHighlights = {}
local ArmOriginals = {}

function ToolModifier:Initialize(gameAdapter)
    GameAdapter = gameAdapter
end

function ToolModifier:Reset()
    if ToolHighlight then
        pcall(function() ToolHighlight:Destroy() end)
        ToolHighlight = nil
    end
    for _, hl in pairs(GameHighlights) do
        pcall(function() hl:Destroy() end)
    end
    GameHighlights = {}
    for part, orig in pairs(GameOriginals) do
        pcall(function()
            part.Material = orig.Material
            part.Color = orig.Color
            part.BrickColor = orig.BrickColor
            if orig.TextureID ~= nil then
                pcall(function() part.TextureID = orig.TextureID end)
            end
            if orig.SpecialMesh and orig.SpecialMeshTexture then
                pcall(function() orig.SpecialMesh.TextureId = orig.SpecialMeshTexture end)
            end
            for _, r in ipairs(orig.Removables or {}) do
                pcall(function() if not r.Instance.Parent then r.Instance.Parent = r.Parent end end)
            end
        end)
    end
    GameOriginals = {}
    for part, data in pairs(ToolPartData) do
        pcall(function()
            part.Material = data.Material
            part.Color = data.Color
            part.BrickColor = data.BrickColor
            if data.TextureID ~= nil then
                part.TextureID = data.TextureID
            end
            if data.SpecialMesh and data.SpecialMeshTexture then
                data.SpecialMesh.TextureId = data.SpecialMeshTexture
            end
            for _, obj in ipairs(data.Removables) do
                if not obj.Parent then obj.Parent = part end
            end
        end)
    end
    ToolPartData = {}
    CurrentTool = nil
end

function ToolModifier:Unload()
    self:Reset()
    self.Enabled = false
end

local function ApplyToEquippedTool(self)
    local character = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        if ToolHighlight then ToolHighlight.Enabled = false end
        return
    end

    if tool ~= CurrentTool then
        self:Reset()
        CurrentTool = tool
    end

    local isMaterial = (self.Material == "ForceField" or self.Material == "Neon")

    if not isMaterial then
        if not ToolHighlight or not ToolHighlight.Parent then
            ToolHighlight = Instance.new("Highlight")
            ToolHighlight.Parent = tool
        end
        ToolHighlight.Adornee = tool
        local fc, oc, fa = GetEffectColors(self.Effect, self.EffectSpeed, self.Color, self.OutlineColor, self.Alpha)
        ToolHighlight.FillColor = fc
        ToolHighlight.FillTransparency = fa
        ToolHighlight.OutlineColor = oc
        ToolHighlight.OutlineTransparency = self.OutlineEnabled and 0 or 1
        ToolHighlight.Enabled = true
    else
        if ToolHighlight then
            ToolHighlight.Enabled = false
        end
    end

    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            if not ToolPartData[part] then
                local removables = {}
                local specialMesh = nil
                local specialMeshTexture = nil
                for _, child in ipairs(part:GetChildren()) do
                    if child:IsA("SurfaceAppearance") then
                        table.insert(removables, child)
                    end
                    if child:IsA("SpecialMesh") then
                        specialMesh = child
                        specialMeshTexture = child.TextureId
                    end
                end
                ToolPartData[part] = {
                    Material = part.Material,
                    Color = part.Color,
                    BrickColor = part.BrickColor,
                    TextureID = part:IsA("MeshPart") and part.TextureID or nil,
                    Removables = removables,
                    SpecialMesh = specialMesh,
                    SpecialMeshTexture = specialMeshTexture
                }
            end

            if self.Material == "ForceField" then
                part.Material = Enum.Material.ForceField
                part.BrickColor = BrickColor.new(self.Color)
                for _, child in ipairs(part:GetChildren()) do
                    if child:IsA("SurfaceAppearance") then
                        pcall(function() child.Parent = nil end)
                    end
                end
            elseif self.Material == "Neon" then
                part.Color = self.Color
                part.Material = Enum.Material.Neon
                for _, obj in ipairs(ToolPartData[part].Removables) do
                    pcall(function() obj.Parent = nil end)
                end
                pcall(function()
                    if part:IsA("MeshPart") then
                        part.TextureID = ""
                    end
                end)
                if ToolPartData[part].SpecialMesh then
                    pcall(function() ToolPartData[part].SpecialMesh.TextureId = "" end)
                end
            else
                local data = ToolPartData[part]
                part.Material = data.Material
                part.Color = data.Color
                pcall(function()
                    if part:IsA("MeshPart") and data.TextureID ~= nil then
                        part.TextureID = data.TextureID
                    end
                end)
                if data.SpecialMesh and data.SpecialMeshTexture then
                    pcall(function() data.SpecialMesh.TextureId = data.SpecialMeshTexture end)
                end
                for _, obj in ipairs(data.Removables) do
                    pcall(function() if not obj.Parent then obj.Parent = part end end)
                end
            end
        end
    end
end

local function ApplyToGameTargets(self)
    if not GameAdapter then return end

    local localPlayer = game:GetService("Players").LocalPlayer
    local targets = GameAdapter:GetToolTargets(localPlayer.Name)
    if #targets == 0 then return end

    local allParts = {}
    for _, target in pairs(targets) do
        local parts = {target}
        for _, p in pairs(target:GetDescendants()) do
            table.insert(parts, p)
        end
        for _, p in pairs(parts) do
            if p:IsA("BasePart") and not GameOriginals[p] then
                local removables = {}
                local specialMesh = nil
                local specialMeshTexture = nil
                for _, child in ipairs(p:GetChildren()) do
                    if child:IsA("SurfaceAppearance") or child:IsA("Decal") or child:IsA("Texture") then
                        table.insert(removables, {Instance = child, Parent = p})
                    end
                    if child:IsA("SpecialMesh") or child:IsA("FileMesh") then
                        specialMesh = child
                        specialMeshTexture = child.TextureId
                    end
                end
                GameOriginals[p] = {
                    Material = p.Material,
                    Color = p.Color,
                    BrickColor = p.BrickColor,
                    TextureID = pcall(function() return p.TextureID end) and p.TextureID or nil,
                    SpecialMesh = specialMesh,
                    SpecialMeshTexture = specialMeshTexture,
                    Removables = removables,
                }
            end
            if p:IsA("BasePart") then
                table.insert(allParts, p)
            end
        end
    end

    if self.Material == "Highlight" then
        for _, p in pairs(allParts) do
            pcall(function()
                local orig = GameOriginals[p]
                if orig then
                    p.Material = orig.Material
                    p.Color = orig.Color
                    p.BrickColor = orig.BrickColor
                end
            end)
            pcall(function()
                local existing = nil
                for _, c in pairs(p:GetChildren()) do
                    if c.Name == "_ToolModHighlight" then existing = c break end
                end
                local fc, oc, fa = GetEffectColors(self.Effect, self.EffectSpeed, self.Color, self.OutlineColor, self.Alpha)
                if not existing then
                    local hl = Instance.new("Highlight")
                    hl.Name = "_ToolModHighlight"
                    hl.Adornee = p
                    hl.FillColor = fc
                    hl.FillTransparency = fa
                    hl.OutlineColor = oc
                    hl.OutlineTransparency = self.OutlineEnabled and 0 or 1
                    hl.Parent = p
                    table.insert(GameHighlights, hl)
                else
                    existing.FillColor = fc
                    existing.FillTransparency = fa
                    existing.OutlineColor = oc
                    existing.OutlineTransparency = self.OutlineEnabled and 0 or 1
                end
            end)
        end
    else
        for _, hl in pairs(GameHighlights) do
            pcall(function() hl:Destroy() end)
        end
        GameHighlights = {}

        local mat = self.Material == "ForceField" and Enum.Material.ForceField or Enum.Material.Neon
        local fc, _, _ = GetEffectColors(self.Effect, self.EffectSpeed, self.Color, self.OutlineColor, self.Alpha)
        for _, p in pairs(allParts) do
            pcall(function()
                p.Material = mat
                if self.Material == "ForceField" then
                    p.BrickColor = BrickColor.new(fc)
                else
                    p.Color = fc
                end
                pcall(function() p.TextureID = "" end)
            end)
        end
        for _, target in pairs(targets) do
            for _, p in pairs(target:GetDescendants()) do
                pcall(function()
                    if p:IsA("SpecialMesh") or p:IsA("FileMesh") then
                        p.TextureId = ""
                    elseif p:IsA("SurfaceAppearance") or p:IsA("Decal") or p:IsA("Texture") then
                        p.Parent = nil
                    end
                end)
            end
        end
    end
end

local function ApplyToArmTargets(self)
    if not GameAdapter or not GameAdapter.GetArmTargets then return end

    local localPlayer = game:GetService("Players").LocalPlayer
    local targets = GameAdapter:GetArmTargets(localPlayer.Name)
    if #targets == 0 then return end

    local allParts = {}
    for _, target in pairs(targets) do
        local parts = {target}
        for _, p in pairs(target:GetDescendants()) do
            table.insert(parts, p)
        end
        for _, p in pairs(parts) do
            if p:IsA("BasePart") and not ArmOriginals[p] then
                local removables = {}
                local specialMesh = nil
                local specialMeshTexture = nil
                for _, child in ipairs(p:GetChildren()) do
                    if child:IsA("SurfaceAppearance") or child:IsA("Decal") or child:IsA("Texture") then
                        table.insert(removables, {Instance = child, Parent = p})
                    end
                    if child:IsA("SpecialMesh") or child:IsA("FileMesh") then
                        specialMesh = child
                        specialMeshTexture = child.TextureId
                    end
                end
                ArmOriginals[p] = {
                    Material = p.Material,
                    Color = p.Color,
                    BrickColor = p.BrickColor,
                    TextureID = pcall(function() return p.TextureID end) and p.TextureID or nil,
                    SpecialMesh = specialMesh,
                    SpecialMeshTexture = specialMeshTexture,
                    Removables = removables,
                }
            end
            if p:IsA("BasePart") then
                table.insert(allParts, p)
            end
        end
    end

    for _, hl in pairs(ArmHighlights) do
        pcall(function() hl:Destroy() end)
    end
    ArmHighlights = {}

    local mat
    if self.ArmMaterial == "Highlight" then
        mat = Enum.Material.Neon
    elseif self.ArmMaterial == "ForceField" then
        mat = Enum.Material.ForceField
    else
        mat = Enum.Material.Neon
    end

    local fc, _, _ = GetEffectColors(self.ArmEffect, self.ArmEffectSpeed, self.ArmColor, self.ArmOutlineColor, self.ArmAlpha)
    for _, p in pairs(allParts) do
        pcall(function()
            if p.Transparency < 1 then
                p.Material = mat
                if self.ArmMaterial == "ForceField" then
                    p.BrickColor = BrickColor.new(fc)
                else
                    p.Color = fc
                end
                pcall(function() p.TextureID = "" end)
            end
        end)
    end
    for _, target in pairs(targets) do
        local items = {target}
        for _, d in pairs(target:GetDescendants()) do
            table.insert(items, d)
        end
        for _, p in pairs(items) do
            pcall(function()
                if p:IsA("SpecialMesh") or p:IsA("FileMesh") then
                    p.TextureId = ""
                elseif p:IsA("SurfaceAppearance") or p:IsA("Decal") or p:IsA("Texture") then
                    p.Parent = nil
                end
            end)
        end
    end
end

function ToolModifier:ResetArms()
    for _, hl in pairs(ArmHighlights) do
        pcall(function() hl:Destroy() end)
    end
    ArmHighlights = {}
    for part, orig in pairs(ArmOriginals) do
        pcall(function()
            part.Material = orig.Material
            part.Color = orig.Color
            part.BrickColor = orig.BrickColor
            if orig.TextureID ~= nil then
                pcall(function() part.TextureID = orig.TextureID end)
            end
            if orig.SpecialMesh and orig.SpecialMeshTexture then
                pcall(function() orig.SpecialMesh.TextureId = orig.SpecialMeshTexture end)
            end
            for _, r in ipairs(orig.Removables or {}) do
                pcall(function() if not r.Instance.Parent then r.Instance.Parent = r.Parent end end)
            end
        end)
    end
    ArmOriginals = {}
end

function ToolModifier:Apply()
    if self.Enabled then
        ApplyToEquippedTool(self)
        ApplyToGameTargets(self)
    end
    if self.ArmEnabled then
        ApplyToArmTargets(self)
    end
end

return ToolModifier
