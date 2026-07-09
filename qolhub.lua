
--[[
    QoL Hub + Exploits + HUD + Executor
    Theme: black + purple, smooth tweens, drag & drop, collapse.
    Tabs: QoL, Exploits, HUD, Executor.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StatsService = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- PALETTE
----------------------------------------------------------------
local COLORS = {
    Background   = Color3.fromRGB(18, 16, 24),
    Panel        = Color3.fromRGB(26, 22, 34),
    Accent       = Color3.fromRGB(138, 43, 226), -- purple
    AccentDark   = Color3.fromRGB(90, 30, 150),
    Text         = Color3.fromRGB(235, 230, 245),
    SubText      = Color3.fromRGB(160, 150, 175),
    ToggleOff    = Color3.fromRGB(45, 40, 55),
    ToggleOn     = Color3.fromRGB(138, 43, 226),
}

----------------------------------------------------------------
-- MAIN SCREEN
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QoLHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- SPLASH SCREEN
----------------------------------------------------------------
local splash = Instance.new("TextLabel")
splash.Name = "Splash"
splash.BackgroundTransparency = 1
splash.Size = UDim2.new(1, 0, 1, 0)
splash.Position = UDim2.new(0, 0, 0, 0)
splash.Font = Enum.Font.GothamBold
splash.Text = "Enjoy this, you can either use qol features not to hack or use exploits"
splash.TextColor3 = COLORS.Accent
splash.TextSize = 28
splash.TextTransparency = 1
splash.ZIndex = 50
splash.Parent = screenGui

task.spawn(function()
    task.wait(0.15)
    TweenService:Create(splash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    task.wait(1.3)
    TweenService:Create(splash, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    task.wait(0.5)
    splash:Destroy()
end)

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 360, 0, 520) -- wider for 4 tabs
main.Position = UDim2.new(0, 20, 0.5, -260)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent = main

-- Top bar (title + tabs + drag + collapse)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = COLORS.Panel
topBar.BorderSizePixel = 0
topBar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local topMask = Instance.new("Frame")
topMask.BackgroundColor3 = COLORS.Panel
topMask.BorderSizePixel = 0
topMask.Size = UDim2.new(1, 0, 0, 12)
topMask.Position = UDim2.new(0, 0, 1, -12)
topMask.Parent = topBar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 14, 0, 0)
title.Size = UDim2.new(0, 40, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "QoL"
title.TextColor3 = COLORS.Text
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0, 0, 0.5, -4)
dot.BackgroundColor3 = COLORS.Accent
dot.BorderSizePixel = 0
dot.Parent = title

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot
title.Position = UDim2.new(0, 24, 0, 0)

-- Tab buttons (4 total)
local function createTabButton(text, xPos, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 0, 28)
    btn.Position = UDim2.new(0, xPos, 0.5, -14)
    btn.BackgroundColor3 = COLORS.ToggleOff
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = COLORS.SubText
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = topBar
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local tabQoL = createTabButton("QoL", 68, 45)
local tabExploit = createTabButton("Exploits", 118, 60)
local tabHUD = createTabButton("HUD", 183, 45)
local tabExecutor = createTabButton("Executor", 233, 65)

-- Initially active: QoL
tabQoL.BackgroundColor3 = COLORS.Accent
tabQoL.TextColor3 = COLORS.Text

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(1, -35, 0, 5)
collapseBtn.BackgroundColor3 = COLORS.ToggleOff
collapseBtn.Text = "—"
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.TextColor3 = COLORS.Text
collapseBtn.TextSize = 16
collapseBtn.AutoButtonColor = false
collapseBtn.Parent = topBar

local collapseCorner = Instance.new("UICorner")
collapseCorner.CornerRadius = UDim.new(0, 8)
collapseCorner.Parent = collapseBtn

----------------------------------------------------------------
-- TAB CONTAINERS (ScrollingFrame)
----------------------------------------------------------------
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.BackgroundTransparency = 1
contentContainer.Position = UDim2.new(0, 0, 0, 40)
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Parent = main

-- Tab QoL
local contentQoL = Instance.new("ScrollingFrame")
contentQoL.Name = "QoL"
contentQoL.BackgroundTransparency = 1
contentQoL.Size = UDim2.new(1, 0, 1, 0)
contentQoL.BorderSizePixel = 0
contentQoL.ScrollBarThickness = 4
contentQoL.ScrollBarImageColor3 = COLORS.Accent
contentQoL.CanvasSize = UDim2.new(0, 0, 0, 0)
contentQoL.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentQoL.Parent = contentContainer

local layoutQoL = Instance.new("UIListLayout")
layoutQoL.Padding = UDim.new(0, 8)
layoutQoL.SortOrder = Enum.SortOrder.LayoutOrder
layoutQoL.Parent = contentQoL

local paddingQoL = Instance.new("UIPadding")
paddingQoL.PaddingTop = UDim.new(0, 10)
paddingQoL.PaddingBottom = UDim.new(0, 10)
paddingQoL.PaddingLeft = UDim.new(0, 12)
paddingQoL.PaddingRight = UDim.new(0, 12)
paddingQoL.Parent = contentQoL

-- Tab Exploits
local contentExploit = Instance.new("ScrollingFrame")
contentExploit.Name = "Exploits"
contentExploit.BackgroundTransparency = 1
contentExploit.Size = UDim2.new(1, 0, 1, 0)
contentExploit.BorderSizePixel = 0
contentExploit.ScrollBarThickness = 4
contentExploit.ScrollBarImageColor3 = COLORS.Accent
contentExploit.CanvasSize = UDim2.new(0, 0, 0, 0)
contentExploit.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentExploit.Visible = false
contentExploit.Parent = contentContainer

local layoutExploit = Instance.new("UIListLayout")
layoutExploit.Padding = UDim.new(0, 8)
layoutExploit.SortOrder = Enum.SortOrder.LayoutOrder
layoutExploit.Parent = contentExploit

local paddingExploit = Instance.new("UIPadding")
paddingExploit.PaddingTop = UDim.new(0, 10)
paddingExploit.PaddingBottom = UDim.new(0, 10)
paddingExploit.PaddingLeft = UDim.new(0, 12)
paddingExploit.PaddingRight = UDim.new(0, 12)
paddingExploit.Parent = contentExploit

-- Tab HUD (no scroll, custom content)
local contentHUD = Instance.new("Frame")
contentHUD.Name = "HUD"
contentHUD.BackgroundTransparency = 1
contentHUD.Size = UDim2.new(1, 0, 1, 0)
contentHUD.Visible = false
contentHUD.Parent = contentContainer

-- Tab Executor (no scroll)
local contentExecutor = Instance.new("Frame")
contentExecutor.Name = "Executor"
contentExecutor.BackgroundTransparency = 1
contentExecutor.Size = UDim2.new(1, 0, 1, 0)
contentExecutor.Visible = false
contentExecutor.Parent = contentContainer

-- Set current container for backward compatibility
local content = contentQoL

----------------------------------------------------------------
-- WINDOW DRAGGING
----------------------------------------------------------------
do
    local dragging, dragInput, dragStart, startPos

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

----------------------------------------------------------------
-- TAB SWITCHING
----------------------------------------------------------------
local currentTab = "QoL"

local function switchTab(tab)
    if tab == currentTab then return end
    currentTab = tab
    
    contentQoL.Visible = false
    contentExploit.Visible = false
    contentHUD.Visible = false
    contentExecutor.Visible = false
    
    tabQoL.BackgroundColor3 = COLORS.ToggleOff
    tabQoL.TextColor3 = COLORS.SubText
    tabExploit.BackgroundColor3 = COLORS.ToggleOff
    tabExploit.TextColor3 = COLORS.SubText
    tabHUD.BackgroundColor3 = COLORS.ToggleOff
    tabHUD.TextColor3 = COLORS.SubText
    tabExecutor.BackgroundColor3 = COLORS.ToggleOff
    tabExecutor.TextColor3 = COLORS.SubText
    
    if tab == "QoL" then
        contentQoL.Visible = true
        tabQoL.BackgroundColor3 = COLORS.Accent
        tabQoL.TextColor3 = COLORS.Text
        content = contentQoL
    elseif tab == "Exploits" then
        contentExploit.Visible = true
        tabExploit.BackgroundColor3 = COLORS.Accent
        tabExploit.TextColor3 = COLORS.Text
        content = contentExploit
    elseif tab == "HUD" then
        contentHUD.Visible = true
        tabHUD.BackgroundColor3 = COLORS.Accent
        tabHUD.TextColor3 = COLORS.Text
        content = contentHUD
    elseif tab == "Executor" then
        contentExecutor.Visible = true
        tabExecutor.BackgroundColor3 = COLORS.Accent
        tabExecutor.TextColor3 = COLORS.Text
        content = contentExecutor
    end
end

tabQoL.MouseButton1Click:Connect(function() switchTab("QoL") end)
tabExploit.MouseButton1Click:Connect(function() switchTab("Exploits") end)
tabHUD.MouseButton1Click:Connect(function() switchTab("HUD") end)
tabExecutor.MouseButton1Click:Connect(function() switchTab("Executor") end)

----------------------------------------------------------------
-- COLLAPSING
----------------------------------------------------------------
local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    local targetSize = collapsed and UDim2.new(0, 360, 0, 40) or UDim2.new(0, 360, 0, 520)
    TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingStyle.Out), {Size = targetSize}):Play()
    collapseBtn.Text = collapsed and "+" or "—"
