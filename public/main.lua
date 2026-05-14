print("reaper loaded")

local library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"
))()

print("library loaded")

local window = library:window({
    name = "reaper.lol",
    size = UDim2.fromOffset(500, 650)
})

print("window created")
