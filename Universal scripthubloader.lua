local starterGui = game:GetService("StarterGui")

print("This is a joke, not real. The anticheat system is also not real. Just have fun!")
starterGui:SetCore("SendNotification", {
    Title = "Loader",
    Text = "Downloading the scripthub....",
    Duration = 3
})
task.wait(3)

starterGui:SetCore("SendNotification", {
    Title = "Loader",
    Text = "Success!",
    Duration = 1
})
task.wait(1)

starterGui:SetCore("SendNotification", {
    Title = "Loader",
    Text = "Checking the protection...",
    Duration = 3
})
task.wait(3)

starterGui:SetCore("SendNotification", {
    Title = "Loader",
    Text = "Success!",
    Duration = 1
})
task.wait(1)

local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/Hack3rN3w/Scripts/refs/heads/main/Universal%20scripthub.lua", true)
end)

if success and result then
    loadstring(result)()
end