end)

----------------------------------------------------------------
-- HELPER FUNCTIONS FOR ELEMENT CREATION (for QoL and Exploits)
----------------------------------------------------------------
local function createToggleRow(order, labelText, defaultOn, onChanged)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = COLORS.Panel
    row.LayoutOrder = order
    row.Parent = content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = labelText
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 42, 0, 22)
    toggleBg.Position = UDim2.new(1, -54, 0.5, -11)
    toggleBg.BackgroundColor3 = defaultOn and COLORS.ToggleOn or COLORS.ToggleOff
    toggleBg.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local clickBtn = Instance.new("TextButton")
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.Parent = toggleBg

    local state = defaultOn

    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        local bgColor = state and COLORS.ToggleOn or COLORS.ToggleOff
        local knobPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)

        TweenService:Create(toggleBg, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundColor3 = bgColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = knobPos}):Play()

        onChanged(state)
    end)

    return row
end

local function createInfoRow(order, labelText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = COLORS.Panel
    row.LayoutOrder = order
    row.Parent = content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = labelText
    label.TextColor3 = COLORS.SubText
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    return row, label
end

local function createButtonRow(order, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = COLORS.AccentDark
    btn.Text = labelText
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = COLORS.Text
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = content

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.AccentDark}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)

    return btn
