print("START")

local library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"
))()

print("LIBRARY LOADED")

local window = library:window({
    name = "reaper.lol",
    size = UDim2.fromOffset(500, 650)
})

print("WINDOW CREATED")
