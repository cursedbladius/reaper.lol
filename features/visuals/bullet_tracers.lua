local BulletTracers = {}

BulletTracers.Enabled = false
BulletTracers.Color = Color3.fromRGB(255, 0, 0)
BulletTracers.Width = 0.15
BulletTracers.Lifetime = 0.5
BulletTracers.TextureId = ""
BulletTracers.TextureSpeed = 1
BulletTracers.TextureLength = 1
BulletTracers.FadeTime = 0.3

local TracerFolder = nil
local Connections = {}
local GameAdapter = nil

local function GetTracerFolder()
    if TracerFolder and TracerFolder.Parent then return TracerFolder end
    TracerFolder = Instance.new("Folder")
    TracerFolder.Name = "_BulletTracers"
    TracerFolder.Parent = workspace.Terrain
    return TracerFolder
end

function BulletTracers:CreateTracer(origin, endpoint)
    if not self.Enabled then return end

    local folder = GetTracerFolder()

    local a0 = Instance.new("Attachment")
    a0.WorldPosition = origin
    a0.Parent = workspace.Terrain

    local a1 = Instance.new("Attachment")
    a1.WorldPosition = endpoint
    a1.Parent = workspace.Terrain

    local beam = Instance.new("Beam")
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Color = ColorSequence.new(self.Color)
    beam.Width0 = self.Width
    beam.Width1 = self.Width
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Segments = 1

    if self.TextureId ~= "" then
        beam.Texture = self.TextureId
        beam.TextureSpeed = self.TextureSpeed
        beam.TextureLength = self.TextureLength
        beam.TextureMode = Enum.TextureMode.Stretch
    end

    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0),
    })
    beam.Parent = folder

    local fadeTime = self.FadeTime
    local lifetime = self.Lifetime

    task.delay(lifetime - fadeTime, function()
        if not beam.Parent then return end
        local steps = 10
        for i = 1, steps do
            if not beam.Parent then break end
            local alpha = i / steps
            beam.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, alpha),
                NumberSequenceKeypoint.new(1, alpha),
            })
            task.wait(fadeTime / steps)
        end
        pcall(function() beam:Destroy() end)
        pcall(function() a0:Destroy() end)
        pcall(function() a1:Destroy() end)
    end)
end

function BulletTracers:Initialize(gameAdapter)
    GameAdapter = gameAdapter
end

function BulletTracers:StartHook()
    if #Connections > 0 then return end

    local LocalPlayer = game:GetService("Players").LocalPlayer

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Raycast" and self == workspace and BulletTracers.Enabled then
            local args = {...}
            local origin = args[1]
            local direction = args[2]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                local result = oldNamecall(self, ...)
                local endpoint = result and result.Position or (origin + direction)
                task.spawn(function()
                    BulletTracers:CreateTracer(origin, endpoint)
                end)
                return result
            end
        end
        return oldNamecall(self, ...)
    end))

    table.insert(Connections, {Type = "hook", Original = oldNamecall})
end

function BulletTracers:Unload()
    self.Enabled = false
    if TracerFolder then
        pcall(function() TracerFolder:Destroy() end)
        TracerFolder = nil
    end
end

return BulletTracers
