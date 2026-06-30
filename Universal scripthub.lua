local player = game:GetService("Players").LocalPlayer
local starterGui = game:GetService("StarterGui")
local playersService = game:GetService("Players")

if not player.Character then 
    player.CharacterAdded:Wait() 
end

starterGui:SetCore("SendNotification", {
    Title = "Universal Script Hub",
    Text = "Loading UI Libraries and configs... Please wait.",
    Duration = 5
})

task.wait(7)

local function freezeWorld()
    for _, otherPlayer in ipairs(playersService:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored then
                    part.Anchored = true
                end
            end
            local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:AdjustSpeed(0)
                    end
                end
            end
        end
    end
end

local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

local controls
local successControls, resultControls = pcall(function()
    return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
end)

if successControls and resultControls then
    controls = resultControls
    controls:Disable()
else
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = true
        end
    end)
end

pcall(function()
    starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

freezeWorld()

starterGui:SetCore("SendNotification", {
    Title = "Server Anti-Cheat",
    Text = "Our server anticheat is checking you.",
    Duration = 5
})

task.wait(5)

starterGui:SetCore("SendNotification", {
    Title = "Server Anti-Cheat",
    Text = "Our server anticheat thinks you are suspicious.",
    Duration = 4
})

task.wait(3)

starterGui:SetCore("SendNotification", {
    Title = "Advanced Anti-Cheat",
    Text = "[Advanced anticheat] Your executor sucks, too bad.",
    Duration = 4
})

task.wait(3)

player:Kick("\n\n[Advanced Anti-Cheat]\nConnection terminated.\nReason: Executor like injection detected.\n\nEven level 7+ executor won't help.")
