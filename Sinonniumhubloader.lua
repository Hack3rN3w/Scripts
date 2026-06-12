local url = "https://raw.githubusercontent.com/Hack3rN3w/Scripts/main/Sinonniumhub.lua"
local success, code = pcall(function()
    return game:HttpGet(url)
end)

if success then
    print("Succesful") -- если тут 0 или мало, значит файл не скачался
    if #code > 0 then
        loadstring(code)()
    else
        warn("Скрипт пустой!")
    end
else
    warn("Error of opening. Try changing executor: " .. tostring(code))
end