end

local function createSliderRow(order, labelText, min, max, default, onChanged, suffix)
    suffix = suffix or ""
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = COLORS.Panel
    row.LayoutOrder = order
    row.Parent = content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 4)
    label.Size = UDim2.new(1, -24, 0, 18)
    label.Font = Enum.Font.Gotham
    label.Text = labelText
    label.TextColor3 = COLORS.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -60, 0, 4)
    valueLabel.Size = UDim2.new(0, 48, 0, 18)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default) .. suffix
    valueLabel.TextColor3 = COLORS.Accent
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = COLORS.ToggleOff
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fraction = (default - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(fraction, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Accent
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fraction, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 2
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false

    local function update(inputPosX)
        local relative = math.clamp((inputPosX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relative
        value = math.floor(value + 0.5)
        relative = (value - min) / (max - min)

        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. suffix

        onChanged(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row
end

----------------------------------------------------------------
-- QoL TAB FUNCTIONS (old + new)
----------------------------------------------------------------
-- FPS / Ping / Clock
local statsRow, statsLabel = createInfoRow(1, "FPS: -- | Ping: -- ms")
local clockRow, clockLabel = createInfoRow(2, "Time: --:--:--")

local frameCount, lastFpsUpdate = 0, os.clock()
local currentFps = 0

RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = os.clock()
    if now - lastFpsUpdate >= 0.5 then
        currentFps = math.floor(frameCount / (now - lastFpsUpdate))
        frameCount = 0
        lastFpsUpdate = now

        local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
        statsLabel.Text = string.format("FPS: %d | Ping: %d ms", currentFps, ping)
    end
    clockLabel.Text = "Time: " .. os.date("%H:%M:%S")
end)

-- Anti-AFK
local antiAfkEnabled = true
local vu = UserInputService

RunService.Heartbeat:Connect(function()
    if antiAfkEnabled then
        vu:GetLastInputType()
    end
end)

player.Idled:Connect(function()
    if antiAfkEnabled then
        vu:GetLastInputType()
    end
end)

createToggleRow(3, "Anti-AFK", true, function(state)
    antiAfkEnabled = state
end)

-- Rejoin
createButtonRow(4, "Rejoin", function()
    TeleportService:Teleport(game.PlaceId, player)
end)

-- Hide Roblox UI
createToggleRow(5, "Hide Roblox UI", false, function(state)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not state)
end)

-- Low Graphics
local savedLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
}
createToggleRow(6, "Low Graphics Mode", false, function(state)
    if state then
        savedLighting.GlobalShadows = Lighting.GlobalShadows
        savedLighting.FogEnd = Lighting.FogEnd
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") then
                obj.Density = 0
            end
        end
    else
        Lighting.GlobalShadows = savedLighting.GlobalShadows
        Lighting.FogEnd = savedLighting.FogEnd
    end
end)

-- Camera FOV
createSliderRow(7, "Camera FOV", 50, 120, 70, function(value)
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = value
    end
end, "°")

-- Master Volume
createSliderRow(8, "Game Volume", 0, 100, 50, function(value)
    for _, snd in ipairs(SoundService:GetDescendants()) do
        if snd:IsA("Sound") then
            snd.Volume = (value / 100)
        end
    end
end, "%")

-- Unstuck
createButtonRow(9, "Unstuck (I'm stuck)", function()
    local character = player.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)

-- Coordinates
local coordRow, coordLabel = createInfoRow(10, "Coordinates: X: 0, Y: 0, Z: 0")

-- Player count
local playerCountRow, playerCountLabel = createInfoRow(11, "Players: 0")

-- Brightness
createSliderRow(12, "Brightness", 0.1, 2, 1, function(value)
    Lighting.Brightness = value
end, "x")

-- Respawn
createButtonRow(13, "Respawn", function()
    if player.Character then
        player.Character:BreakJoints()
    end
    task.wait(0.1)
    player:LoadCharacter()
end)

-- Teleport to Spawn
createButtonRow(14, "Teleport to Spawn", function()
    local found = false
    local spawns = workspace:GetDescendants()
    for _, obj in ipairs(spawns) do
        if obj:IsA("SpawnLocation") then
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    found = true
                    break
                end
            end
        end
    end
    if not found then
        warn("No SpawnLocation found on the map")
    end
end)

-- Background update of coordinates and player counter
task.spawn(function()
    while task.wait(0.3) do
        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position
                coordLabel.Text = string.format("Coordinates: X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
            end
        end
        local count = #Players:GetPlayers()
        playerCountLabel.Text = "Players: " .. count
    end
end)

----------------------------------------------------------------
-- EXPLOITS TAB FUNCTIONS (new)
----------------------------------------------------------------
content = contentExploit

-- Fly
local flyEnabled = false
local flyBodyVelocity = nil
local flyConnections = {}

local function toggleFly(state)
    flyEnabled = state
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyEnabled then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = hrp

        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end

        local moveConnection
        local function onMove()
            if not flyEnabled or not flyBodyVelocity then return end
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -1, 0) end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * 50
                flyBodyVelocity.Velocity = moveDir
            else
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end

        moveConnection = RunService.Heartbeat:Connect(onMove)
        flyConnections = {moveConnection}
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        for _, conn in ipairs(flyConnections) do
            conn:Disconnect()
        end
        flyConnections = {}
    end
end

createToggleRow(15, "Fly", false, function(state)
    toggleFly(state)
end)

-- Noclip
local noclipEnabled = false
local noclipConnections = {}

local function toggleNoclip(state)
    noclipEnabled = state
    if noclipEnabled then
        local function noclipUpdate()
            local character = player.Character
            if not character then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        noclipUpdate()
        local conn = RunService.Heartbeat:Connect(noclipUpdate)
        table.insert(noclipConnections, conn)
    else
        for _, conn in ipairs(noclipConnections) do
            conn:Disconnect()
        end
        noclipConnections = {}
        local character = player.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

createToggleRow(16, "Noclip", false, function(state)
    toggleNoclip(state)
end)

-- Speedhack
local speedMultiplier = 1
createSliderRow(17, "Speedhack (x)", 1, 10, 1, function(value)
    speedMultiplier = value
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * speedMultiplier
        end
    end
end, "x")

-- ESP
local espEnabled = false
local espConnections = {}
local espLabels = {}

local function toggleESP(state)
    espEnabled = state
    if espEnabled then
        local function createESP(targetPlayer)
            if targetPlayer == player then return end
            local character = targetPlayer.Character
            if not character then return end
            local head = character:FindFirstChild("Head")
            if not head then return end

            local bill = Instance.new("BillboardGui")
            bill.Name = "ESP_" .. targetPlayer.Name
            bill.Size = UDim2.new(0, 200, 0, 40)
            bill.Adornee = head
            bill.AlwaysOnTop = true
            bill.Parent = head

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = targetPlayer.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0.5
            label.Font = Enum.Font.GothamBold
            label.TextSize = 16
            label.Parent = bill

            espLabels[targetPlayer] = bill
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end

        local playerAdded = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                createESP(plr)
            end)
            task.wait(0.5)
            createESP(plr)
        end)

        local playerRemoved = Players.PlayerRemoving:Connect(function(plr)
            if espLabels[plr] then
                espLabels[plr]:Destroy()
                espLabels[plr] = nil
            end
        end)

        espConnections = {playerAdded, playerRemoved}
    else
        for _, bill in pairs(espLabels) do
            bill:Destroy()
        end
        espLabels = {}
        for _, conn in ipairs(espConnections) do
            conn:Disconnect()
        end
        espConnections = {}
    end
