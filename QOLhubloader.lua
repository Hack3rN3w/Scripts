--[[
    QoL Hub Loader
    Loads the hub from GitHub with error handling and Roblox notifications.
]]
print("Enjoy!")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local function notify(title, text, duration)
    duration = duration or 5
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration,
    })
end

local function loadHub()
    local url = "https://raw.githubusercontent.com/Hack3rN3w/Scripts/refs/heads/main/qolhub.lua"
    
    -- Attempt to download
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        -- Network error
        local errMsg = "Failed to download script: " .. tostring(result)
        notify("QoL Hub Loader", "Network error. Check your internet connection.")
        warn("[QoL Loader] " .. errMsg)
        warn("[QoL Loader] Recommendation: Ensure you have an active internet connection and try again.")
        return
    end
    
    local scriptContent = result
    
    -- Check if we got HTML error (404, etc.)
    if string.find(scriptContent, "<html") or string.find(scriptContent, "404") then
        notify("QoL Hub Loader", "Script not found on GitHub.")
        warn("[QoL Loader] The script file seems to have been moved or deleted. URL: " .. url)
        warn("[QoL Loader] Recommendation: Check the URL or contact the developer.")
        return
    end
    
    -- Check if content is too short (likely empty)
    if #scriptContent < 100 then
        notify("QoL Hub Loader", "Script file is empty or corrupted.")
        warn("[QoL Loader] The downloaded script is too short (length: " .. #scriptContent .. ").")
        warn("[QoL Loader] Recommendation: Verify the file on GitHub.")
        return
    end
    
    -- Basic sanity check: look for typical Lua patterns
    if not string.find(scriptContent, "local") and not string.find(scriptContent, "function") then
        notify("QoL Hub Loader", "Invalid script format.")
        warn("[QoL Loader] The downloaded content does not look like a valid Lua script.")
        warn("[QoL Loader] Recommendation: Check the file content on GitHub.")
        return
    end
    
    -- Try to compile and execute
    local func, compileErr = loadstring(scriptContent)
    if not func then
        notify("QoL Hub Loader", "Syntax error in the script.")
        warn("[QoL Loader] Compilation error: " .. tostring(compileErr))
        warn("[QoL Loader] Recommendation: Check the script syntax on GitHub.")
        return
    end
    
    local execSuccess, execErr = pcall(func)
    if not execSuccess then
        notify("QoL Hub Loader", "Runtime error while executing the script.")
        warn("[QoL Loader] Execution error: " .. tostring(execErr))
        warn("[QoL Loader] Recommendation: Check the script logic or report the issue.")
        return
    end
    
    -- Success
    notify("QoL Hub Loader", "Hub loaded successfully!")
end

-- Run the loader
task.spawn(loadHub)
