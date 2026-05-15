local Arsenal = {}

Arsenal.MeleeSkins = {
    "Crucible", "Fish", "The Windforce", "Coral Blade", "Machete", "Mop",
    "Peppermint Slicer", "Brick", "Big Sip", "Bloxy", "Coal Sword",
    "ACT Trophy S6", "Roughian's Pipe", "Da Melee", "Endbringer",
    "The Scrambler", "Space Katana", "Egg", "Katana", "Pipe Wrench Shank",
    "Halberd", "Synthlight Greatsword", "SuperSpaceKatana", "Skele Scythe",
    "Space KatanaOLD", "The Firebrand", "Candy Cane Claws", "Fire Poker",
    "Digi-Blade", "Handblades", "Racket", "Harvester", "The Ice Dagger",
    "Calculator", "Katar", "Chainsaw", "Frog", "Blast Hammer", "Assimilator",
    "Handy Candy", "Blossoming Femur", "Makeshift Saw", "Loaf", "Swordfish",
    "Toy Tree", "The Darkheart", "Wrench", "Silver Bell", "Peppermint Hammer",
    "Butterfly Knife", "Gaster Blaster", "Candy Cane Sword", "Spring Greatsword",
    "Pan", "Pencil", "Crowbar", "Doublade", "Garlic Kebab", "Aged Shovel",
    "Sickle", "Seal", "Banana", "Pumpkin Staff", "Drill-Shear Skewer",
    "Literal Melee", "Candle Sword", "Reclaimer", "Bone Karambit",
    "Earth Cleaver", "R.A.M", "Stranger's Handblades", "Shovel", "Bat Axe",
    "Karambit", "Wooden Spoon", "Electric Flail", "Energy Blade", "Blade",
    "Rapier", "OG Space Katana", "Electronic Stake", "Smug Egg", "Heart Break",
    "Bat", "Grumpy Hammer", "FOAM BLADE 3000", "Makeshift Axe", "Wired Bat",
    "Candleabra", "Rusty Pipe", "Kunai", "Saber", "Naginata", "Carrot",
    "Energy Katar", "Divine Medallions", "Scythe", "Delinquent Pop",
    "Tactical Knife", "Annihilator's Broken Sword", "Beast Hammer", "Divinity",
    "Sledgehammer", "Fisticuffs", "Moai", "Hero's Sword", "Killbrick Melee",
    "The Fool's Tool", "Slicecicle", "Sabre", "Glacier Blade", "Doodle Sign",
    "Dagger", "Paddle", "Daito", "Combat Knife", "Kitchen Knife", "Stop Sign",
    "Frostweaver's Wand", "Leader's Axe", "Sip O' Stink", "Death's Blade",
    "Guitar", "Bouquet", "Gingerbread Knife", "The Illumina", "Bunny Staff",
    "Pumpkin Bucket", "Nomad's Blade", "Paint Brush", "Rubber Hammer",
    "When Day Breaks", "Tomahawk", "Swift End", "Brass Knuckles", "Plane",
    "Skull Pal", "Let The Skies Fall", "Newspaper", "Coal Scythe",
    "Starfire Staff", "Can Mace", "Pitchfork", "Balloon Sword", "Electro Axe",
    "Claws", "Khopesh", "Stinger", "Rebel's Bat", "The Ghostwalker",
    "Golden Rings", "Easter Cleaver", "Icicle", "Classic Sword", "Slappy",
    "Hallow's Scythe", "Merry Masher", "The Venomshank", "Night's Edge",
    "Candy Cane", "Ban Hammer", "Pumpkin Axe", "Ghost Ripper", "Baton",
    "Mittens", "Moderation Hammer", "Bone Club", "Reliable Hammer", "Crab Claw",
    "Kukri", "Rokia Hammer", "ACT Trophy"
}

function Arsenal:SetMeleeSkin(skinName)
    pcall(function()
        game:GetService("Players").LocalPlayer.Data.Melee.Value = skinName
    end)
end

function Arsenal:GetToolTargets(playerName)
    local targets = {}

    local wrapName = "HWRAP_" .. playerName
    local wrap = nil
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == wrapName then
            wrap = child
            break
        end
    end
    if not wrap then return targets end

    for _, child in pairs(wrap:GetChildren()) do
        if child.Name == "Gun" then
            table.insert(targets, child)
            break
        end
    end

    return targets
end

return Arsenal
