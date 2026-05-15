local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sametexe001/sametlibs/refs/heads/main/Thugsense/Library.lua"))()

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
AimbotSection:Toggle({Name = "Enabled", Flag = "AimbotEnabled", Default = false, Callback = function(Value)
    print("Aimbot Enabled:", Value)
end}):Keybind({Name = "Aimbot Key", Flag = "AimbotKey", Default = Enum.KeyCode.Q, Mode = "Toggle", Callback = function(Value)
    print("Aimbot Key:", Value)
end})

AimbotSection:Toggle({Name = "Auto Aim", Flag = "AutoAim", Default = false, Callback = function(Value)
    print("Auto Aim:", Value)
end})

AimbotSection:Toggle({Name = "Smooth Aim", Flag = "SmoothAim", Default = false, Callback = function(Value)
    print("Smooth Aim:", Value)
end})

AimbotSection:Slider({Name = "Smoothness", Min = 0, Max = 100, Default = 50, Suffix = "%", Decimals = 1, Compact = true, Flag = "AimbotSmoothness", Callback = function(Value)
    print("Smoothness:", Value)
end})

AimbotSection:Toggle({Name = "Show FOV", Flag = "ShowFOV", Default = true, Callback = function(Value)
    print("Show FOV:", Value)
end}):Colorpicker({Name = "FOV Color", Flag = "FOVColor", Default = Color3.fromRGB(255, 100, 100), Callback = function(Value)
    print("FOV Color:", Value)
end})

AimbotSection:Slider({Name = "FOV Size", Min = 0, Max = 500, Default = 150, Decimals = 0, Flag = "FOVSize", Callback = function(Value)
    print("FOV Size:", Value)
end})

AimbotSection:Toggle({Name = "Prediction", Flag = "AimbotPrediction", Default = false, Callback = function(Value)
    print("Prediction:", Value)
end})

AimbotSection:Slider({Name = "Prediction X", Min = 0, Max = 1, Default = 0.15, Decimals = 2, Flag = "PredictionX", Callback = function(Value)
    print("Prediction X:", Value)
end})

AimbotSection:Slider({Name = "Prediction Y", Min = 0, Max = 1, Default = 0.1, Decimals = 2, Flag = "PredictionY", Callback = function(Value)
    print("Prediction Y:", Value)
end})

AimbotSection:Toggle({Name = "Wall Check", Flag = "WallCheck", Default = true, Callback = function(Value)
    print("Wall Check:", Value)
end})

AimbotSection:Toggle({Name = "Visible Check", Flag = "VisibleCheck", Default = true, Callback = function(Value)
    print("Visible Check:", Value)
end})

AimbotSection:Toggle({Name = "Team Check", Flag = "TeamCheck", Default = true, Callback = function(Value)
    print("Team Check:", Value)
end})

AimbotSection:Toggle({Name = "Knocked Check", Flag = "KnockedCheck", Default = true, Callback = function(Value)
    print("Knocked Check:", Value)
end})

AimbotSection:Divider()