end

createToggleRow(18, "ESP (names)", false, function(state)
    toggleESP(state)
end)

----------------------------------------------------------------
-- HUD TAB
----------------------------------------------------------------
-- Create HUD elements (not using helper functions because they're bound to 'content')
local function createHUDLabel(text, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 30)
    label.Position = UDim2.new(0, 12, 0, yPos)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = contentHUD
    return label
end

-- F9 Console
local consoleLabel = createHUDLabel("F9 Console (click to output)", 10)
local consoleFrame = Instance.new("Frame")
consoleFrame.Size = UDim2.new(1, -24, 0, 150)
consoleFrame.Position = UDim2.new(0, 12, 0, 45)
consoleFrame.BackgroundColor3 = COLORS.Panel
consoleFrame.Parent = contentHUD
local consoleCorner = Instance.new("UICorner")
consoleCorner.CornerRadius = UDim.new(0, 8)
consoleCorner.Parent = consoleFrame

local consoleText = Instance.new("ScrollingFrame")
consoleText.Size = UDim2.new(1, -10, 1, -10)
consoleText.Position = UDim2.new(0, 5, 0, 5)
consoleText.BackgroundTransparency = 1
consoleText.BorderSizePixel = 0
consoleText.ScrollBarThickness = 4
consoleText.ScrollBarImageColor3 = COLORS.Accent
consoleText.Parent = consoleFrame

local consoleLayout = Instance.new("UIListLayout")
consoleLayout.Padding = UDim.new(0, 2)
consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
consoleLayout.Parent = consoleText

-- Intercept print and output to console
local originalPrint = print
local consoleLines = {}

local function addConsoleLine(msg)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = msg
    label.TextColor3 = COLORS.SubText
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = consoleText
    consoleLines[#consoleLines + 1] = label
    -- Limit number of lines
    if #consoleLines > 100 then
        local old = table.remove(consoleLines, 1)
        old:Destroy()
    end
    -- Scroll down
    consoleText.CanvasPosition = Vector2.new(0, consoleText.CanvasSize.Y.Offset)
end

print = function(...)
    local args = {...}
    local msg = table.concat(args, " ")
    originalPrint(...)
    addConsoleLine(msg)
end

-- Clear console button
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 80, 0, 28)
clearBtn.Position = UDim2.new(1, -92, 0, 10)
clearBtn.BackgroundColor3 = COLORS.AccentDark
clearBtn.Text = "Clear"
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextColor3 = COLORS.Text
clearBtn.TextSize = 13
clearBtn.AutoButtonColor = false
clearBtn.Parent = contentHUD
local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearBtn
clearBtn.MouseButton1Click:Connect(function()
    for _, line in ipairs(consoleLines) do
        line:Destroy()
    end
    consoleLines = {}
end)

-- Player list
local playerListLabel = createHUDLabel("Players on server:", 210)
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, -24, 0, 120)
playerListFrame.Position = UDim2.new(0, 12, 0, 245)
playerListFrame.BackgroundColor3 = COLORS.Panel
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.ScrollBarImageColor3 = COLORS.Accent
playerListFrame.Parent = contentHUD
local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 8)
playerCorner.Parent = playerListFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerListFrame

