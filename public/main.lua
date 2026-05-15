local LoadStart = os.clock()

local Library = loadstring(game:HttpGet("https://reaper-lol.pages.dev/ui/library.lua"))()

-- Load ESP Module
local ESP = loadstring(game:HttpGet("https://reaper-lol.pages.dev/features/esp.lua"))()
ESP:Initialize()

--
local Window = Library:Window({
    Name = "reaper.lol",
    FadeSpeed = 0.25
})

local Watermark = Library:Watermark("reaper.lol ~ ".. os.date("%b %d %Y") .. " ~ ".. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
local KeybindList = Library:KeybindList()

Watermark:SetVisibility(true)
KeybindList:SetVisibility(false)

-- Tabs
local CombatTab = Window:Page({Name = "Combat", Columns = 2, Subtabs = false})
local VisualsTab = Window:Page({Name = "Visuals", Columns = 2, Subtabs = false})
local MovementTab = Window:Page({Name = "Movement", Columns = 2, Subtabs = false})
local MiscTab = Window:Page({Name = "Misc", Columns = 2, Subtabs = false})
local PlayersTab = Window:Page({Name = "Players", Columns = 2, Subtabs = false})
local SettingsTab = Library:CreateSettingsPage(Window, Watermark, KeybindList)

-- Combat Tab   
local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = 1})
local SilentAimSection = CombatTab:Section({Name = "Silent Aim", Side = 1})
local TargetSection = CombatTab:Section({Name = "Target", Side = 2})
local WeaponSection = CombatTab:Section({Name = "Weapon", Side = 2})

-- Aimbot Toggles & Sliders
AimbotSection:Toggle({Name = "Enabled", Flag = "AimbotEnabled", Default = false}):Keybind({Name = "Aimbot Key", Flag = "AimbotKey", Default = Enum.KeyCode.Q, Mode = "Toggle"})

AimbotSection:Toggle({Name = "Auto Aim", Flag = "AutoAim", Default = false})

AimbotSection:Toggle({Name = "Smooth Aim", Flag = "SmoothAim", Default = false})

AimbotSection:Slider({Name = "Smoothness", Min = 0, Max = 100, Default = 50, Suffix = "%", Decimals = 1, Compact = true, Flag = "AimbotSmoothness"})

