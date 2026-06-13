--by executing the script you agree that im not responsible for bans
local GITHUB_WEB_URL = "https://github.com/Hack3rN3w/Scripts/blob/main/SinonniumKey"
local GITHUB_KEY_URL = "https://raw.githubusercontent.com/Hack3rN3w/Scripts/main/SinonniumKey"

task.wait(0.2)

local oldUI = game:GetService("CoreGui"):FindFirstChild("sinonnium_hub_custom") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("sinonnium_hub_custom")
if oldUI then oldUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "sinonnium_hub_custom"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- =================================================================
-- ======================== KEY SYSTEM WINDOW ======================
-- =================================================================

local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.fromOffset(350, 220)
KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(135, 80, 255)
KeyStroke.Thickness = 1.5
KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "sinonnium hub | Key System"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 14
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -40, 0, 36)
KeyInput.Position = UDim2.new(0, 20, 0, 60)
KeyInput.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
KeyInput.BorderSizePixel = 0
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter access key..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 12
KeyInput.Parent = KeyFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = KeyInput

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(35, 35, 40)
InputStroke.Thickness = 1
InputStroke.Parent = KeyInput

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0.5, -25, 0, 36)
CheckBtn.Position = UDim2.new(0, 20, 0, 115)
CheckBtn.BackgroundColor3 = Color3.fromRGB(135, 80, 255)
CheckBtn.Text = "Check Key"
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 12
CheckBtn.Parent = KeyFrame

local CheckCorner = Instance.new("UICorner")
CheckCorner.CornerRadius = UDim.new(0, 5)
CheckCorner.Parent = CheckBtn

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.5, -25, 0, 36)
GetKeyBtn.Position = UDim2.new(0.5, 5, 0, 115)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
GetKeyBtn.Text = "Get Link"
GetKeyBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
GetKeyBtn.Font = Enum.Font.GothamSemibold
GetKeyBtn.TextSize = 11
GetKeyBtn.Parent = KeyFrame

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 5)
GetKeyCorner.Parent = GetKeyBtn

local GetKeyStroke = Instance.new("UIStroke")
GetKeyStroke.Color = Color3.fromRGB(45, 45, 50)
GetKeyStroke.Thickness = 1
GetKeyStroke.Parent = GetKeyBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 170)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Awaiting input"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.Parent = KeyFrame

local CloseKeyBtn = Instance.new("TextButton")
CloseKeyBtn.Size = UDim2.fromOffset(20, 20)
CloseKeyBtn.Position = UDim2.new(1, -25, 0, 10)
CloseKeyBtn.BackgroundTransparency = 1
CloseKeyBtn.Text = "✕"
CloseKeyBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
CloseKeyBtn.Font = Enum.Font.GothamBold
CloseKeyBtn.TextSize = 12
CloseKeyBtn.Parent = KeyFrame

CloseKeyBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(GITHUB_WEB_URL)
        GetKeyBtn.Text = "Link Copied!"
    else
        GetKeyBtn.Text = "Clipboard Error"
    end
    task.wait(1.5)
    GetKeyBtn.Text = "Get Link"
end)

