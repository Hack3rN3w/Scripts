local url = "https://raw.githubusercontent.com/Hack3rN3w/Scripts/main/Sinonniumhub.lua"

local success, code = pcall(function()
    return game:HttpGet(url)
end)

if success then
    -- 1. Check if GitHub returned a 404 error instead of the actual script
    if code:find("404: Not Found") then
        warn("ERROR 404: File 'Sinonniumhub.lua' was not found at this URL!")
    elseif #code > 0 then
        
        -- 2. Safely compile the code WITHOUT calling it instantly via ()
        local executableFunction, err = loadstring(code)
        
        -- 3. If loadstring successfully returned a function, execute it
        if executableFunction then
            print("Script opened!")
            executableFunction() 
        else
            -- Triggered if there is a syntax error inside the downloaded script
            warn("Script compilation error: " .. tostring(err))
        end
        
    else
        warn("Script is empty!")
    end
else
    warn("Execution error. Try changing your executor: " .. tostring(code))
end