local playerLabels = {}
local function updatePlayerList()
    for _, lbl in ipairs(playerLabels) do
        lbl:Destroy()
    end
    playerLabels = {}
    local plrs = Players:GetPlayers()
    for _, plr in ipairs(plrs) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.Text = plr.Name .. (plr == player and " (You)" or "")
        lbl.TextColor3 = plr == player and COLORS.Accent or COLORS.SubText
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = playerListFrame
        playerLabels[#playerLabels + 1] = lbl
    end
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Greeting in console output
print("F9 Console active. Hello!")

----------------------------------------------------------------
-- EXECUTOR TAB
----------------------------------------------------------------
local codeLabel = Instance.new("TextLabel")
codeLabel.Size = UDim2.new(1, -24, 0, 30)
codeLabel.Position = UDim2.new(0, 12, 0, 10)
codeLabel.BackgroundTransparency = 1
codeLabel.Font = Enum.Font.Gotham
codeLabel.Text = "Enter Lua code:"
codeLabel.TextColor3 = COLORS.Text
codeLabel.TextSize = 14
codeLabel.TextXAlignment = Enum.TextXAlignment.Left
codeLabel.Parent = contentExecutor

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -24, 0, 150)
codeBox.Position = UDim2.new(0, 12, 0, 45)
codeBox.BackgroundColor3 = COLORS.Panel
codeBox.Font = Enum.Font.Gotham
codeBox.Text = ""
codeBox.TextColor3 = COLORS.Text
codeBox.TextSize = 13
codeBox.MultiLine = true
codeBox.ClearTextOnFocus = false
codeBox.Parent = contentExecutor
local codeCorner = Instance.new("UICorner")
codeCorner.CornerRadius = UDim.new(0, 8)
codeCorner.Parent = codeBox

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0, 120, 0, 36)
execBtn.Position = UDim2.new(0, 12, 0, 210)
execBtn.BackgroundColor3 = COLORS.Accent
execBtn.Text = "Execute"
execBtn.Font = Enum.Font.GothamBold
execBtn.TextColor3 = COLORS.Text
execBtn.TextSize = 14
execBtn.AutoButtonColor = false
execBtn.Parent = contentExecutor
local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 8)
execCorner.Parent = execBtn

