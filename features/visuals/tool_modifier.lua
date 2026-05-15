local ToolModifier = {}

ToolModifier.Enabled = false
ToolModifier.Color = Color3.fromRGB(255, 0, 0)
ToolModifier.Alpha = 0.4
ToolModifier.Material = "Highlight"
ToolModifier.OutlineColor = Color3.fromRGB(255, 255, 255)
ToolModifier.OutlineEnabled = true

local CurrentTool = nil
local ToolHighlight = nil
local ToolPartData = {}

local GameAdapter = nil
local GameHighlights = {}
local GameOriginals = {}

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
        ToolHighlight.FillColor = self.Color
        ToolHighlight.FillTransparency = self.Alpha
        ToolHighlight.OutlineColor = self.OutlineColor
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
        for _, p in pairs(target:GetDescendants()) do
            if p:IsA("BasePart") then
                table.insert(allParts, p)
                if not GameOriginals[p] then
                    GameOriginals[p] = {
                        Material = p.Material,
                        Color = p.Color,
                        BrickColor = p.BrickColor,
                    }
                end
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
        end
        for _, target in pairs(targets) do
            for _, child in pairs(target:GetChildren()) do
                pcall(function()
                    if not child:FindFirstChild("_ToolModHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "_ToolModHighlight"
                        hl.Adornee = child
                        hl.FillColor = self.Color
                        hl.FillTransparency = self.Alpha
                        hl.OutlineColor = self.OutlineColor
                        hl.OutlineTransparency = self.OutlineEnabled and 0 or 1
                        hl.Parent = child
                        table.insert(GameHighlights, hl)
                    else
                        local hl = child:FindFirstChild("_ToolModHighlight")
                        hl.FillColor = self.Color
                        hl.FillTransparency = self.Alpha
                        hl.OutlineColor = self.OutlineColor
                        hl.OutlineTransparency = self.OutlineEnabled and 0 or 1
                    end
                end)
            end
        end
    else
        for _, hl in pairs(GameHighlights) do
            pcall(function() hl:Destroy() end)
        end
        GameHighlights = {}

        local mat = self.Material == "ForceField" and Enum.Material.ForceField or Enum.Material.Neon
        for _, p in pairs(allParts) do
            pcall(function()
                p.Material = mat
                if self.Material == "ForceField" then
                    p.BrickColor = BrickColor.new(self.Color)
                else
                    p.Color = self.Color
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

function ToolModifier:Apply()
    if not self.Enabled then return end
    ApplyToEquippedTool(self)
    ApplyToGameTargets(self)
end

return ToolModifier
