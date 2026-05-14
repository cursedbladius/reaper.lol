print("1")

local success1, library = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"
    ))()
end)

print("2", success1, library)

if not success1 then
    error(library)
end

local success2, window = pcall(function()
    return library:window({
        name = "reaper.lol",
        size = UDim2.fromOffset(500, 650)
    })
end)

print("3", success2, window)

if not success2 then
    error(window)
end

print("4")