execBtn.MouseButton1Click:Connect(function()
    local code = codeBox.Text
    if code and code ~= "" then
        local func, err = loadstring(code)
        if func then
            local success, result = pcall(func)
            if not success then
                print("Execution error: " .. tostring(result))
            elseif result ~= nil then
                print("Result: " .. tostring(result))
            end
        else
            print("Syntax error: " .. tostring(err))
        end
    end
end)

local clearCodeBtn = Instance.new("TextButton")
clearCodeBtn.Size = UDim2.new(0, 80, 0, 36)
clearCodeBtn.Position = UDim2.new(0, 140, 0, 210)
clearCodeBtn.BackgroundColor3 = COLORS.ToggleOff
clearCodeBtn.Text = "Clear"
clearCodeBtn.Font = Enum.Font.GothamBold
clearCodeBtn.TextColor3 = COLORS.Text
clearCodeBtn.TextSize = 14
clearCodeBtn.AutoButtonColor = false
clearCodeBtn.Parent = contentExecutor
local clearCodeCorner = Instance.new("UICorner")
clearCodeCorner.CornerRadius = UDim.new(0, 8)
clearCodeCorner.Parent = clearCodeBtn

clearCodeBtn.MouseButton1Click:Connect(function()
    codeBox.Text = ""
end)

----------------------------------------------------------------
-- HOTKEY TO SHOW/HIDE WINDOW (Right Shift)
----------------------------------------------------------------
local hubVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        hubVisible = not hubVisible
        main.Visible = hubVisible
    end
end)

-- Smooth appear after splash
main.Visible = false
main.BackgroundTransparency = 1
main.Position = UDim2.new(0, 20, 0.5, -190)

task.spawn(function()
    task.wait(2.4)
    main.Visible = true
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 20, 0.5, -260)
    }):Play()
end)
