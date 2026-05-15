local CustomChams = {}

CustomChams.Enabled = false
CustomChams.Color = Color3.fromRGB(255, 0, 255)
CustomChams.Transparency = 0.3
CustomChams.AlwaysOnTop = true
CustomChams.ImageId = ""
CustomChams.SpritesheetCols = 1
CustomChams.SpritesheetRows = 1
CustomChams.SpritesheetFPS = 10
CustomChams.TeamCheck = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ActiveChams = {}
local RenderConn = nil
local PlayerConns = {}
local FrameCounter = 0
local CurrentFrame = 0

local FACES = {
    Enum.NormalId.Front,
    Enum.NormalId.Back,
    Enum.NormalId.Left,
    Enum.NormalId.Right,
    Enum.NormalId.Top,
    Enum.NormalId.Bottom,
}

local function CreatePartChams(part)
    local guis = {}
    for _, face in ipairs(FACES) do
        local gui = Instance.new("SurfaceGui")
        gui.Name = "_CustomCham"
        gui.Face = face
        gui.Adornee = part
        gui.AlwaysOnTop = CustomChams.AlwaysOnTop
        gui.LightInfluence = 0
        gui.Brightness = 1
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50

        local img = Instance.new("ImageLabel")
        img.Name = "Img"
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.BorderSizePixel = 0
        img.ImageColor3 = CustomChams.Color
        img.ImageTransparency = CustomChams.Transparency
        img.ScaleType = Enum.ScaleType.Stretch

        if CustomChams.ImageId ~= "" then
            img.Image = CustomChams.ImageId
        else
            img.Image = ""
            img.BackgroundColor3 = CustomChams.Color
            img.BackgroundTransparency = CustomChams.Transparency
        end

        img.Parent = gui
        gui.Parent = game:GetService("CoreGui")
        table.insert(guis, gui)
    end
    return guis
end

local function RemovePlayerChams(player)
    if ActiveChams[player] then
        for _, guiList in pairs(ActiveChams[player]) do
            for _, gui in pairs(guiList) do
                pcall(function() gui:Destroy() end)
            end
        end
        ActiveChams[player] = nil
    end
    if PlayerConns[player] then
        for _, conn in pairs(PlayerConns[player]) do
            pcall(function() conn:Disconnect() end)
        end
        PlayerConns[player] = nil
    end
end

local function ApplyPlayerChams(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end

    if not ActiveChams[player] then
        ActiveChams[player] = {}
    end

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Transparency < 1 and not ActiveChams[player][part] then
            ActiveChams[player][part] = CreatePartChams(part)
        end
    end
end

local function UpdateAllChams()
    local totalFrames = CustomChams.SpritesheetCols * CustomChams.SpritesheetRows
    local hasImage = CustomChams.ImageId ~= ""
    local isSpritesheet = totalFrames > 1 and hasImage

    if isSpritesheet then
        FrameCounter = FrameCounter + 1
        local framesPerTick = 60 / math.max(CustomChams.SpritesheetFPS, 1)
        if FrameCounter >= framesPerTick then
            FrameCounter = 0
            CurrentFrame = (CurrentFrame + 1) % totalFrames
        end
    end

    for player, parts in pairs(ActiveChams) do
        if not player.Parent or not player.Character then
            RemovePlayerChams(player)
        else
            for part, guis in pairs(parts) do
                if not part.Parent then
                    for _, gui in pairs(guis) do
                        pcall(function() gui:Destroy() end)
                    end
                    parts[part] = nil
                else
                    for _, gui in pairs(guis) do
                        pcall(function()
                            gui.AlwaysOnTop = CustomChams.AlwaysOnTop
                            local img = gui:FindFirstChild("Img")
                            if img then
                                img.ImageColor3 = CustomChams.Color
                                img.ImageTransparency = CustomChams.Transparency

                                if hasImage then
                                    img.Image = CustomChams.ImageId
                                    img.BackgroundTransparency = 1

                                    if isSpritesheet then
                                        local col = CurrentFrame % CustomChams.SpritesheetCols
                                        local row = math.floor(CurrentFrame / CustomChams.SpritesheetCols)
                                        local frameW = 1 / CustomChams.SpritesheetCols
                                        local frameH = 1 / CustomChams.SpritesheetRows
                                        img.ImageRectOffset = Vector2.new(col * (1024 * frameW), row * (1024 * frameH))
                                        img.ImageRectSize = Vector2.new(1024 * frameW, 1024 * frameH)
                                    else
                                        img.ImageRectOffset = Vector2.new(0, 0)
                                        img.ImageRectSize = Vector2.new(0, 0)
                                    end
                                else
                                    img.Image = ""
                                    img.BackgroundColor3 = CustomChams.Color
                                    img.BackgroundTransparency = CustomChams.Transparency
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end

function CustomChams:Start()
    if RenderConn then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ApplyPlayerChams(player)
            if not PlayerConns[player] then
                PlayerConns[player] = {}
            end
            table.insert(PlayerConns[player], player.CharacterAdded:Connect(function()
                RemovePlayerChams(player)
                task.wait(0.5)
                ApplyPlayerChams(player)
            end))
        end
    end

    table.insert(PlayerConns, {
        Players.PlayerAdded:Connect(function(player)
            task.wait(1)
            if not self.Enabled then return end
            ApplyPlayerChams(player)
            if not PlayerConns[player] then
                PlayerConns[player] = {}
            end
            table.insert(PlayerConns[player], player.CharacterAdded:Connect(function()
                RemovePlayerChams(player)
                task.wait(0.5)
                if self.Enabled then
                    ApplyPlayerChams(player)
                end
            end))
        end),
        Players.PlayerRemoving:Connect(function(player)
            RemovePlayerChams(player)
        end),
    })

    RenderConn = RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not ActiveChams[player] then
                    ApplyPlayerChams(player)
                end
            end
        end
        UpdateAllChams()
    end)
end

function CustomChams:Stop()
    if RenderConn then
        RenderConn:Disconnect()
        RenderConn = nil
    end
    for player, _ in pairs(ActiveChams) do
        RemovePlayerChams(player)
    end
    ActiveChams = {}
    for key, conns in pairs(PlayerConns) do
        if type(conns) == "table" then
            for _, conn in pairs(conns) do
                pcall(function() conn:Disconnect() end)
            end
        end
    end
    PlayerConns = {}
end

function CustomChams:Unload()
    self.Enabled = false
    self:Stop()
end

return CustomChams
