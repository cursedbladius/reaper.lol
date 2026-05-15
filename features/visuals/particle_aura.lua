local ParticleAura = {}

ParticleAura.Enabled = false
ParticleAura.Color = Color3.fromRGB(133, 220, 255)
ParticleAura.Transparency = 0.2
ParticleAura.SelectedAura = "angel"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local particle_auras = {}
local particles = {}
local aura_connection = nil
local char_connection = nil

local R15_TO_R6 = {
    ["UpperTorso"] = "Torso",
    ["LowerTorso"] = "Torso",
    ["LeftUpperArm"] = "Left Arm",
    ["LeftLowerArm"] = "Left Arm",
    ["LeftHand"] = "Left Arm",
    ["RightUpperArm"] = "Right Arm",
    ["RightLowerArm"] = "Right Arm",
    ["RightHand"] = "Right Arm",
    ["LeftUpperLeg"] = "Left Leg",
    ["LeftLowerLeg"] = "Left Leg",
    ["LeftFoot"] = "Left Leg",
    ["RightUpperLeg"] = "Right Leg",
    ["RightLowerLeg"] = "Right Leg",
    ["RightFoot"] = "Right Leg",
}

local function IsR6(character)
    for _, child in pairs(character:GetChildren()) do
        if child.Name == "Torso" and child:IsA("BasePart") then
            return true
        end
    end
    return false
end

local function FindCharPart(character, name, r6)
    if r6 then
        local mapped = R15_TO_R6[name] or name
        for _, child in pairs(character:GetChildren()) do
            if child.Name == mapped and child:IsA("BasePart") then
                return child
            end
        end
    else
        for _, child in pairs(character:GetChildren()) do
            if child.Name == name and child:IsA("BasePart") then
                return child
            end
        end
    end
    return nil
end

local function LoadAuras()
    local assets = {
        ["starlight"] = "rbxassetid://134645216613107",
        ["heavenly"] = "rbxassetid://139300897520961",
        ["ribbon"] = "rbxassetid://132069507632161",
        ["sakura"] = "rbxassetid://81755778619404",
        ["angel"] = "rbxassetid://97658130917593",
        ["wind"] = "rbxassetid://80694081850877",
        ["flow"] = "rbxassetid://119913533725648",
        ["star"] = "rbxassetid://73754563740680",
    }
    for name, id in pairs(assets) do
        pcall(function()
            particle_auras[name] = game:GetObjects(id)[1]
        end)
    end
end

local function ApplyColorToModel(model, color)
    if not model then return end
    local colorSeq = ColorSequence.new(color)
    pcall(function()
        for _, desc in pairs(model:GetDescendants()) do
            pcall(function()
                if desc.ClassName == "PointLight" then
                    desc.Color = color
                elseif desc.ClassName == "ParticleEmitter" or desc.ClassName == "Beam" or desc.ClassName == "Trail" then
                    desc.Color = colorSeq
                end
            end)
        end
    end)
end

local function ClearParticles()
    for i = #particles, 1, -1 do
        pcall(function() particles[i]:Destroy() end)
        particles[i] = nil
    end
    particles = {}
end

local function ApplyAura()
    ClearParticles()

    local character = LocalPlayer and LocalPlayer.Character
    if not character then return end

    local hrp = nil
    pcall(function()
        for _, child in pairs(character:GetChildren()) do
            if child.Name == "HumanoidRootPart" then
                hrp = child
                break
            end
        end
    end)
    if not hrp then return end

    local auraModel = particle_auras[ParticleAura.SelectedAura]
    if not auraModel then return end

    local r6 = IsR6(character)

    pcall(function()
        local cloned = auraModel:Clone()
        local children = cloned:GetChildren()

        for _, part in pairs(children) do
            local localPart = FindCharPart(character, part.Name, r6)

            if localPart then
                for _, child in pairs(part:GetChildren()) do
                    pcall(function()
                        child.Name = "\0\0"
                        child.Parent = localPart
                        table.insert(particles, child)
                    end)
                end
            end
            pcall(function() part:Destroy() end)
        end

        pcall(function() cloned:Destroy() end)
    end)
end

function ParticleAura:SetColor(color)
    self.Color = color
    local colorSeq = ColorSequence.new(color)

    for name, model in pairs(particle_auras) do
        if model and typeof(model) ~= "string" then
            ApplyColorToModel(model, color)
        end
    end

    for _, part in pairs(particles) do
        pcall(function()
            if part.ClassName == "PointLight" then
                part.Color = color
            elseif part.ClassName == "ParticleEmitter" or part.ClassName == "Beam" or part.ClassName == "Trail" then
                part.Color = colorSeq
            end
            for _, desc in pairs(part:GetDescendants()) do
                pcall(function()
                    if desc.ClassName == "PointLight" then
                        desc.Color = color
                    elseif desc.ClassName == "ParticleEmitter" or desc.ClassName == "Beam" or desc.ClassName == "Trail" then
                        desc.Color = colorSeq
                    end
                end)
            end
        end)
    end
end

function ParticleAura:SetAura(name)
    self.SelectedAura = name
    if self.Enabled then
        ApplyAura()
    end
end

function ParticleAura:Toggle(enabled)
    self.Enabled = enabled

    ClearParticles()

    if char_connection then
        pcall(function() char_connection:Disconnect() end)
        char_connection = nil
    end

    if enabled then
        ApplyAura()
        char_connection = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if self.Enabled then
                ApplyAura()
            end
        end)
    end
end

function ParticleAura:GetAuraNames()
    return {"starlight", "heavenly", "ribbon", "sakura", "angel", "wind", "flow", "star"}
end

function ParticleAura:Unload()
    self.Enabled = false
    ClearParticles()
    if char_connection then
        pcall(function() char_connection:Disconnect() end)
        char_connection = nil
    end
    for name, model in pairs(particle_auras) do
        pcall(function()
            if model and typeof(model) ~= "string" then
                model:Destroy()
            end
        end)
    end
    particle_auras = {}
end

LoadAuras()
pcall(function()
    ParticleAura:SetColor(ParticleAura.Color)
end)

return ParticleAura