AimbotSection:Dropdown({Name = "Target Bone", Flag = "TargetBone", Default = "Head", Items = {"Head", "Neck", "Torso", "Pelvis", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Callback = function(Value)
    print("Target Bone:", Value)
end})

AimbotSection:Dropdown({Name = "Priority", Flag = "Priority", Default = "Distance", Items = {"Distance", "Health", "Crosshair"}, Callback = function(Value)
    print("Priority:", Value)
end})

-- Silent Aim Section
SilentAimSection:Toggle({Name = "Enabled", Flag = "SilentAimEnabled", Default = false, Callback = function(Value)
    print("Silent Aim Enabled:", Value)
end})

SilentAimSection:Toggle({Name = "Auto Fire", Flag = "AutoFire", Default = false, Callback = function(Value)
    print("Auto Fire:", Value)
end})

SilentAimSection:Slider({Name = "Hit Chance", Min = 0, Max = 100, Default = 100, Suffix = "%", Decimals = 1, Compact = true, Flag = "HitChance", Callback = function(Value)
    print("Hit Chance:", Value)
end})

SilentAimSection:Toggle({Name = "Magnet", Flag = "SilentMagnet", Default = false, Callback = function(Value)
    print("Magnet:", Value)
end})

SilentAimSection:Slider({Name = "Magnet Strength", Min = 0, Max = 100, Default = 50, Suffix = "%", Decimals = 1, Compact = true, Flag = "MagnetStrength", Callback = function(Value)
    print("Magnet Strength:", Value)
end})

SilentAimSection:Toggle({Name = "Override Shots", Flag = "OverrideShots", Default = false, Callback = function(Value)
    print("Override Shots:", Value)
end})

SilentAimSection:Slider({Name = "Override %", Min = 0, Max = 100, Default = 25, Suffix = "%", Decimals = 1, Compact = true, Flag = "OverridePercent", Callback = function(Value)
    print("Override %:", Value)
end})

-- Target Section
TargetSection:Toggle({Name = "Highlight Target", Flag = "HighlightTarget", Default = false, Callback = function(Value)
    print("Highlight Target:", Value)
end}):Colorpicker({Name = "Highlight Color", Flag = "HighlightTargetColor", Default = Color3.fromRGB(255, 0, 0), Callback = function(Value)
    print("Highlight Color:", Value)
end})

TargetSection:Toggle({Name = "Tracer", Flag = "TargetTracer", Default = false, Callback = function(Value)
    print("Tracer:", Value)
end})

TargetSection:Slider({Name = "Max Target Distance", Min = 0, Max = 2000, Default = 1000, Decimals = 0, Flag = "MaxTargetDistance", Callback = function(Value)
    print("Max Target Distance:", Value)
end})

TargetSection:Toggle({Name = "Lock Closest", Flag = "LockClosest", Default = true, Callback = function(Value)
    print("Lock Closest:", Value)
end})

TargetSection:Toggle({Name = "Auto Switch", Flag = "AutoSwitch", Default = false, Callback = function(Value)
    print("Auto Switch:", Value)
end})

TargetSection:Dropdown({Name = "Switch Mode", Flag = "SwitchMode", Default = "On Kill", Items = {"On Kill", "On Damage", "Time Based", "Manual"}, Callback = function(Value)
    print("Switch Mode:", Value)
end})

-- Weapon Section
WeaponSection:Toggle({Name = "No Recoil", Flag = "NoRecoil", Default = false, Callback = function(Value)
    print("No Recoil:", Value)
end})

WeaponSection:Slider({Name = "Recoil Control", Min = 0, Max = 100, Default = 100, Suffix = "%", Decimals = 1, Compact = true, Flag = "RecoilControl", Callback = function(Value)
    print("Recoil Control:", Value)
end})

WeaponSection:Toggle({Name = "No Spread", Flag = "NoSpread", Default = false, Callback = function(Value)
    print("No Spread:", Value)
end})

WeaponSection:Toggle({Name = "Instant Hit", Flag = "InstantHit", Default = false, Callback = function(Value)
    print("Instant Hit:", Value)
end})

WeaponSection:Toggle({Name = "Rapid Fire", Flag = "RapidFire", Default = false, Callback = function(Value)
    print("Rapid Fire:", Value)
end})

WeaponSection:Slider({Name = "Fire Rate", Min = 0, Max = 10, Default = 1, Decimals = 1, Flag = "FireRate", Callback = function(Value)
    print("Fire Rate:", Value)
end})

WeaponSection:Toggle({Name = "Infinite Ammo", Flag = "InfiniteAmmo", Default = false, Callback = function(Value)
    print("Infinite Ammo:", Value)
end})

WeaponSection:Toggle({Name = "Auto Reload", Flag = "AutoReload", Default = false, Callback = function(Value)
    print("Auto Reload:", Value)
end})

WeaponSection:Toggle({Name = "Instant Reload", Flag = "InstantReload", Default = false, Callback = function(Value)
    print("Instant Reload:", Value)
end})

WeaponSection:Slider({Name = "Reload Speed", Min = 0, Max = 5, Default = 1, Decimals = 2, Flag = "ReloadSpeed", Callback = function(Value)
    print("Reload Speed:", Value)
end})

WeaponSection:Toggle({Name = "Full Auto", Flag = "FullAuto", Default = false, Callback = function(Value)
    print("Full Auto:", Value)
end})

-- Visuals Tab
local ESPWorldSection = VisualsTab:Section({Name = "ESP - World", Side = 1})
local ESPPlayerSection = VisualsTab:Section({Name = "ESP - Players", Side = 1})
local ESPOtherSection = VisualsTab:Section({Name = "ESP - Other", Side = 2})
local VisualEffectsSection = VisualsTab:Section({Name = "Visual Effects", Side = 2})

-- ESP World Section
ESPWorldSection:Toggle({Name = "Enabled", Flag = "ESPEnabled", Default = false, Callback = function(Value)
    print("ESP Enabled:", Value)
end})

ESPWorldSection:Toggle({Name = "Boxes", Flag = "ESPBoxes", Default = false, Callback = function(Value)
    print("Boxes:", Value)
end}):Colorpicker({Name = "Box Color", Flag = "ESPBoxColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    print("Box Color:", Value)
end})

ESPWorldSection:Toggle({Name = "Filled Boxes", Flag = "ESPFilledBoxes", Default = false, Callback = function(Value)
    print("Filled Boxes:", Value)
end})

ESPWorldSection:Slider({Name = "Box Fill Transparency", Min = 0, Max = 1, Default = 0.5, Decimals = 2, Flag = "BoxFillTransparency", Callback = function(Value)
    print("Box Fill Transparency:", Value)
end})

ESPWorldSection:Toggle({Name = "Skeleton", Flag = "ESPSkeleton", Default = false, Callback = function(Value)
    print("Skeleton:", Value)
end}):Colorpicker({Name = "Skeleton Color", Flag = "ESPSkeletonColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    print("Skeleton Color:", Value)
end})

ESPWorldSection:Toggle({Name = "Tracer", Flag = "ESPTracer", Default = false, Callback = function(Value)
    print("Tracer:", Value)
end}):Colorpicker({Name = "Tracer Color", Flag = "ESPTracerColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    print("Tracer Color:", Value)
end})

ESPWorldSection:Toggle({Name = "Name ESP", Flag = "ESPName", Default = false, Callback = function(Value)
    print("Name ESP:", Value)
end})

ESPWorldSection:Toggle({Name = "Distance ESP", Flag = "ESPDistance", Default = false, Callback = function(Value)
    print("Distance ESP:", Value)
end})

ESPWorldSection:Toggle({Name = "Health ESP", Flag = "ESPHealth", Default = false, Callback = function(Value)
    print("Health ESP:", Value)
end})

ESPWorldSection:Toggle({Name = "Health Bar", Flag = "ESPHealthBar", Default = false, Callback = function(Value)
    print("Health Bar:", Value)
end})

ESPWorldSection:Toggle({Name = "Weapon ESP", Flag = "ESPWeapon", Default = false, Callback = function(Value)
    print("Weapon ESP:", Value)
end})

ESPWorldSection:Slider({Name = "Max ESP Distance", Min = 0, Max = 5000, Default = 2000, Decimals = 0, Flag = "MaxESPDistance", Callback = function(Value)
    print("Max ESP Distance:", Value)
end})

ESPWorldSection:Toggle({Name = "Show Team", Flag = "ESPShowTeam", Default = false, Callback = function(Value)
    print("Show Team:", Value)
end})

ESPWorldSection:Toggle({Name = "Show Enemy Only", Flag = "ESPShowEnemyOnly", Default = true, Callback = function(Value)
    print("Show Enemy Only:", Value)
end})

ESPWorldSection:Toggle({Name = "Visible Only", Flag = "ESPVisibleOnly", Default = false, Callback = function(Value)
    print("Visible Only:", Value)
end})

ESPWorldSection:Toggle({Name = "Chams", Flag = "ESPChams", Default = false, Callback = function(Value)
    print("Chams:", Value)
end}):Colorpicker({Name = "Chams Color", Flag = "ESPChamsColor", Default = Color3.fromRGB(255, 100, 100), Callback = function(Value)
    print("Chams Color:", Value)
end})

ESPWorldSection:Toggle({Name = "Chams Visible", Flag = "ESPChamsVisible", Default = false, Callback = function(Value)
    print("Chams Visible:", Value)
end}):Colorpicker({Name = "Chams Visible Color", Flag = "ESPChamsVisibleColor", Default = Color3.fromRGB(100, 255, 100), Callback = function(Value)
    print("Chams Visible Color:", Value)
end})

ESPWorldSection:Toggle({Name = "Chams Behind Walls", Flag = "ESPChamsBehind", Default = true, Callback = function(Value)
    print("Chams Behind Walls:", Value)
end})

-- ESP Player Section
ESPPlayerSection:Toggle({Name = "Outlines", Flag = "ESPOutlines", Default = false, Callback = function(Value)
    print("Outlines:", Value)
end})

ESPPlayerSection:Toggle({Name = "Glow", Flag = "ESPGlow", Default = false, Callback = function(Value)
    print("Glow:", Value)
end}):Colorpicker({Name = "Glow Color", Flag = "ESPGlowColor", Default = Color3.fromRGB(255, 100, 100), Callback = function(Value)
    print("Glow Color:", Value)
end})

ESPPlayerSection:Slider({Name = "Glow Size", Min = 0, Max = 50, Default = 10, Decimals = 0, Flag = "ESPGlowSize", Callback = function(Value)
    print("Glow Size:", Value)
end})

ESPPlayerSection:Toggle({Name = "Arrows", Flag = "ESPArrows", Default = false, Callback = function(Value)
    print("Arrows:", Value)
end}):Colorpicker({Name = "Arrow Color", Flag = "ESPArrowColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
    print("Arrow Color:", Value)
end})

ESPPlayerSection:Slider({Name = "Arrow Size", Min = 0, Max = 50, Default = 20, Decimals = 0, Flag = "ESPArrowSize", Callback = function(Value)
    print("Arrow Size:", Value)
end})

ESPPlayerSection:Toggle({Name = "Head Dot", Flag = "ESPHeadDot", Default = false, Callback = function(Value)
    print("Head Dot:", Value)
end}):Colorpicker({Name = "Head Dot Color", Flag = "ESPHeadDotColor", Default = Color3.fromRGB(255, 0, 0), Callback = function(Value)
    print("Head Dot Color:", Value)
end})

ESPPlayerSection:Slider({Name = "Head Dot Size", Min = 0, Max = 20, Default = 5, Decimals = 1, Flag = "ESPHeadDotSize", Callback = function(Value)
    print("Head Dot Size:", Value)
end})

ESPPlayerSection:Toggle({Name = "View Angle", Flag = "ESPViewAngle", Default = false, Callback = function(Value)
    print("View Angle:", Value)
end})

ESPPlayerSection:Slider({Name = "View Angle Length", Min = 0, Max = 500, Default = 100, Decimals = 0, Flag = "ESPViewAngleLength", Callback = function(Value)
    print("View Angle Length:", Value)
end})

-- ESP Other Section
ESPOtherSection:Toggle({Name = "Loot ESP", Flag = "LootESP", Default = false, Callback = function(Value)
    print("Loot ESP:", Value)
end})

ESPOtherSection:Toggle({Name = "Chest ESP", Flag = "ChestESP", Default = false, Callback = function(Value)
    print("Chest ESP:", Value)
end}):Colorpicker({Name = "Chest Color", Flag = "ChestESPColor", Default = Color3.fromRGB(255, 215, 0), Callback = function(Value)
    print("Chest Color:", Value)
end})

ESPOtherSection:Toggle({Name = "Item ESP", Flag = "ItemESP", Default = false, Callback = function(Value)
    print("Item ESP:", Value)
end})

ESPOtherSection:Toggle({Name = "Weapon ESP", Flag = "WeaponWorldESP", Default = false, Callback = function(Value)
    print("Weapon ESP:", Value)
end})

ESPOtherSection:Toggle({Name = "Vehicle ESP", Flag = "VehicleESP", Default = false, Callback = function(Value)
    print("Vehicle ESP:", Value)
end})

ESPOtherSection:Toggle({Name = "NPC ESP", Flag = "NPCESP", Default = false, Callback = function(Value)
    print("NPC ESP:", Value)
end})

ESPOtherSection:Toggle({Name = "Radar", Flag = "RadarEnabled", Default = false, Callback = function(Value)
    print("Radar:", Value)
end})

ESPOtherSection:Slider({Name = "Radar Size", Min = 0, Max = 500, Default = 200, Decimals = 0, Flag = "RadarSize", Callback = function(Value)
    print("Radar Size:", Value)
end})

ESPOtherSection:Slider({Name = "Radar Range", Min = 0, Max = 1000, Default = 500, Decimals = 0, Flag = "RadarRange", Callback = function(Value)
    print("Radar Range:", Value)
end})

-- Visual Effects Section
VisualEffectsSection:Toggle({Name = "Remove Fog", Flag = "RemoveFog", Default = false, Callback = function(Value)
    print("Remove Fog:", Value)
end})

VisualEffectsSection:Toggle({Name = "Full Bright", Flag = "FullBright", Default = false, Callback = function(Value)
    print("Full Bright:", Value)
end})

VisualEffectsSection:Slider({Name = "Brightness", Min = 0, Max = 10, Default = 1, Decimals = 1, Flag = "Brightness", Callback = function(Value)
    print("Brightness:", Value)
end})

VisualEffectsSection:Toggle({Name = "Night Mode", Flag = "NightMode", Default = false, Callback = function(Value)
    print("Night Mode:", Value)
end})

VisualEffectsSection:Toggle({Name = "Custom Time", Flag = "CustomTime", Default = false, Callback = function(Value)
    print("Custom Time:", Value)
end})

VisualEffectsSection:Slider({Name = "Time of Day", Min = 0, Max = 24, Default = 12, Decimals = 0, Flag = "TimeOfDay", Callback = function(Value)
    print("Time of Day:", Value)
end})

VisualEffectsSection:Toggle({Name = "No Flash", Flag = "NoFlash", Default = false, Callback = function(Value)
    print("No Flash:", Value)
end})

VisualEffectsSection:Toggle({Name = "No Smoke", Flag = "NoSmoke", Default = false, Callback = function(Value)
    print("No Smoke:", Value)
end})

VisualEffectsSection:Toggle({Name = "No Blood", Flag = "NoBlood", Default = false, Callback = function(Value)
    print("No Blood:", Value)
end})

VisualEffectsSection:Toggle({Name = "No Bullet Holes", Flag = "NoBulletHoles", Default = false, Callback = function(Value)
    print("No Bullet Holes:", Value)
end})

VisualEffectsSection:Toggle({Name = "No Particles", Flag = "NoParticles", Default = false, Callback = function(Value)
    print("No Particles:", Value)
end})

VisualEffectsSection:Toggle({Name = "No Textures", Flag = "NoTextures", Default = false, Callback = function(Value)
    print("No Textures:", Value)
end})

VisualEffectsSection:Toggle({Name = "Wireframe", Flag = "Wireframe", Default = false, Callback = function(Value)
    print("Wireframe:", Value)
end})

VisualEffectsSection:Toggle({Name = "Chams Walls", Flag = "ChamsWalls", Default = false, Callback = function(Value)
    print("Chams Walls:", Value)
end})

VisualEffectsSection:Slider({Name = "Field of View", Min = 0, Max = 150, Default = 70, Decimals = 0, Flag = "FOV", Callback = function(Value)
    print("Field of View:", Value)
end})

VisualEffectsSection:Toggle({Name = "Zoom", Flag = "ZoomEnabled", Default = false, Callback = function(Value)
    print("Zoom:", Value)
end}):Keybind({Name = "Zoom Key", Flag = "ZoomKey", Default = Enum.KeyCode.X, Mode = "Hold", Callback = function(Value)
    print("Zoom Key:", Value)
end})

VisualEffectsSection:Slider({Name = "Zoom FOV", Min = 0, Max = 100, Default = 30, Decimals = 0, Flag = "ZoomFOV", Callback = function(Value)
    print("Zoom FOV:", Value)
end})

VisualEffectsSection:Toggle({Name = "Third Person", Flag = "ThirdPerson", Default = false, Callback = function(Value)
    print("Third Person:", Value)
end})

VisualEffectsSection:Slider({Name = "Third Person Distance", Min = 0, Max = 50, Default = 15, Decimals = 1, Flag = "ThirdPersonDistance", Callback = function(Value)
    print("Third Person Distance:", Value)
end})

-- Movement Tab
local WalkSection = MovementTab:Section({Name = "Walk", Side = 1})
local FlySection = MovementTab:Section({Name = "Fly", Side = 1})
local JumpSection = MovementTab:Section({Name = "Jump", Side = 2})
local SpeedSection = MovementTab:Section({Name = "Speed", Side = 2})

-- Walk Section
WalkSection:Toggle({Name = "Speed Enabled", Flag = "SpeedEnabled", Default = false, Callback = function(Value)
    print("Speed Enabled:", Value)
end}):Keybind({Name = "Speed Key", Flag = "SpeedKey", Default = Enum.KeyCode.LeftShift, Mode = "Hold", Callback = function(Value)
    print("Speed Key:", Value)
end})

WalkSection:Slider({Name = "Speed", Min = 0, Max = 500, Default = 50, Decimals = 0, Flag = "WalkSpeed", Callback = function(Value)
    print("Speed:", Value)
end})

WalkSection:Toggle({Name = "Auto Sprint", Flag = "AutoSprint", Default = false, Callback = function(Value)
    print("Auto Sprint:", Value)
end})

WalkSection:Toggle({Name = "No Slowdown", Flag = "NoSlowdown", Default = false, Callback = function(Value)
    print("No Slowdown:", Value)
end})

WalkSection:Toggle({Name = "No Clip", Flag = "NoClip", Default = false, Callback = function(Value)
    print("No Clip:", Value)
end}):Keybind({Name = "NoClip Key", Flag = "NoClipKey", Default = Enum.KeyCode.V, Mode = "Toggle", Callback = function(Value)
    print("NoClip Key:", Value)
end})

WalkSection:Toggle({Name = "Infinite Stamina", Flag = "InfiniteStamina", Default = false, Callback = function(Value)
    print("Infinite Stamina:", Value)
end})

WalkSection:Toggle({Name = "Anti Slip", Flag = "AntiSlip", Default = false, Callback = function(Value)
    print("Anti Slip:", Value)
end})

WalkSection:Toggle({Name = "Walk on Water", Flag = "WalkOnWater", Default = false, Callback = function(Value)
    print("Walk on Water:", Value)
end})

WalkSection:Toggle({Name = "Auto Strafe", Flag = "AutoStrafe", Default = false, Callback = function(Value)
    print("Auto Strafe:", Value)
end})

-- Fly Section
FlySection:Toggle({Name = "Fly Enabled", Flag = "FlyEnabled", Default = false, Callback = function(Value)
    print("Fly Enabled:", Value)
end}):Keybind({Name = "Fly Key", Flag = "FlyKey", Default = Enum.KeyCode.F, Mode = "Toggle", Callback = function(Value)
    print("Fly Key:", Value)
end})

FlySection:Slider({Name = "Fly Speed", Min = 0, Max = 200, Default = 50, Decimals = 0, Flag = "FlySpeed", Callback = function(Value)
    print("Fly Speed:", Value)
end})

FlySection:Toggle({Name = "Vertical Fly", Flag = "VerticalFly", Default = true, Callback = function(Value)
    print("Vertical Fly:", Value)
end})

FlySection:Toggle({Name = "Hover", Flag = "Hover", Default = false, Callback = function(Value)
    print("Hover:", Value)
end})

FlySection:Slider({Name = "Hover Height", Min = 0, Max = 1000, Default = 100, Decimals = 0, Flag = "HoverHeight", Callback = function(Value)
    print("Hover Height:", Value)
end})

FlySection:Toggle({Name = "Noclip Fly", Flag = "NoclipFly", Default = true, Callback = function(Value)
    print("Noclip Fly:", Value)
end})

-- Jump Section
JumpSection:Toggle({Name = "Infinite Jump", Flag = "InfiniteJump", Default = false, Callback = function(Value)
    print("Infinite Jump:", Value)
end})

JumpSection:Toggle({Name = "Super Jump", Flag = "SuperJump", Default = false, Callback = function(Value)
    print("Super Jump:", Value)
end})

JumpSection:Slider({Name = "Jump Power", Min = 0, Max = 500, Default = 50, Decimals = 0, Flag = "JumpPower", Callback = function(Value)
    print("Jump Power:", Value)
end})

JumpSection:Toggle({Name = "Low Gravity", Flag = "LowGravity", Default = false, Callback = function(Value)
    print("Low Gravity:", Value)
end})

JumpSection:Slider({Name = "Gravity", Min = 0, Max = 196, Default = 196, Decimals = 0, Flag = "Gravity", Callback = function(Value)
    print("Gravity:", Value)
end})

JumpSection:Toggle({Name = "Bunny Hop", Flag = "BunnyHop", Default = false, Callback = function(Value)
    print("Bunny Hop:", Value)
end})

JumpSection:Slider({Name = "Bhop Speed", Min = 0, Max = 100, Default = 20, Decimals = 0, Flag = "BhopSpeed", Callback = function(Value)
    print("Bhop Speed:", Value)
end})

JumpSection:Toggle({Name = "Auto Jump", Flag = "AutoJump", Default = false, Callback = function(Value)
    print("Auto Jump:", Value)
end})

JumpSection:Toggle({Name = "Edge Jump", Flag = "EdgeJump", Default = false, Callback = function(Value)
    print("Edge Jump:", Value)
end})

JumpSection:Toggle({Name = "No Fall Damage", Flag = "NoFallDamage", Default = false, Callback = function(Value)
    print("No Fall Damage:", Value)
end})

-- Speed Section
SpeedSection:Toggle({Name = "Velocity Fly", Flag = "VelocityFly", Default = false, Callback = function(Value)
    print("Velocity Fly:", Value)
end})

SpeedSection:Toggle({Name = "CFrame Speed", Flag = "CFrameSpeed", Default = false, Callback = function(Value)
    print("CFrame Speed:", Value)
end})

SpeedSection:Slider({Name = "CFrame Multiplier", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "CFrameMultiplier", Callback = function(Value)
    print("CFrame Multiplier:", Value)
end})

SpeedSection:Toggle({Name = "TP Speed", Flag = "TPSpeed", Default = false, Callback = function(Value)
    print("TP Speed:", Value)
end})

SpeedSection:Slider({Name = "TP Distance", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "TPDistance", Callback = function(Value)
    print("TP Distance:", Value)
end})

-- Misc Tab
local AntiSection = MiscTab:Section({Name = "Anti-Aim", Side = 1})
local ExploitsSection = MiscTab:Section({Name = "Exploits", Side = 1})
local WorldSection = MiscTab:Section({Name = "World", Side = 2})
local AutomationSection = MiscTab:Section({Name = "Automation", Side = 2})

-- Anti-Aim Section
AntiSection:Toggle({Name = "Enabled", Flag = "AntiAimEnabled", Default = false, Callback = function(Value)
    print("Anti-Aim Enabled:", Value)
end})

AntiSection:Toggle({Name = "Spin Bot", Flag = "SpinBot", Default = false, Callback = function(Value)
    print("Spin Bot:", Value)
end})

AntiSection:Slider({Name = "Spin Speed", Min = 0, Max = 1000, Default = 100, Decimals = 0, Flag = "SpinSpeed", Callback = function(Value)
    print("Spin Speed:", Value)
end})

AntiSection:Toggle({Name = "Jitter", Flag = "Jitter", Default = false, Callback = function(Value)
    print("Jitter:", Value)
end})

AntiSection:Slider({Name = "Jitter Range", Min = 0, Max = 180, Default = 90, Decimals = 0, Flag = "JitterRange", Callback = function(Value)
    print("Jitter Range:", Value)
end})

AntiSection:Toggle({Name = "Desync", Flag = "Desync", Default = false, Callback = function(Value)
    print("Desync:", Value)
end})

AntiSection:Toggle({Name = "Backtrack", Flag = "Backtrack", Default = false, Callback = function(Value)
    print("Backtrack:", Value)
end})

AntiSection:Slider({Name = "Backtrack Ticks", Min = 0, Max = 20, Default = 5, Decimals = 0, Flag = "BacktrackTicks", Callback = function(Value)
    print("Backtrack Ticks:", Value)
end})

AntiSection:Toggle({Name = "Fake Lag", Flag = "FakeLag", Default = false, Callback = function(Value)
    print("Fake Lag:", Value)
end})

AntiSection:Slider({Name = "Lag Ticks", Min = 0, Max = 20, Default = 5, Decimals = 0, Flag = "LagTicks", Callback = function(Value)
    print("Lag Ticks:", Value)
end})

AntiSection:Toggle({Name = "Anti-Aim Facing", Flag = "AntiAimFacing", Default = false, Callback = function(Value)
    print("Anti-Aim Facing:", Value)
end})

AntiSection:Dropdown({Name = "Facing Mode", Flag = "FacingMode", Default = "Away", Items = {"Away", "Towards", "Random", "Spin"}, Callback = function(Value)
    print("Facing Mode:", Value)
end})

-- Exploits Section
ExploitsSection:Toggle({Name = "God Mode", Flag = "GodMode", Default = false, Callback = function(Value)
    print("God Mode:", Value)
end})

ExploitsSection:Toggle({Name = "Infinite Yield", Flag = "InfiniteYield", Default = false, Callback = function(Value)
    print("Infinite Yield:", Value)
end})

ExploitsSection:Toggle({Name = "Admin Commands", Flag = "AdminCommands", Default = false, Callback = function(Value)
    print("Admin Commands:", Value)
end})

ExploitsSection:Toggle({Name = "One Hit", Flag = "OneHit", Default = false, Callback = function(Value)
    print("One Hit:", Value)
end})

ExploitsSection:Toggle({Name = "Kill Aura", Flag = "KillAura", Default = false, Callback = function(Value)
    print("Kill Aura:", Value)
end})

ExploitsSection:Slider({Name = "Aura Range", Min = 0, Max = 50, Default = 10, Decimals = 1, Flag = "AuraRange", Callback = function(Value)
    print("Aura Range:", Value)
end})

ExploitsSection:Toggle({Name = "Auto Parry", Flag = "AutoParry", Default = false, Callback = function(Value)
    print("Auto Parry:", Value)
end})

ExploitsSection:Toggle({Name = "Auto Block", Flag = "AutoBlock", Default = false, Callback = function(Value)
    print("Auto Block:", Value)
end})

ExploitsSection:Toggle({Name = "Reach", Flag = "Reach", Default = false, Callback = function(Value)
    print("Reach:", Value)
end})

ExploitsSection:Slider({Name = "Reach Distance", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "ReachDistance", Callback = function(Value)
    print("Reach Distance:", Value)
end})

ExploitsSection:Toggle({Name = "Hitbox Expander", Flag = "HitboxExpander", Default = false, Callback = function(Value)
    print("Hitbox Expander:", Value)
end})

ExploitsSection:Slider({Name = "Hitbox Size", Min = 0, Max = 50, Default = 5, Decimals = 1, Flag = "HitboxSize", Callback = function(Value)
    print("Hitbox Size:", Value)
end})

ExploitsSection:Toggle({Name = "Auto Farm", Flag = "AutoFarm", Default = false, Callback = function(Value)
    print("Auto Farm:", Value)
end})

-- World Section
WorldSection:Toggle({Name = "Item ESP", Flag = "ItemWorldESP", Default = false, Callback = function(Value)
    print("Item ESP:", Value)
end})

WorldSection:Toggle({Name = "Vehicle Spawner", Flag = "VehicleSpawner", Default = false, Callback = function(Value)
    print("Vehicle Spawner:", Value)
end})

WorldSection:Toggle({Name = "Teleport", Flag = "TeleportEnabled", Default = false, Callback = function(Value)
    print("Teleport:", Value)
end})

WorldSection:Toggle({Name = "Click TP", Flag = "ClickTP", Default = false, Callback = function(Value)
    print("Click TP:", Value)
end}):Keybind({Name = "Click TP Key", Flag = "ClickTPKey", Default = Enum.KeyCode.T, Mode = "Hold", Callback = function(Value)
    print("Click TP Key:", Value)
end})

WorldSection:Toggle({Name = "Bring Items", Flag = "BringItems", Default = false, Callback = function(Value)
    print("Bring Items:", Value)
end})

WorldSection:Slider({Name = "Bring Range", Min = 0, Max = 500, Default = 100, Decimals = 0, Flag = "BringRange", Callback = function(Value)
    print("Bring Range:", Value)
end})

WorldSection:Toggle({Name = "Delete Doors", Flag = "DeleteDoors", Default = false, Callback = function(Value)
    print("Delete Doors:", Value)
end})

WorldSection:Toggle({Name = "Unlock Doors", Flag = "UnlockDoors", Default = false, Callback = function(Value)
    print("Unlock Doors:", Value)
end})

WorldSection:Toggle({Name = "Open All", Flag = "OpenAll", Default = false, Callback = function(Value)
    print("Open All:", Value)
end})

-- Automation Section
AutomationSection:Toggle({Name = "Auto Loot", Flag = "AutoLoot", Default = false, Callback = function(Value)
    print("Auto Loot:", Value)
end})

AutomationSection:Toggle({Name = "Auto Pickup", Flag = "AutoPickup", Default = false, Callback = function(Value)
    print("Auto Pickup:", Value)
end})

AutomationSection:Slider({Name = "Pickup Range", Min = 0, Max = 100, Default = 20, Decimals = 0, Flag = "PickupRange", Callback = function(Value)
    print("Pickup Range:", Value)
end})

AutomationSection:Toggle({Name = "Auto Equip", Flag = "AutoEquip", Default = false, Callback = function(Value)
    print("Auto Equip:", Value)
end})

AutomationSection:Dropdown({Name = "Equip Priority", Flag = "EquipPriority", Default = "Best", Items = {"Best", "First", "Custom"}, Callback = function(Value)
    print("Equip Priority:", Value)
end})

AutomationSection:Toggle({Name = "Auto Heal", Flag = "AutoHeal", Default = false, Callback = function(Value)
    print("Auto Heal:", Value)
end})

AutomationSection:Slider({Name = "Heal Threshold", Min = 0, Max = 100, Default = 30, Suffix = "%", Decimals = 0, Flag = "HealThreshold", Callback = function(Value)
    print("Heal Threshold:", Value)
end})

AutomationSection:Toggle({Name = "Auto Eat", Flag = "AutoEat", Default = false, Callback = function(Value)
    print("Auto Eat:", Value)
end})

AutomationSection:Toggle({Name = "Auto Fish", Flag = "AutoFish", Default = false, Callback = function(Value)
    print("Auto Fish:", Value)
end})

AutomationSection:Toggle({Name = "Auto Mine", Flag = "AutoMine", Default = false, Callback = function(Value)
    print("Auto Mine:", Value)
end})

AutomationSection:Toggle({Name = "Auto Chop", Flag = "AutoChop", Default = false, Callback = function(Value)
    print("Auto Chop:", Value)
end})

AutomationSection:Toggle({Name = "Auto Craft", Flag = "AutoCraft", Default = false, Callback = function(Value)
    print("Auto Craft:", Value)
end})

AutomationSection:Toggle({Name = "Auto Build", Flag = "AutoBuild", Default = false, Callback = function(Value)
    print("Auto Build:", Value)
end})

-- Players Tab
local TargetPlayerSection = PlayersTab:Section({Name = "Target Player", Side = 1})
local TrollingSection = PlayersTab:Section({Name = "Trolling", Side = 1})
local SpectateSection = PlayersTab:Section({Name = "Spectate", Side = 2})
local ServerSection = PlayersTab:Section({Name = "Server", Side = 2})

-- Target Player Section
TargetPlayerSection:Dropdown({Name = "Select Player", Flag = "SelectedPlayer", Default = "", Items = {}, Callback = function(Value)
    print("Selected Player:", Value)
end})

TargetPlayerSection:Button({Name = "Refresh Players", Callback = function()
    print("Refreshing players list...")
end})

TargetPlayerSection:Button({Name = "Teleport to Player", Callback = function()
    print("Teleporting to selected player...")
end})

TargetPlayerSection:Button({Name = "Spectate", Callback = function()
    print("Spectating selected player...")
end})

TargetPlayerSection:Button({Name = "Kill", Callback = function()
    print("Killing selected player...")
end})

TargetPlayerSection:Toggle({Name = "Loop Kill", Flag = "LoopKill", Default = false, Callback = function(Value)
    print("Loop Kill:", Value)
end})

TargetPlayerSection:Button({Name = "Bring", Callback = function()
    print("Bringing selected player...")
end})

TargetPlayerSection:Toggle({Name = "Loop Bring", Flag = "LoopBring", Default = false, Callback = function(Value)
    print("Loop Bring:", Value)
end})

TargetPlayerSection:Button({Name = "View Inventory", Callback = function()
    print("Viewing inventory...")
end})

TargetPlayerSection:Button({Name = "Copy Outfit", Callback = function()
    print("Copying outfit...")
end})

-- Trolling Section
TrollingSection:Toggle({Name = "Lag Player", Flag = "LagPlayer", Default = false, Callback = function(Value)
    print("Lag Player:", Value)
end})

TrollingSection:Toggle({Name = "Crash Player", Flag = "CrashPlayer", Default = false, Callback = function(Value)
    print("Crash Player:", Value)
end})

TrollingSection:Toggle({Name = "Freeze", Flag = "FreezePlayer", Default = false, Callback = function(Value)
    print("Freeze:", Value)
end})

TrollingSection:Toggle({Name = "Blind", Flag = "BlindPlayer", Default = false, Callback = function(Value)
    print("Blind:", Value)
end})

TrollingSection:Button({Name = "Fling", Callback = function()
    print("Flinging player...")
end})

TrollingSection:Button({Name = "Launch", Callback = function()
    print("Launching player...")
end})

TrollingSection:Button({Name = "Trap", Callback = function()
    print("Trapping player...")
end})

TrollingSection:Button({Name = "Void", Callback = function()
    print("Sending to void...")
end})

-- Spectate Section
SpectateSection:Toggle({Name = "Spectate", Flag = "SpectateEnabled", Default = false, Callback = function(Value)
    print("Spectate:", Value)
end}):Keybind({Name = "Spectate Key", Flag = "SpectateKey", Default = Enum.KeyCode.P, Mode = "Toggle", Callback = function(Value)
    print("Spectate Key:", Value)
end})

SpectateSection:Toggle({Name = "Freecam", Flag = "Freecam", Default = false, Callback = function(Value)
    print("Freecam:", Value)
end}):Keybind({Name = "Freecam Key", Flag = "FreecamKey", Default = Enum.KeyCode.N, Mode = "Toggle", Callback = function(Value)
    print("Freecam Key:", Value)
end})

SpectateSection:Slider({Name = "Freecam Speed", Min = 0, Max = 100, Default = 50, Decimals = 0, Flag = "FreecamSpeed", Callback = function(Value)
    print("Freecam Speed:", Value)
end})

-- Server Section
ServerSection:Button({Name = "Rejoin", Callback = function()
    print("Rejoining server...")
end})

ServerSection:Button({Name = "Server Hop", Callback = function()
    print("Server hopping...")
end})

ServerSection:Button({Name = "Join Lowest", Callback = function()
    print("Joining lowest player server...")
end})

ServerSection:Button({Name = "Copy Join Code", Callback = function()
    print("Copying join code...")
end})

ServerSection:Button({Name = "Crash Server", Callback = function()
    print("Crashing server...")
end})

-- Initialization
Library:Notification(string.format("reaper.lol loaded in %.4f seconds", os.clock()), 5, Library.Theme.Accent, {"rbxassetid://135757045959142", Color3.fromRGB(149, 255, 139)})

Library:Init()