-- =================================================================
-- ========================= MAIN HUB WINDOW =======================
-- =================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(550, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(135, 80, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(0, 1, 1, 0)
Separator.Position = UDim2.new(1, -1, 0, 0)
Separator.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Separator.BorderSizePixel = 0
Separator.Parent = Sidebar

local PremiumCircle = Instance.new("Frame")
PremiumCircle.Name = "PremiumCircle"
PremiumCircle.Size = UDim2.fromOffset(45, 45)
PremiumCircle.Position = UDim2.fromOffset(15, 15)
PremiumCircle.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
PremiumCircle.BorderSizePixel = 0
PremiumCircle.Parent = Sidebar

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = PremiumCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(135, 80, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Parent = PremiumCircle

local PremiumText = Instance.new("TextLabel")
PremiumText.Size = UDim2.fromScale(1, 1)
PremiumText.BackgroundTransparency = 1
PremiumText.Text = "PREMIUM"
PremiumText.TextColor3 = Color3.fromRGB(255, 255, 255)
PremiumText.Font = Enum.Font.GothamBold
PremiumText.TextSize = 8
PremiumText.Parent = PremiumCircle

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, -20, 0, 20)
HubTitle.Position = UDim2.fromOffset(15, 70)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "sinonnium hub"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 13
HubTitle.Parent = Sidebar

-- СКРОЛЛ-КОНТЕЙНЕР ДЛЯ ТАБОВ В БОКОВОЙ ПАНЕЛИ
local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Name = "TabScroll"
TabScroll.Size = UDim2.new(1, 0, 1, -105)
TabScroll.Position = UDim2.fromOffset(0, 100)
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel = 0
TabScroll.ScrollBarThickness = 2
TabScroll.ScrollBarImageColor3 = Color3.fromRGB(135, 80, 255)
TabScroll.Active = true
TabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
TabScroll.Parent = Sidebar

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -160, 1, -20)
PageContainer.Position = UDim2.fromOffset(155, 10)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local tabs = {}
local pages = {}
local tabCount = 0

local function CreateTab(name)
    tabCount = tabCount + 1
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -12, 0, 32)
    TabBtn.Position = UDim2.fromOffset(5, (tabCount - 1) * 36)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 11
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabScroll
    
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, tabCount * 36 + 10)
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = TabBtn
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.fromScale(1, 1)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(135, 80, 255)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Active = true 
    Page.ScrollingDirection = Enum.ScrollingDirection.Y 
    Page.Parent = PageContainer
    
    if tabCount == 1 then
        TabBtn.BackgroundTransparency = 0
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
    end
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, t in pairs(tabs) do 
            t.BackgroundTransparency = 1 
            t.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(tabs, TabBtn)
    table.insert(pages, Page)
    
    local pageFunctions = {}
    local elementOffset = 0
    
    function pageFunctions:AddButton(title, desc, url)
        local BtnFrame = Instance.new("Frame")
        BtnFrame.Size = UDim2.new(1, -16, 0, 46)
        BtnFrame.Position = UDim2.fromOffset(5, elementOffset)
        BtnFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        BtnFrame.BorderSizePixel = 0
        BtnFrame.Parent = Page
        
        elementOffset = elementOffset + 52
        Page.CanvasSize = UDim2.new(0, 0, 0, elementOffset + 10)
        
        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 5)
        FrameCorner.Parent = BtnFrame
        
        local FrameStroke = Instance.new("UIStroke")
        FrameStroke.Color = Color3.fromRGB(35, 35, 40)
        FrameStroke.Thickness = 1
        FrameStroke.Parent = BtnFrame
        
        local TxtTitle = Instance.new("TextLabel")
        TxtTitle.Size = UDim2.new(0.7, 0, 0, 22)
        TxtTitle.Position = UDim2.fromOffset(12, 4)
        TxtTitle.BackgroundTransparency = 1
        TxtTitle.Text = title
        TxtTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        TxtTitle.Font = Enum.Font.GothamMedium
        TxtTitle.TextSize = 12
        TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
        TxtTitle.Parent = BtnFrame
        
        local TxtDesc = Instance.new("TextLabel")
        TxtDesc.Size = UDim2.new(0.7, 0, 0, 15)
        TxtDesc.Position = UDim2.fromOffset(12, 24)
        TxtDesc.BackgroundTransparency = 1
        TxtDesc.Text = desc
        TxtDesc.TextColor3 = Color3.fromRGB(120, 120, 130)
        TxtDesc.Font = Enum.Font.Gotham
        TxtDesc.TextSize = 10
        TxtDesc.TextXAlignment = Enum.TextXAlignment.Left
        TxtDesc.Parent = BtnFrame
        
        local ActionBtn = Instance.new("TextButton")
        ActionBtn.Size = UDim2.fromOffset(85, 26)
        ActionBtn.Position = UDim2.new(1, -97, 0.5, -13)
        ActionBtn.BackgroundColor3 = Color3.fromRGB(135, 80, 255)
        ActionBtn.Text = "Execute"
        ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActionBtn.Font = Enum.Font.GothamBold
        ActionBtn.TextSize = 10
        ActionBtn.Parent = BtnFrame
        
        local ActCorner = Instance.new("UICorner")
        ActCorner.CornerRadius = UDim.new(0, 4)
        ActCorner.Parent = ActionBtn
        
        ActionBtn.MouseButton1Click:Connect(function()
            ActionBtn.Text = "Loading..."
            task.spawn(function()
                local success, content = pcall(function()
                    return game:HttpGet(url)
                end)
                
                if success and type(content) == "string" then
                    local runSuccess, runErr = pcall(function()
                        local func = assert(loadstring(content), "Error")
                        func()
                    end)
                    if runSuccess then
                        ActionBtn.Text = "Success!"
                    else
                        ActionBtn.Text = "Error"
                    end
                else
                    ActionBtn.Text = "HTTP Error"
                end
                task.wait(1.5)
                ActionBtn.Text = "Execute"
            end)
        end)
    end
    
    function pageFunctions:AddLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -16, 0, 25)
        Label.Position = UDim2.fromOffset(8, elementOffset + 5)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(135, 80, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Page
        
        elementOffset = elementOffset + 32
        Page.CanvasSize = UDim2.new(0, 0, 0, elementOffset + 10)
    end

    function pageFunctions:AddExecutorLayout()
        local CodeBox = Instance.new("TextBox")
        CodeBox.Size = UDim2.new(1, -16, 0, 180)
        CodeBox.Position = UDim2.fromOffset(5, elementOffset)
        CodeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        CodeBox.BorderSizePixel = 0
        CodeBox.ClearTextOnFocus = false
        CodeBox.MultiLine = true
        CodeBox.Text = ""
        CodeBox.PlaceholderText = "Paste your code here..."
        CodeBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
        CodeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        CodeBox.Font = Enum.Font.Code
        CodeBox.TextSize = 11
        CodeBox.TextXAlignment = Enum.TextXAlignment.Left
        CodeBox.TextYAlignment = Enum.TextYAlignment.Top
        CodeBox.Parent = Page

        local CodeCorner = Instance.new("UICorner")
        CodeCorner.CornerRadius = UDim.new(0, 6)
        CodeCorner.Parent = CodeBox

        local CodeStroke = Instance.new("UIStroke")
        CodeStroke.Color = Color3.fromRGB(35, 35, 40)
        CodeStroke.Thickness = 1
        CodeStroke.Parent = CodeBox

        elementOffset = elementOffset + 195

        local ExecButton = Instance.new("TextButton")
        ExecButton.Size = UDim2.new(0.5, -10, 0, 36)
        ExecButton.Position = UDim2.new(0, 5, 0, elementOffset)
        ExecButton.BackgroundColor3 = Color3.fromRGB(135, 80, 255)
        ExecButton.Text = "Execute Script"
        ExecButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ExecButton.Font = Enum.Font.GothamBold
        ExecButton.TextSize = 12
        ExecButton.Parent = Page

        local ExecCorner = Instance.new("UICorner")
        ExecCorner.CornerRadius = UDim.new(0, 5)
        ExecCorner.Parent = ExecButton

        local ClearButton = Instance.new("TextButton")
        ClearButton.Size = UDim2.new(0.5, -10, 0, 36)
        ClearButton.Position = UDim2.new(0.5, 5, 0, elementOffset)
        ClearButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        ClearButton.Text = "Clear Input"
        ClearButton.TextColor3 = Color3.fromRGB(150, 150, 160)
        ClearButton.Font = Enum.Font.GothamSemibold
        ClearButton.TextSize = 12
        ClearButton.Parent = Page

        local ClearCorner = Instance.new("UICorner")
        ClearCorner.CornerRadius = UDim.new(0, 5)
        ClearCorner.Parent = ClearButton

        local ClearStroke = Instance.new("UIStroke")
        ClearStroke.Color = Color3.fromRGB(45, 45, 50)
        ClearStroke.Thickness = 1
        ClearStroke.Parent = ClearButton

        elementOffset = elementOffset + 46
        Page.CanvasSize = UDim2.new(0, 0, 0, elementOffset + 10)

        ExecButton.MouseButton1Click:Connect(function()
            local code = CodeBox.Text
            if code and code ~= "" then
                local success, err = pcall(function()
                    loadstring(code)()
                end)
                if not success then
                    warn("Error executing: " .. tostring(err))
                end
            end
        end)

        ClearButton.MouseButton1Click:Connect(function()
            CodeBox.Text = ""
        end)
    end
    
    return pageFunctions
end

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(20, 20)
CloseBtn.Position = UDim2.new(1, -28, 0, 8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==================== MENU CONTENT ====================
local Tab1 = CreateTab("Universal Admin")
Tab1:AddButton("CMD-X", "Powerful and stable command console (Perfect for Wave)", "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source")
Tab1:AddButton("Nameless Admin", "Admin script with stylish visual commands", "https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source")
Tab1:AddButton("Fates Admin", "Beautiful admin panel focused on custom animations", "https://raw.githubusercontent.com/fatesc/fatesAdmin/main/main.lua")

local TabExecutor = CreateTab("Executor")
TabExecutor:AddExecutorLayout()

local TabUniversal = CreateTab("Universal")
TabUniversal:AddButton("Z4us (Level 7+)", "Universal aimbot", "https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/main.lua")

local Tab2 = CreateTab("99 nights")
Tab2:AddButton("Foxname Hub", "The best keyless script for 99 nights mode", "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FoxnameHub.lua")

local Tab3 = CreateTab("Break In")
Tab3:AddLabel("Break In 1")
Tab3:AddButton("XHub", "Top multi-functional script for the first part", "https://raw.githubusercontent.com/Bebo-Mods/XHub/main/HubLoader.lua")
Tab3:AddLabel("Break In 2")
Tab3:AddButton("Actual hub (level 5+ executors)", "The best keyless script for Break In 2 mode (level 5+ executors)", "https://raw.githubusercontent.com/Iptxt/ActualHub/refs/heads/main/Loader")

local Tab4 = CreateTab("Murder Mystery 2")
Tab4:AddButton("Vertex MM2", "Original Vertex Hub for MM2 (Autofarm, ESP)", "https://raw.smokingscripts.org/vertex.lua")

local Tab5 = CreateTab("Survive Zombie Arena")
Tab5:AddButton("Foxname Hub", "Best Keyless Script with OP combat features!", "https://rawscripts.net/raw/Survive-Zombie-Arena-Best-Keyless-Script-Foxname-Hub-222076")

local Tab6 = CreateTab("Dead Rails") 
Tab6:AddButton("Ringta (Best Keyless)", "Best keyless script for Dead Rails", "https://rawscripts.net/raw/Dead-Rails-Alpha-DEAD-RAILS-AUTOSWING-INF-HEALTH-UI-40057")
Tab6:AddButton("Foxname (Best Keyless)", "Best keyless script after Ringta", "https://rawscripts.net/raw/Dead-Rails-Beta-Foxname-hub-script-194122")

-- ================= SAFE CHECK LOGIC =================
CheckBtn.MouseButton1Click:Connect(function()
    CheckBtn.Text = "Checking..."
    
    task.spawn(function()
        -- Добавляем os.time() чтобы обойти жесткий кэш HttpGet у Роблокса
        local cacheBusterUrl = GITHUB_KEY_URL .. "?t=" .. tostring(os.time())
        
        local success, serverKey = pcall(function()
            return game:HttpGet(cacheBusterUrl)
        end)
        
        -- Выводим логи в консоль (F9), чтобы сразу видеть, что ответил GitHub
        print("[Sinonnium Debug] HttpGet Success Status:", success)
        print("[Sinonnium Debug] Raw response from GitHub:", tostring(serverKey))
        
        if success and serverKey then
            -- Чистим пробелы и переносы строк
            local cleanServerKey = serverKey:gsub("%s+", "")
            local userKey = KeyInput.Text:gsub("%s+", "")
            
            print("[Sinonnium Debug] Cleaned Server Key:", "'" .. cleanServerKey .. "'")
            print("[Sinonnium Debug] Cleaned User Input:", "'" .. userKey .. "'")
            
            -- Если Гитхаб вернул 404 страницу вместо ключа
            if cleanServerKey:find("404") or cleanServerKey == "" then
                StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                StatusLabel.Text = "Error: Key file not found on GitHub (404)!"
                CheckBtn.Text = "Error"
                task.wait(2)
                CheckBtn.Text = "Check Key"
                return
            end
            
            if userKey == cleanServerKey then
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                StatusLabel.Text = "Key correct! Loading..."
                CheckBtn.Text = "Success"
                
                task.wait(0.5)
                KeyFrame:Destroy()
                MainFrame.Visible = true
            else
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                StatusLabel.Text = "Invalid key! Please try again."
                KeyInput.Text = ""
                CheckBtn.Text = "Error"
                task.wait(1.5)
                CheckBtn.Text = "Check Key"
            end
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
            StatusLabel.Text = "GitHub connection error! Please retry."
            CheckBtn.Text = "Error"
            task.wait(1.5)
            CheckBtn.Text = "Check Key"
        end
    end)
end)