AimbotSection:Toggle({Name = "Show FOV", Flag = "ShowFOV", Default = true, Callback = function(Value)
    --[[Show FOV:", Value)
end}):Colorpicker({Name = "FOV Color", Flag = "FOVColor", Default = Color3.fromRGB(255, 100, 100), Callback = function(Value)
    --[[FOV Color:", Value)
end})

AimbotSection:Slider({Name = "FOV Size", Min = 0, Max = 500, Default = 150, Decimals = 0, Flag = "FOVSize", Callback = function(Value)
    --[[FOV Size:", Value)
end})

AimbotSection:Toggle({Name = "Prediction", Flag = "AimbotPrediction", Default = false, Callback = function(Value)
    --[[Prediction:", Value)
end})

AimbotSection:Slider({Name = "Prediction X", Min = 0, Max = 1, Default = 0.15, Decimals = 2, Flag = "PredictionX", Callback = function(Value)
    --[[Prediction X:", Value)
end})

AimbotSection:Slider({Name = "Prediction Y", Min = 0, Max = 1, Default = 0.1, Decimals = 2, Flag = "PredictionY", Callback = function(Value)
    --[[Prediction Y:", Value)
end})

AimbotSection:Toggle({Name = "Wall Check", Flag = "WallCheck", Default = true, Callback = function(Value)
    --[[Wall Check:", Value)
end})

AimbotSection:Toggle({Name = "Visible Check", Flag = "VisibleCheck", Default = true, Callback = function(Value)
    --[[Visible Check:", Value)
end})

AimbotSection:Toggle({Name = "Team Check", Flag = "TeamCheck", Default = true, Callback = function(Value)
    --[[Team Check:", Value)
end})

AimbotSection:Toggle({Name = "Knocked Check", Flag = "KnockedCheck", Default = true, Callback = function(Value)
    --[[Knocked Check:", Value)
end})

AimbotSection:Divider()

AimbotSection:Dropdown({Name = "Target Bone", Flag = "TargetBone", Default = "Head", Items = {"Head", "Neck", "Torso", "Pelvis", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Callback = function(Value)
    --[[Target Bone:", Value)
end})

AimbotSection:Dropdown({Name = "Priority", Flag = "Priority", Default = "Distance", Items = {"Distance", "Health", "Crosshair"}, Callback = function(Value)
    --[[Priority:", Value)
end})

-- Silent Aim Section
SilentAimSection:Toggle({Name = "Enabled", Flag = "SilentAimEnabled", Default = false, Callback = function(Value)
    --[[Silent Aim Enabled:", Value)
end})

SilentAimSection:Toggle({Name = "Auto Fire", Flag = "AutoFire", Default = false, Callback = function(Value)
    --[[Auto Fire:", Value)
end})

SilentAimSection:Slider({Name = "Hit Chance", Min = 0, Max = 100, Default = 100, Suffix = "%", Decimals = 1, Compact = true, Flag = "HitChance", Callback = function(Value)
    --[[Hit Chance:", Value)
end})

SilentAimSection:Toggle({Name = "Magnet", Flag = "SilentMagnet", Default = false, Callback = function(Value)
    --[[Magnet:", Value)
end})

SilentAimSection:Slider({Name = "Magnet Strength", Min = 0, Max = 100, Default = 50, Suffix = "%", Decimals = 1, Compact = true, Flag = "MagnetStrength", Callback = function(Value)
    --[[Magnet Strength:", Value)
end})

SilentAimSection:Toggle({Name = "Override Shots", Flag = "OverrideShots", Default = false, Callback = function(Value)
    --[[Override Shots:", Value)
end})

SilentAimSection:Slider({Name = "Override %", Min = 0, Max = 100, Default = 25, Suffix = "%", Decimals = 1, Compact = true, Flag = "OverridePercent", Callback = function(Value)
    --[[Override %:", Value)
end})

-- Target Section
TargetSection:Toggle({Name = "Highlight Target", Flag = "HighlightTarget", Default = false, Callback = function(Value)
    --[[Highlight Target:", Value)
end}):Colorpicker({Name = "Highlight Color", Flag = "HighlightTargetColor", Default = Color3.fromRGB(255, 0, 0), Callback = function(Value)
    --[[Highlight Color:", Value)
end})

TargetSection:Toggle({Name = "Tracer", Flag = "TargetTracer", Default = false, Callback = function(Value)
    --[[Tracer:", Value)
end})

TargetSection:Slider({Name = "Max Target Distance", Min = 0, Max = 2000, Default = 1000, Decimals = 0, Flag = "MaxTargetDistance", Callback = function(Value)
    --[[Max Target Distance:", Value)
end})

TargetSection:Toggle({Name = "Lock Closest", Flag = "LockClosest", Default = true, Callback = function(Value)
    --[[Lock Closest:", Value)
end})

TargetSection:Toggle({Name = "Auto Switch", Flag = "AutoSwitch", Default = false, Callback = function(Value)
    --[[Auto Switch:", Value)
end})

TargetSection:Dropdown({Name = "Switch Mode", Flag = "SwitchMode", Default = "On Kill", Items = {"On Kill", "On Damage", "Time Based", "Manual"}, Callback = function(Value)
    --[[Switch Mode:", Value)
end})

-- Weapon Section
WeaponSection:Toggle({Name = "No Recoil", Flag = "NoRecoil", Default = false, Callback = function(Value)
    --[[No Recoil:", Value)
end})

WeaponSection:Slider({Name = "Recoil Control", Min = 0, Max = 100, Default = 100, Suffix = "%", Decimals = 1, Compact = true, Flag = "RecoilControl", Callback = function(Value)
    --[[Recoil Control:", Value)
end})

WeaponSection:Toggle({Name = "No Spread", Flag = "NoSpread", Default = false, Callback = function(Value)
    --[[No Spread:", Value)
end})

WeaponSection:Toggle({Name = "Instant Hit", Flag = "InstantHit", Default = false, Callback = function(Value)
    --[[Instant Hit:", Value)
end})

WeaponSection:Toggle({Name = "Rapid Fire", Flag = "RapidFire", Default = false, Callback = function(Value)
    --[[Rapid Fire:", Value)
end})

WeaponSection:Slider({Name = "Fire Rate", Min = 0, Max = 10, Default = 1, Decimals = 1, Flag = "FireRate", Callback = function(Value)
    --[[Fire Rate:", Value)
end})

WeaponSection:Toggle({Name = "Infinite Ammo", Flag = "InfiniteAmmo", Default = false, Callback = function(Value)
    --[[Infinite Ammo:", Value)
end})

WeaponSection:Toggle({Name = "Auto Reload", Flag = "AutoReload", Default = false, Callback = function(Value)
    --[[Auto Reload:", Value)
end})

WeaponSection:Toggle({Name = "Instant Reload", Flag = "InstantReload", Default = false, Callback = function(Value)
    --[[Instant Reload:", Value)
end})

WeaponSection:Slider({Name = "Reload Speed", Min = 0, Max = 5, Default = 1, Decimals = 2, Flag = "ReloadSpeed", Callback = function(Value)
    --[[Reload Speed:", Value)
end})

WeaponSection:Toggle({Name = "Full Auto", Flag = "FullAuto", Default = false, Callback = function(Value)
    --[[Full Auto:", Value)
end})

-- Visuals Tab
local ESPSection = VisualsTab:Section({Name = "ESP", Side = 1})
local VisualEffectsSection = VisualsTab:Section({Name = "Visual Effects", Side = 2})

-- ESP Section with Master Switch
ESPSection:Toggle({Name = "Enabled", Flag = "ESPEnabled", Default = false, Callback = function(Value)
    ESP:Toggle(Value)
end})

ESPSection:Toggle({Name = "Boxes", Flag = "ESPBoxes", Default = true, Callback = function(Value)
    ESP:SetSetting("Box", Value)
end})

ESPSection:Toggle({Name = "Health Bar", Flag = "ESPHealthBar", Default = true, Callback = function(Value)
    ESP:SetSetting("HealthBar", Value)
end})

ESPSection:Toggle({Name = "Names", Flag = "ESPNames", Default = true, Callback = function(Value)
    ESP:SetSetting("Name", Value)
end})

ESPSection:Slider({Name = "Max Distance", Min = 100, Max = 5000, Default = 2000, Decimals = 0, Flag = "MaxESPDistance", Callback = function(Value)
    ESP:SetSetting("MaxDistance", Value)
end})

ESPSection:Toggle({Name = "Team Check", Flag = "ESPTeamCheck", Default = true, Callback = function(Value)
    ESP:SetSetting("TeamCheck", Value)
end})

-- Visual Effects Section
VisualEffectsSection:Toggle({Name = "Remove Fog", Flag = "RemoveFog", Default = false})

VisualEffectsSection:Toggle({Name = "Full Bright", Flag = "FullBright", Default = false})

VisualEffectsSection:Slider({Name = "Brightness", Min = 0, Max = 10, Default = 1, Decimals = 1, Flag = "Brightness"})

VisualEffectsSection:Toggle({Name = "Field of View", Flag = "FOVChanger", Default = false})

VisualEffectsSection:Slider({Name = "FOV", Min = 30, Max = 150, Default = 70, Decimals = 0, Flag = "FOVValue"})

-- Movement Tab
local WalkSection = MovementTab:Section({Name = "Walk", Side = 1})
local FlySection = MovementTab:Section({Name = "Fly", Side = 1})
local JumpSection = MovementTab:Section({Name = "Jump", Side = 2})
local SpeedSection = MovementTab:Section({Name = "Speed", Side = 2})

-- Walk Section
WalkSection:Toggle({Name = "Speed Enabled", Flag = "SpeedEnabled", Default = false, Callback = function(Value)
    --[[Speed Enabled:", Value)
end}):Keybind({Name = "Speed Key", Flag = "SpeedKey", Default = Enum.KeyCode.LeftShift, Mode = "Hold", Callback = function(Value)
    --[[Speed Key:", Value)
end})

WalkSection:Slider({Name = "Speed", Min = 0, Max = 500, Default = 50, Decimals = 0, Flag = "WalkSpeed", Callback = function(Value)
    --[[Speed:", Value)
end})

WalkSection:Toggle({Name = "Auto Sprint", Flag = "AutoSprint", Default = false, Callback = function(Value)
    --[[Auto Sprint:", Value)
end})

WalkSection:Toggle({Name = "No Slowdown", Flag = "NoSlowdown", Default = false, Callback = function(Value)
    --[[No Slowdown:", Value)
end})

WalkSection:Toggle({Name = "No Clip", Flag = "NoClip", Default = false, Callback = function(Value)
    --[[No Clip:", Value)
end}):Keybind({Name = "NoClip Key", Flag = "NoClipKey", Default = Enum.KeyCode.V, Mode = "Toggle", Callback = function(Value)
    --[[NoClip Key:", Value)
end})

WalkSection:Toggle({Name = "Infinite Stamina", Flag = "InfiniteStamina", Default = false, Callback = function(Value)
    --[[Infinite Stamina:", Value)
end})

WalkSection:Toggle({Name = "Anti Slip", Flag = "AntiSlip", Default = false, Callback = function(Value)
    --[[Anti Slip:", Value)
end})

WalkSection:Toggle({Name = "Walk on Water", Flag = "WalkOnWater", Default = false, Callback = function(Value)
    --[[Walk on Water:", Value)
end})

WalkSection:Toggle({Name = "Auto Strafe", Flag = "AutoStrafe", Default = false, Callback = function(Value)
    --[[Auto Strafe:", Value)
end})

-- Fly Section
FlySection:Toggle({Name = "Fly Enabled", Flag = "FlyEnabled", Default = false, Callback = function(Value)
    --[[Fly Enabled:", Value)
end}):Keybind({Name = "Fly Key", Flag = "FlyKey", Default = Enum.KeyCode.F, Mode = "Toggle", Callback = function(Value)
    --[[Fly Key:", Value)
end})

FlySection:Slider({Name = "Fly Speed", Min = 0, Max = 200, Default = 50, Decimals = 0, Flag = "FlySpeed", Callback = function(Value)
    --[[Fly Speed:", Value)
end})

FlySection:Toggle({Name = "Vertical Fly", Flag = "VerticalFly", Default = true, Callback = function(Value)
    --[[Vertical Fly:", Value)
end})

FlySection:Toggle({Name = "Hover", Flag = "Hover", Default = false, Callback = function(Value)
    --[[Hover:", Value)
end})

FlySection:Slider({Name = "Hover Height", Min = 0, Max = 1000, Default = 100, Decimals = 0, Flag = "HoverHeight", Callback = function(Value)
    --[[Hover Height:", Value)
end})

FlySection:Toggle({Name = "Noclip Fly", Flag = "NoclipFly", Default = true, Callback = function(Value)
    --[[Noclip Fly:", Value)
end})

-- Jump Section
JumpSection:Toggle({Name = "Infinite Jump", Flag = "InfiniteJump", Default = false, Callback = function(Value)
    --[[Infinite Jump:", Value)
end})

JumpSection:Toggle({Name = "Super Jump", Flag = "SuperJump", Default = false, Callback = function(Value)
    --[[Super Jump:", Value)
end})

JumpSection:Slider({Name = "Jump Power", Min = 0, Max = 500, Default = 50, Decimals = 0, Flag = "JumpPower", Callback = function(Value)
    --[[Jump Power:", Value)
end})

JumpSection:Toggle({Name = "Low Gravity", Flag = "LowGravity", Default = false, Callback = function(Value)
    --[[Low Gravity:", Value)
end})

JumpSection:Slider({Name = "Gravity", Min = 0, Max = 196, Default = 196, Decimals = 0, Flag = "Gravity", Callback = function(Value)
    --[[Gravity:", Value)
end})

JumpSection:Toggle({Name = "Bunny Hop", Flag = "BunnyHop", Default = false, Callback = function(Value)
    --[[Bunny Hop:", Value)
end})

JumpSection:Slider({Name = "Bhop Speed", Min = 0, Max = 100, Default = 20, Decimals = 0, Flag = "BhopSpeed", Callback = function(Value)
    --[[Bhop Speed:", Value)
end})

JumpSection:Toggle({Name = "Auto Jump", Flag = "AutoJump", Default = false, Callback = function(Value)
    --[[Auto Jump:", Value)
end})

JumpSection:Toggle({Name = "Edge Jump", Flag = "EdgeJump", Default = false, Callback = function(Value)
    --[[Edge Jump:", Value)
end})

JumpSection:Toggle({Name = "No Fall Damage", Flag = "NoFallDamage", Default = false, Callback = function(Value)
    --[[No Fall Damage:", Value)
end})

-- Speed Section
SpeedSection:Toggle({Name = "Velocity Fly", Flag = "VelocityFly", Default = false, Callback = function(Value)
    --[[Velocity Fly:", Value)
end})

SpeedSection:Toggle({Name = "CFrame Speed", Flag = "CFrameSpeed", Default = false, Callback = function(Value)
    --[[CFrame Speed:", Value)
end})

SpeedSection:Slider({Name = "CFrame Multiplier", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "CFrameMultiplier", Callback = function(Value)
    --[[CFrame Multiplier:", Value)
end})

SpeedSection:Toggle({Name = "TP Speed", Flag = "TPSpeed", Default = false, Callback = function(Value)
    --[[TP Speed:", Value)
end})

SpeedSection:Slider({Name = "TP Distance", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "TPDistance", Callback = function(Value)
    --[[TP Distance:", Value)
end})

-- Misc Tab
local AntiSection = MiscTab:Section({Name = "Anti-Aim", Side = 1})
local ExploitsSection = MiscTab:Section({Name = "Exploits", Side = 1})
local WorldSection = MiscTab:Section({Name = "World", Side = 2})
local AutomationSection = MiscTab:Section({Name = "Automation", Side = 2})

-- Anti-Aim Section
AntiSection:Toggle({Name = "Enabled", Flag = "AntiAimEnabled", Default = false, Callback = function(Value)
    --[[Anti-Aim Enabled:", Value)
end})

AntiSection:Toggle({Name = "Spin Bot", Flag = "SpinBot", Default = false, Callback = function(Value)
    --[[Spin Bot:", Value)
end})

AntiSection:Slider({Name = "Spin Speed", Min = 0, Max = 1000, Default = 100, Decimals = 0, Flag = "SpinSpeed", Callback = function(Value)
    --[[Spin Speed:", Value)
end})

AntiSection:Toggle({Name = "Jitter", Flag = "Jitter", Default = false, Callback = function(Value)
    --[[Jitter:", Value)
end})

AntiSection:Slider({Name = "Jitter Range", Min = 0, Max = 180, Default = 90, Decimals = 0, Flag = "JitterRange", Callback = function(Value)
    --[[Jitter Range:", Value)
end})

AntiSection:Toggle({Name = "Desync", Flag = "Desync", Default = false, Callback = function(Value)
    --[[Desync:", Value)
end})

AntiSection:Toggle({Name = "Backtrack", Flag = "Backtrack", Default = false, Callback = function(Value)
    --[[Backtrack:", Value)
end})

AntiSection:Slider({Name = "Backtrack Ticks", Min = 0, Max = 20, Default = 5, Decimals = 0, Flag = "BacktrackTicks", Callback = function(Value)
    --[[Backtrack Ticks:", Value)
end})

AntiSection:Toggle({Name = "Fake Lag", Flag = "FakeLag", Default = false, Callback = function(Value)
    --[[Fake Lag:", Value)
end})

AntiSection:Slider({Name = "Lag Ticks", Min = 0, Max = 20, Default = 5, Decimals = 0, Flag = "LagTicks", Callback = function(Value)
    --[[Lag Ticks:", Value)
end})

AntiSection:Toggle({Name = "Anti-Aim Facing", Flag = "AntiAimFacing", Default = false, Callback = function(Value)
    --[[Anti-Aim Facing:", Value)
end})

AntiSection:Dropdown({Name = "Facing Mode", Flag = "FacingMode", Default = "Away", Items = {"Away", "Towards", "Random", "Spin"}, Callback = function(Value)
    --[[Facing Mode:", Value)
end})

-- Exploits Section
ExploitsSection:Toggle({Name = "God Mode", Flag = "GodMode", Default = false, Callback = function(Value)
    --[[God Mode:", Value)
end})

ExploitsSection:Toggle({Name = "Infinite Yield", Flag = "InfiniteYield", Default = false, Callback = function(Value)
    --[[Infinite Yield:", Value)
end})

ExploitsSection:Toggle({Name = "Admin Commands", Flag = "AdminCommands", Default = false, Callback = function(Value)
    --[[Admin Commands:", Value)
end})

ExploitsSection:Toggle({Name = "One Hit", Flag = "OneHit", Default = false, Callback = function(Value)
    --[[One Hit:", Value)
end})

ExploitsSection:Toggle({Name = "Kill Aura", Flag = "KillAura", Default = false, Callback = function(Value)
    --[[Kill Aura:", Value)
end})

ExploitsSection:Slider({Name = "Aura Range", Min = 0, Max = 50, Default = 10, Decimals = 1, Flag = "AuraRange", Callback = function(Value)
    --[[Aura Range:", Value)
end})

ExploitsSection:Toggle({Name = "Auto Parry", Flag = "AutoParry", Default = false, Callback = function(Value)
    --[[Auto Parry:", Value)
end})

ExploitsSection:Toggle({Name = "Auto Block", Flag = "AutoBlock", Default = false, Callback = function(Value)
    --[[Auto Block:", Value)
end})

ExploitsSection:Toggle({Name = "Reach", Flag = "Reach", Default = false, Callback = function(Value)
    --[[Reach:", Value)
end})

ExploitsSection:Slider({Name = "Reach Distance", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "ReachDistance", Callback = function(Value)
    --[[Reach Distance:", Value)
end})

ExploitsSection:Toggle({Name = "Hitbox Expander", Flag = "HitboxExpander", Default = false, Callback = function(Value)
    --[[Hitbox Expander:", Value)
end})

ExploitsSection:Slider({Name = "Hitbox Size", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "HitboxSize", Callback = function(Value)
    --[[Hitbox Size:", Value)
end})

ExploitsSection:Toggle({Name = "Auto Farm", Flag = "AutoFarm", Default = false, Callback = function(Value)
    --[[Auto Farm:", Value)
end})

-- World Section
WorldSection:Toggle({Name = "Item ESP", Flag = "ItemWorldESP", Default = false, Callback = function(Value)
    --[[Item ESP:", Value)
end})

WorldSection:Toggle({Name = "Vehicle Spawner", Flag = "VehicleSpawner", Default = false, Callback = function(Value)
    --[[Vehicle Spawner:", Value)
end})

WorldSection:Toggle({Name = "Teleport", Flag = "TeleportEnabled", Default = false, Callback = function(Value)
    --[[Teleport:", Value)
end})

WorldSection:Toggle({Name = "Click TP", Flag = "ClickTP", Default = false, Callback = function(Value)
    --[[Click TP:", Value)
end}):Keybind({Name = "Click TP Key", Flag = "ClickTPKey", Default = Enum.KeyCode.T, Mode = "Hold", Callback = function(Value)
    --[[Click TP Key:", Value)
end})

WorldSection:Toggle({Name = "Bring Items", Flag = "BringItems", Default = false, Callback = function(Value)
    --[[Bring Items:", Value)
end})

WorldSection:Slider({Name = "Bring Range", Min = 0, Max = 500, Default = 100, Decimals = 0, Flag = "BringRange", Callback = function(Value)
    --[[Bring Range:", Value)
end})

WorldSection:Toggle({Name = "Delete Doors", Flag = "DeleteDoors", Default = false, Callback = function(Value)
    --[[Delete Doors:", Value)
end})

WorldSection:Toggle({Name = "Unlock Doors", Flag = "UnlockDoors", Default = false, Callback = function(Value)
    --[[Unlock Doors:", Value)
end})

WorldSection:Toggle({Name = "Open All", Flag = "OpenAll", Default = false, Callback = function(Value)
    --[[Open All:", Value)
end})

-- Automation Section
AutomationSection:Toggle({Name = "Auto Loot", Flag = "AutoLoot", Default = false, Callback = function(Value)
    --[[Auto Loot:", Value)
end})

AutomationSection:Toggle({Name = "Auto Pickup", Flag = "AutoPickup", Default = false, Callback = function(Value)
    --[[Auto Pickup:", Value)
end})

AutomationSection:Slider({Name = "Pickup Range", Min = 0, Max = 100, Default = 20, Decimals = 0, Flag = "PickupRange", Callback = function(Value)
    --[[Pickup Range:", Value)
end})

AutomationSection:Toggle({Name = "Auto Equip", Flag = "AutoEquip", Default = false, Callback = function(Value)
    --[[Auto Equip:", Value)
end})

AutomationSection:Dropdown({Name = "Equip Priority", Flag = "EquipPriority", Default = "Best", Items = {"Best", "First", "Custom"}, Callback = function(Value)
    --[[Equip Priority:", Value)
end})

AutomationSection:Toggle({Name = "Auto Heal", Flag = "AutoHeal", Default = false, Callback = function(Value)
    --[[Auto Heal:", Value)
end})

AutomationSection:Slider({Name = "Heal Threshold", Min = 0, Max = 100, Default = 30, Suffix = "%", Decimals = 0, Flag = "HealThreshold", Callback = function(Value)
    --[[Heal Threshold:", Value)
end})

AutomationSection:Toggle({Name = "Auto Eat", Flag = "AutoEat", Default = false, Callback = function(Value)
    --[[Auto Eat:", Value)
end})

AutomationSection:Toggle({Name = "Auto Fish", Flag = "AutoFish", Default = false, Callback = function(Value)
    --[[Auto Fish:", Value)
end})

AutomationSection:Toggle({Name = "Auto Mine", Flag = "AutoMine", Default = false, Callback = function(Value)
    --[[Auto Mine:", Value)
end})

AutomationSection:Toggle({Name = "Auto Chop", Flag = "AutoChop", Default = false, Callback = function(Value)
    --[[Auto Chop:", Value)
end})

AutomationSection:Toggle({Name = "Auto Craft", Flag = "AutoCraft", Default = false, Callback = function(Value)
    --[[Auto Craft:", Value)
end})

AutomationSection:Toggle({Name = "Auto Build", Flag = "AutoBuild", Default = false, Callback = function(Value)
    --[[Auto Build:", Value)
end})

-- Players Tab
local TargetPlayerSection = PlayersTab:Section({Name = "Target Player", Side = 1})
local TrollingSection = PlayersTab:Section({Name = "Trolling", Side = 1})
local SpectateSection = PlayersTab:Section({Name = "Spectate", Side = 2})
local ServerSection = PlayersTab:Section({Name = "Server", Side = 2})

-- Target Player Section
TargetPlayerSection:Dropdown({Name = "Select Player", Flag = "SelectedPlayer", Default = "", Items = {}, Callback = function(Value)
    --[[Selected Player:", Value)
end})

TargetPlayerSection:Button({Name = "Refresh Players", Callback = function()
    --[[Refreshing players list...")
end})

TargetPlayerSection:Button({Name = "Teleport to Player", Callback = function()
    --[[Teleporting to selected player...")
end})

TargetPlayerSection:Button({Name = "Spectate", Callback = function()
    --[[Spectating selected player...")
end})

TargetPlayerSection:Button({Name = "Kill", Callback = function()
    --[[Killing selected player...")
end})

TargetPlayerSection:Toggle({Name = "Loop Kill", Flag = "LoopKill", Default = false, Callback = function(Value)
    --[[Loop Kill:", Value)
end})

TargetPlayerSection:Button({Name = "Bring", Callback = function()
    --[[Bringing selected player...")
end})

TargetPlayerSection:Toggle({Name = "Loop Bring", Flag = "LoopBring", Default = false, Callback = function(Value)
    --[[Loop Bring:", Value)
end})

TargetPlayerSection:Button({Name = "View Inventory", Callback = function()
    --[[Viewing inventory...")
end})

TargetPlayerSection:Button({Name = "Copy Outfit", Callback = function()
    --[[Copying outfit...")
end})

-- Trolling Section
TrollingSection:Toggle({Name = "Lag Player", Flag = "LagPlayer", Default = false, Callback = function(Value)
    --[[Lag Player:", Value)
end})

TrollingSection:Toggle({Name = "Crash Player", Flag = "CrashPlayer", Default = false, Callback = function(Value)
    --[[Crash Player:", Value)
end})

TrollingSection:Toggle({Name = "Freeze", Flag = "FreezePlayer", Default = false, Callback = function(Value)
    --[[Freeze:", Value)
end})

TrollingSection:Toggle({Name = "Blind", Flag = "BlindPlayer", Default = false, Callback = function(Value)
    --[[Blind:", Value)
end})

TrollingSection:Button({Name = "Fling", Callback = function()
    --[[Flinging player...")
end})

TrollingSection:Button({Name = "Launch", Callback = function()
    --[[Launching player...")
end})

TrollingSection:Button({Name = "Trap", Callback = function()
    --[[Trapping player...")
end})

TrollingSection:Button({Name = "Void", Callback = function()
    --[[Sending to void...")
end})

-- Spectate Section
SpectateSection:Toggle({Name = "Spectate", Flag = "SpectateEnabled", Default = false, Callback = function(Value)
    --[[Spectate:", Value)
end}):Keybind({Name = "Spectate Key", Flag = "SpectateKey", Default = Enum.KeyCode.P, Mode = "Toggle", Callback = function(Value)
    --[[Spectate Key:", Value)
end})

SpectateSection:Toggle({Name = "Freecam", Flag = "Freecam", Default = false, Callback = function(Value)
    --[[Freecam:", Value)
end}):Keybind({Name = "Freecam Key", Flag = "FreecamKey", Default = Enum.KeyCode.N, Mode = "Toggle", Callback = function(Value)
    --[[Freecam Key:", Value)
end})

SpectateSection:Slider({Name = "Freecam Speed", Min = 0, Max = 100, Default = 50, Decimals = 0, Flag = "FreecamSpeed", Callback = function(Value)
    --[[Freecam Speed:", Value)
end})

-- Server Section
ServerSection:Button({Name = "Rejoin", Callback = function()
    --[[Rejoining server...")
end})

ServerSection:Button({Name = "Server Hop", Callback = function()
    --[[Server hopping...")
end})

ServerSection:Button({Name = "Join Lowest", Callback = function()
    --[[Joining lowest player server...")
end})

ServerSection:Button({Name = "Copy Join Code", Callback = function()
    --[[Copying join code...")
end})

ServerSection:Button({Name = "Crash Server", Callback = function()
    --[[Crashing server...")
end})

-- Initialization
Library:Notification(string.format("reaper.lol loaded in %.4f seconds", os.clock() - LoadStart), 5, Library.Theme.Accent, {"rbxassetid://135757045959142", Color3.fromRGB(149, 255, 139)})

Library:Init()
