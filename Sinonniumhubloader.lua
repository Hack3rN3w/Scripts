-- Sinonnium Hub v1.0 | Official Loader
local Notification = game:GetService("StarterGui")

local function notify(text)
    Notification:SetCore("SendNotification", {
        Title = "Sinonnium Hub",
        Text = text,
        Duration = 3
    })
end

notify("Loading Sinonnium Hub...")

local success, result = pcall(function()
    -- Сюда ставим твою RAW-ссылку
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Hack3rN3w/Scripts/main/Sinonniumhub.lua"))()
end)

if success then
    notify("Loaded successfully!")
else
    notify("Error: " .. tostring(result))
    warn("Sinonnium Hub Error: " .. tostring(result))
end
