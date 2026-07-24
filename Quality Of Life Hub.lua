--I am not responsible for bans!
if _G.QOLHubUnload then
	pcall(_G.QOLHubUnload)
	task.wait(0.2)
end
local okUI, WindUI = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not okUI or not WindUI then
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title    = "QOL Hub",
			Text     = "Failed to load WindUI. Check your internet or executor.",
			Duration = 6,
		})
	end)
	error("QOL Hub: WindUI failed to load — " .. tostring(WindUI), 0)
end
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")
local Lighting         = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Running        = true
local StartTime      = os.time()
local FPS, Ping      = 0, 0
local NotifyJoins    = true
local OverlayEnabled = true
local CleanScreen    = false
local AutoRejoin     = false
local ShowSpeed      = false
local AfkConnection  = nil
local AfkCount       = 0
local DefaultFOV     = Camera and Camera.FieldOfView or 70
local JoinLog        = {}
local NamesHidden    = false
local Move = {
	WalkSpeedOn = false, WalkSpeed = 16,
	JumpOn      = false, JumpValue = 50,
	InfJump     = false,
	Fly         = false, FlySpeed  = 60,
	Noclip      = false,
	AutoJump    = false,
	Spin        = false, SpinSpeed = 5,
	Freeze      = false,
	ClickTP     = false,
	AntiVoid    = false,
	LastSafePos = nil,
}
local Esp = { Names = false, Highlight = false }
local DefaultGravity  = workspace.Gravity
local OriginalLighting = {
	Brightness    = Lighting.Brightness,
	ClockTime     = Lighting.ClockTime,
	FogEnd        = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient       = Lighting.Ambient,
}
local Waypoints = {}
local Connections = {}
local function Track(conn)
	table.insert(Connections, conn)
	return conn
end
local function HttpFetch(url)
	local req = (syn and syn.request) or request or http_request
	if req then
		local ok, res = pcall(req, { Url = url, Method = "GET" })
		if ok and res and (res.StatusCode == 200 or res.Success) then
			return res.Body
		end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	return ok and body or nil
end
local function FetchJson(url)
	local body = HttpFetch(url)
	if not body then return nil end
	local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
	return ok and data or nil
end
local function GetChar()
	return LocalPlayer.Character
end
local function GetHum()
	local char = GetChar()
	return char and char:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
	local char = GetChar()
	return char and char:FindFirstChild("HumanoidRootPart")
end
do
	local frames, elapsed = 0, 0
	Track(RunService.RenderStepped:Connect(function(dt)
		frames  += 1
		elapsed += dt
		if elapsed >= 0.5 then
			FPS = math.floor(frames / elapsed + 0.5)
			frames, elapsed = 0, 0
		end
	end))
end
local function GetPing()
	local ok, item = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]
	end)
	if not ok or not item then return 0 end
	local okV, value = pcall(function() return item:GetValue() end)
	if okV and tonumber(value) then
		return math.floor(value + 0.5)
	end
	okV, value = pcall(function()
		return tonumber(item:GetValueString():gsub(",", "."):match("[%d%.]+"))
	end)
	return (okV and tonumber(value)) and math.floor(value + 0.5) or 0
end
local function GetSpeed()
	local root = GetHRP()
	if not root then return 0 end
	local v = root.AssemblyLinearVelocity
	return math.floor(Vector3.new(v.X, 0, v.Z).Magnitude + 0.5)
end
local function FormatTime(sec)
	sec = math.floor(sec)
	return string.format("%02d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
end
local function Clipboard(text)
	local write = setclipboard or toclipboard or (syn and syn.write_clipboard)
	if write then
		pcall(write, text)
		return true
	end
	return false
end
local function Notify(title, content, icon, duration)
	WindUI:Notify({
		Title    = title,
		Content  = content,
		Icon     = icon or "info",
		Duration = duration or 3,
	})
end
local function CopyWithToast(text, label)
	if Clipboard(text) then
		Notify("Copied", label, "copy", 2)
	else
		Notify("Failed", "Clipboard is not available in this executor", "circle-alert", 3)
	end
end
local HISTORY_FILE = "QOLHub/history.json"
local History = {}
local function LoadHistory()
	pcall(function()
		if isfile and isfile(HISTORY_FILE) then
			local data = HttpService:JSONDecode(readfile(HISTORY_FILE))
			if type(data) == "table" then History = data end
		end
	end)
end
local function SaveHistory()
	pcall(function()
		if writefile then
			if makefolder and not (isfolder and isfolder("QOLHub")) then
				makefolder("QOLHub")
			end
			writefile(HISTORY_FILE, HttpService:JSONEncode(History))
		end
	end)
end
local function PushHistory()
	if game.JobId == "" then return end
	table.insert(History, 1, {
		jobId   = game.JobId,
		placeId = game.PlaceId,
		time    = os.time(),
	})
	while #History > 10 do table.remove(History) end
	SaveHistory()
end
LoadHistory()
local Overlay = Instance.new("ScreenGui")
Overlay.Name           = "QOL_Overlay"
Overlay.ResetOnSpawn   = false
Overlay.IgnoreGuiInset = true
Overlay.DisplayOrder   = 999
local Box = Instance.new("Frame")
Box.AnchorPoint            = Vector2.new(0.5, 0)
Box.Position               = UDim2.new(0.5, 0, 0, 6)
Box.Size                   = UDim2.fromOffset(230, 28)
Box.BackgroundColor3       = Color3.fromRGB(12, 12, 16)
Box.BackgroundTransparency = 0.2
Box.BorderSizePixel        = 0
Box.Parent                 = Overlay
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent       = Box
local Stroke = Instance.new("UIStroke")
Stroke.Color        = Color3.fromRGB(90, 90, 105)
Stroke.Transparency = 0.5
Stroke.Parent       = Box
local Label = Instance.new("TextLabel")
Label.BackgroundTransparency = 1
Label.Size       = UDim2.fromScale(1, 1)
Label.Font       = Enum.Font.GothamBold
Label.TextSize   = 14
Label.TextColor3 = Color3.fromRGB(240, 240, 245)
Label.Text       = "FPS --  ·  PING --"
Label.Parent     = Box
pcall(function()
	local parent = (gethui and gethui()) or game:GetService("CoreGui")
	local old = parent:FindFirstChild("QOL_Overlay")
	if old then old:Destroy() end
end)
if not pcall(function()
	Overlay.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end) then
	Overlay.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function SyncOverlay()
	Box.Visible = OverlayEnabled and not CleanScreen
end
local Cross = Instance.new("ScreenGui")
Cross.Name           = "QOL_Crosshair"
Cross.ResetOnSpawn   = false
Cross.IgnoreGuiInset = true
Cross.DisplayOrder   = 998
Cross.Enabled        = false
pcall(function()
	Cross.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not Cross.Parent then Cross.Parent = LocalPlayer:WaitForChild("PlayerGui") end
local CrossColor = Color3.fromRGB(255, 255, 255)
local CrossSize  = 8
local CrossStyle = "Cross"
local CrossParts = {}
local function RebuildCrosshair()
	for _, p in ipairs(CrossParts) do p:Destroy() end
	table.clear(CrossParts)
	local function part(w, h, dx, dy)
		local f = Instance.new("Frame")
		f.AnchorPoint      = Vector2.new(0.5, 0.5)
		f.Position         = UDim2.new(0.5, dx, 0.5, dy)
		f.Size             = UDim2.fromOffset(w, h)
		f.BackgroundColor3 = CrossColor
		f.BorderSizePixel  = 0
		f.Parent           = Cross
		table.insert(CrossParts, f)
		return f
	end
	if CrossStyle == "Dot" then
		local d = part(CrossSize, CrossSize, 0, 0)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = d
	else
		local gap, len, thick = 4, CrossSize, 2
		part(len, thick, -(gap + len // 2), 0)
		part(len, thick,  (gap + len // 2), 0)
		part(thick, len, 0, -(gap + len // 2))
		part(thick, len, 0,  (gap + len // 2))
	end
end
RebuildCrosshair()
local function ApplyMovement()
	local hum = GetHum()
	if not hum then return end
	if Move.WalkSpeedOn then hum.WalkSpeed = Move.WalkSpeed end
	if Move.JumpOn then
		if hum.UseJumpPower then hum.JumpPower = Move.JumpValue
		else hum.JumpHeight = Move.JumpValue end
	end
end
local function ResetMovement()
	local hum = GetHum()
	if hum then
		hum.WalkSpeed = 16
		if hum.UseJumpPower then hum.JumpPower = 50 else hum.JumpHeight = 7.2 end
	end
end
Track(LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	if Running then ApplyMovement() end
end))
Track(UserInputService.JumpRequest:Connect(function()
	if Running and Move.InfJump then
		local hum = GetHum()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end))
local flyBV, flyGyro
local function StopFly()
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyGyro then flyGyro:Destroy() flyGyro = nil end
	local hum = GetHum()
	if hum then hum.PlatformStand = false end
end
Track(RunService.RenderStepped:Connect(function()
	if not Running or not Move.Fly then return end
	local hrp, hum = GetHRP(), GetHum()
	if not hrp or not hum then return end
	if not flyBV or flyBV.Parent ~= hrp then
		StopFly()
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		flyBV.Velocity = Vector3.zero
		flyBV.Parent = hrp
		flyGyro = Instance.new("BodyGyro")
		flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		flyGyro.P = 9e4
		flyGyro.Parent = hrp
		hum.PlatformStand = true
	end
	local cam = workspace.CurrentCamera
	local dir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
	flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * Move.FlySpeed
	flyGyro.CFrame = cam.CFrame
end))
local NoclipParts = {}
local function HookNoclipCache(char)
	table.clear(NoclipParts)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(NoclipParts, part)
		end
	end
	Track(char.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then table.insert(NoclipParts, d) end
	end))
end
if GetChar() then HookNoclipCache(GetChar()) end
Track(LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	if Running then HookNoclipCache(char) end
end))
Track(RunService.Stepped:Connect(function()
	if not Running or not Move.Noclip then return end
	for _, part in ipairs(NoclipParts) do
		if part.Parent and part.CanCollide then
			part.CanCollide = false
		end
	end
end))
local spinBAV
local function SetSpin(state)
	Move.Spin = state
	if state then
		local hrp = GetHRP()
		if hrp then
			spinBAV = Instance.new("BodyAngularVelocity")
			spinBAV.MaxTorque = Vector3.new(0, 9e9, 0)
			spinBAV.AngularVelocity = Vector3.new(0, Move.SpinSpeed, 0)
			spinBAV.Parent = hrp
		end
	elseif spinBAV then
		spinBAV:Destroy()
		spinBAV = nil
	end
end
task.spawn(function()
	while Running do
		task.wait(1)
		local hrp, hum = GetHRP(), GetHum()
		if hrp and hum and hum.FloorMaterial ~= Enum.Material.Air then
			Move.LastSafePos = hrp.CFrame
		end
	end
end)
Track(RunService.Heartbeat:Connect(function()
	if not Running or not Move.AntiVoid then return end
	local hrp = GetHRP()
	if hrp and hrp.Position.Y < (workspace.FallenPartsDestroyHeight or -500) + 50 then
		if Move.LastSafePos then
			hrp.CFrame = Move.LastSafePos + Vector3.new(0, 5, 0)
			hrp.AssemblyLinearVelocity = Vector3.zero
		end
	end
end))
local EspObjects = {}
local function RemoveEsp(player)
	local obj = EspObjects[player]
	if obj then
		if obj.highlight then pcall(function() obj.highlight:Destroy() end) end
		if obj.billboard then pcall(function() obj.billboard:Destroy() end) end
		EspObjects[player] = nil
	end
end
local function CreateEsp(player)
	if player == LocalPlayer then return end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	RemoveEsp(player)
	local obj = {}
	if Esp.Highlight then
		local hl = Instance.new("Highlight")
		hl.FillColor = Color3.fromRGB(255, 80, 80)
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.FillTransparency = 0.6
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Adornee = char
		hl.Parent = char
		obj.highlight = hl
	end
	if Esp.Names then
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0, 200, 0, 40)
		bb.StudsOffset = Vector3.new(0, 3, 0)
		bb.AlwaysOnTop = true
		bb.Adornee = hrp
		bb.Parent = hrp
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0.3
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Name = "ESPLabel"
		label.Parent = bb
		obj.billboard = bb
	end
	EspObjects[player] = obj
end
local function RefreshAllEsp()
	for _, p in ipairs(Players:GetPlayers()) do
		if Esp.Names or Esp.Highlight then CreateEsp(p) else RemoveEsp(p) end
	end
end
local function ClearAllEsp()
	for player in pairs(EspObjects) do RemoveEsp(player) end
end
Track(RunService.Heartbeat:Connect(function()
	if not Running or not Esp.Names then return end
	local myHRP = GetHRP()
	if not myHRP then return end
	for player, obj in pairs(EspObjects) do
		if obj.billboard and obj.billboard.Parent then
			local label = obj.billboard:FindFirstChild("ESPLabel")
			local tHRP = obj.billboard.Adornee
			if label and tHRP then
				local dist = math.floor((tHRP.Position - myHRP.Position).Magnitude)
				label.Text = player.DisplayName .. " [" .. dist .. "m]"
			end
		end
	end
end))
local function HookEspRespawn(p)
	Track(p.CharacterAdded:Connect(function()
		task.wait(1)
		if Running and (Esp.Names or Esp.Highlight) then CreateEsp(p) end
	end))
end
for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then HookEspRespawn(p) end
end
local function Rejoin()
	local ok, err = pcall(function()
		if #Players:GetPlayers() <= 1 then
			TeleportService:Teleport(game.PlaceId, LocalPlayer)
		else
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end
	end)
	if not ok then
		Notify("Error", tostring(err), "circle-alert", 5)
	end
end
local HopMinPlayers = 0
local function ServerHop()
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
		.. "/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=100"
	local data = FetchJson(url)
	if not data or not data.data then
		Notify("Error", "Could not fetch the server list", "circle-alert", 4)
		return
	end
	local candidates = {}
	for _, server in ipairs(data.data) do
		if server.id ~= game.JobId and server.playing and server.maxPlayers
			and server.playing < server.maxPlayers
			and server.playing >= HopMinPlayers then
			table.insert(candidates, server.id)
		end
	end
	if #candidates == 0 then
		Notify("Empty", "No servers matching the filter", "circle-alert", 4)
		return
	end
	PushHistory()
	Notify("Server Hop", "Jumping to another server...", "shuffle", 3)
	TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[math.random(1, #candidates)], LocalPlayer)
end
local function ReturnToPrevious()
	local prev = History[1]
	if not prev then
		Notify("History", "No previous server recorded", "circle-alert", 3)
		return
	end
	if prev.jobId == game.JobId then
		table.remove(History, 1)
		prev = History[1]
		if not prev then
			Notify("History", "No previous server recorded", "circle-alert", 3)
			return
		end
	end
	Notify("History", "Returning to previous server...", "undo-2", 3)
	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(prev.placeId, prev.jobId, LocalPlayer)
	end)
	if not ok then
		Notify("Error", "That server is probably gone", "circle-alert", 4)
	end
end
local function Respawn()
	local char = GetChar()
	if not char then
		Notify("No character", "Wait for the respawn", "circle-alert", 3)
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Health = 0
	else
		pcall(function() char:BreakJoints() end)
	end
end
local function SetNamesHidden(state)
	NamesHidden = state
	for _, plr in ipairs(Players:GetPlayers()) do
		local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function()
				hum.DisplayDistanceType = state
					and Enum.HumanoidDisplayDistanceType.None
					or Enum.HumanoidDisplayDistanceType.Viewer
			end)
		end
	end
end
local Window = WindUI:CreateWindow({
	Title        = "QOL Hub",
	Icon         = "zap",
	Author       = "v4",
	Folder       = "QOLHub",
	Size         = UDim2.fromOffset(580, 460),
	Theme        = "Dark",
	Transparent  = true,
	SideBarWidth = 165,
	User = {
		Enabled   = true,
		Anonymous = false,
		Callback  = function()
			CopyWithToast(LocalPlayer.Name, "@" .. LocalPlayer.Name)
		end,
	},
})
pcall(function()
	Window:Tag({ Title = "@" .. LocalPlayer.Name, Icon = "user", Border = true })
end)
local MainTab = Window:Tab({ Title = "Main",        Icon = "gauge" })
local MovTab  = Window:Tab({ Title = "Player",      Icon = "user" })
local TPTab   = Window:Tab({ Title = "Teleport",    Icon = "map-pin" })
local ESPTab  = Window:Tab({ Title = "ESP",         Icon = "scan-eye" })
local VisTab  = Window:Tab({ Title = "Visual",      Icon = "eye" })
local PerfTab = Window:Tab({ Title = "Performance", Icon = "cpu" })
local PlrTab  = Window:Tab({ Title = "Players",     Icon = "users" })
local UITab   = Window:Tab({ Title = "Interface",   Icon = "layout-dashboard" })
Window:SelectTab(1)
local Config
pcall(function()
	Config = Window.ConfigManager:CreateConfig("qol_hub")
end)
MainTab:Section({ Title = "Stats" })
local Info = MainTab:Paragraph({
	Title     = "FPS: --   ·   Ping: -- ms",
	Desc      = "Measuring...",
	Image     = "activity",
	ImageSize = 22,
})
MainTab:Toggle({
	Flag  = "Overlay",
	Title = "On-screen overlay",
	Desc  = "FPS and ping counter on top of the game",
	Icon  = "monitor",
	Value = true,
	Callback = function(state)
		OverlayEnabled = state
		SyncOverlay()
	end,
})
MainTab:Toggle({
	Flag  = "SpeedInOverlay",
	Title = "Show speed in overlay",
	Desc  = "Horizontal speed of your character (studs/s)",
	Icon  = "gauge",
	Value = false,
	Callback = function(state)
		ShowSpeed = state
		Box.Size = UDim2.fromOffset(state and 300 or 230, 28)
	end,
})
MainTab:Section({ Title = "This game" })
local GameInfo = MainTab:Paragraph({
	Title     = "Game info",
	Desc      = "Press the button to load",
	Image     = "info",
	ImageSize = 22,
	Buttons   = {
		{
			Title = "Load",
			Icon  = "download",
			Callback = function()
				task.spawn(function()
					local data = FetchJson("https://games.roblox.com/v1/games?universeIds=" .. game.GameId)
					local g = data and data.data and data.data[1]
					if not g then
						Notify("Error", "Could not load game info", "circle-alert", 3)
						return
					end
					pcall(function()
						GameInfo:SetTitle(tostring(g.name))
						GameInfo:SetDesc(string.format(
							"by %s  ·  playing now: %s  ·  visits: %s  ·  created: %s",
							tostring(g.creator and g.creator.name or "?"),
							tostring(g.playing or "?"),
							tostring(g.visits or "?"),
							tostring(g.created and g.created:sub(1, 10) or "?")
						))
					end)
				end)
			end,
		},
	},
})
MainTab:Section({ Title = "Server" })
MainTab:Button({
	Title = "Rejoin",
	Desc  = "Reconnect to this same server",
	Icon  = "refresh-cw",
	Callback = function()
		Notify("Rejoin", "Reconnecting...", "refresh-cw", 2)
		PushHistory()
		task.wait(0.3)
		Rejoin()
	end,
})
MainTab:Button({
	Title = "Server Hop",
	Desc  = "Teleport to a random different server",
	Icon  = "shuffle",
	Callback = ServerHop,
})
MainTab:Slider({
	Flag  = "HopMinPlayers",
	Title = "Hop filter: minimum players",
	Desc  = "0 = any server, higher = livelier servers",
	Step  = 1,
	Value = { Min = 0, Max = 30, Default = 0 },
	Callback = function(value) HopMinPlayers = value end,
})
MainTab:Button({
	Title = "Return to previous server",
	Desc  = "Go back to where you were before the last hop",
	Icon  = "undo-2",
	Callback = ReturnToPrevious,
})
MainTab:Toggle({
	Flag  = "AutoRejoin",
	Title = "Auto-rejoin on disconnect",
	Desc  = "Catches the 'Disconnected' prompt and joins back",
	Icon  = "plug-zap",
	Value = false,
	Callback = function(state) AutoRejoin = state end,
})
MainTab:Section({ Title = "Copy" })
MainTab:Button({
	Title = "Copy JobId",
	Icon  = "copy",
	Callback = function() CopyWithToast(game.JobId, "Server JobId") end,
})
MainTab:Button({
	Title = "Copy PlaceId",
	Icon  = "copy",
	Callback = function() CopyWithToast(tostring(game.PlaceId), "PlaceId") end,
})
MainTab:Button({
	Title = "Copy game link",
	Icon  = "link",
	Callback = function()
		CopyWithToast("https://www.roblox.com/games/" .. game.PlaceId, "Game link")
	end,
})
MainTab:Button({
	Title = "Copy invite link",
	Desc  = "Web link that joins this exact server",
	Icon  = "link",
	Callback = function()
		CopyWithToast(
			"https://www.roblox.com/games/start?placeId=" .. game.PlaceId
				.. "&gameInstanceId=" .. game.JobId,
			"Invite link"
		)
	end,
})
MainTab:Section({ Title = "Character" })
MainTab:Button({
	Title = "Respawn",
	Desc  = "Kill the character (same as the Reset button)",
	Icon  = "skull",
	Callback = Respawn,
})
task.spawn(function()
	pcall(function()
		local prompt = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui", 10)
		local overlay = prompt and prompt:WaitForChild("promptOverlay", 10)
		if overlay then
			Track(overlay.ChildAdded:Connect(function(child)
				if AutoRejoin and child.Name == "ErrorPrompt" then
					task.wait(1)
					Rejoin()
				end
			end))
		end
	end)
end)
MovTab:Section({ Title = "Movement" })
MovTab:Toggle({
	Flag  = "WalkSpeedOn",
	Title = "WalkSpeed",
	Desc  = "Custom walking speed",
	Icon  = "footprints",
	Value = false,
	Callback = function(state)
		Move.WalkSpeedOn = state
		if state then ApplyMovement() else ResetMovement() ; if Move.JumpOn then ApplyMovement() end end
	end,
})
MovTab:Slider({
	Flag  = "WalkSpeed",
	Title = "Speed",
	Step  = 1,
	Value = { Min = 16, Max = 300, Default = 16 },
	Callback = function(value)
		Move.WalkSpeed = value
		if Move.WalkSpeedOn then ApplyMovement() end
	end,
})
MovTab:Toggle({
	Flag  = "JumpOn",
	Title = "Jump (Power/Height)",
	Desc  = "Custom jump strength",
	Icon  = "arrow-up",
	Value = false,
	Callback = function(state)
		Move.JumpOn = state
		if state then ApplyMovement() else ResetMovement() ; if Move.WalkSpeedOn then ApplyMovement() end end
	end,
})
MovTab:Slider({
	Flag  = "JumpValue",
	Title = "Jump strength",
	Step  = 1,
	Value = { Min = 50, Max = 500, Default = 50 },
	Callback = function(value)
		Move.JumpValue = value
		if Move.JumpOn then ApplyMovement() end
	end,
})
MovTab:Toggle({
	Flag  = "InfJump",
	Title = "Infinite Jump",
	Desc  = "Jump again while in the air",
	Icon  = "chevrons-up",
	Value = false,
	Callback = function(state) Move.InfJump = state end,
})
MovTab:Section({ Title = "Flight" })
MovTab:Toggle({
	Flag  = "Fly",
	Title = "Fly (WASD + Space/Ctrl)",
	Desc  = "Camera-relative flight",
	Icon  = "feather",
	Value = false,
	Callback = function(state)
		Move.Fly = state
		if not state then StopFly() end
	end,
})
MovTab:Slider({
	Flag  = "FlySpeed",
	Title = "Fly speed",
	Step  = 5,
	Value = { Min = 10, Max = 300, Default = 60 },
	Callback = function(v) Move.FlySpeed = v end,
})
MovTab:Toggle({
	Flag  = "Noclip",
	Title = "Noclip",
	Desc  = "Walk through walls",
	Icon  = "ghost",
	Value = false,
	Callback = function(state) Move.Noclip = state end,
})
MovTab:Section({ Title = "Misc" })
MovTab:Toggle({
	Flag  = "AutoJump",
	Title = "Auto Jump",
	Desc  = "Jumps automatically every half a second",
	Icon  = "repeat",
	Value = false,
	Callback = function(state)
		Move.AutoJump = state
		task.spawn(function()
			while Running and Move.AutoJump do
				local hum = GetHum()
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
				task.wait(0.5)
			end
		end)
	end,
})
MovTab:Toggle({
	Title = "Spin",
	Desc  = "Character keeps rotating",
	Icon  = "rotate-cw",
	Value = false,
	Callback = SetSpin,
})
MovTab:Slider({
	Flag  = "SpinSpeed",
	Title = "Spin speed",
	Step  = 1,
	Value = { Min = 1, Max = 50, Default = 5 },
	Callback = function(v)
		Move.SpinSpeed = v
		if spinBAV then spinBAV.AngularVelocity = Vector3.new(0, v, 0) end
	end,
})
MovTab:Toggle({
	Title = "Freeze",
	Desc  = "Anchor the character in place",
	Icon  = "snowflake",
	Value = false,
	Callback = function(state)
		Move.Freeze = state
		local hrp = GetHRP()
		if hrp then hrp.Anchored = state end
	end,
})
MovTab:Button({
	Title = "Sit / stand up",
	Icon  = "armchair",
	Callback = function()
		local hum = GetHum()
		if hum then hum.Sit = not hum.Sit end
	end,
})
MovTab:Button({
	Title = "Reset movement",
	Desc  = "Restore default speed and jump",
	Icon  = "rotate-ccw",
	Callback = function()
		Move.WalkSpeedOn, Move.JumpOn = false, false
		ResetMovement()
		Notify("QOL Hub", "Movement reset", "check", 2)
	end,
})
TPTab:Section({ Title = "To players" })
local selectedPlayer = nil
local function PlayerNames()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then table.insert(names, p.Name) end
	end
	return names
end
local playerDropdown = TPTab:Dropdown({
	Title  = "Select player",
	Values = PlayerNames(),
	Value  = nil,
	Callback = function(option) selectedPlayer = option end,
})
TPTab:Button({
	Title = "Refresh player list",
	Icon  = "refresh-cw",
	Callback = function()
		pcall(function() playerDropdown:Refresh(PlayerNames()) end)
		Notify("QOL Hub", "List refreshed", "refresh-cw", 2)
	end,
})
local function TpToPlayer(name)
	local target = Players:FindFirstChild(name)
	local myHRP = GetHRP()
	if target and target.Character and myHRP then
		local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
		if tHRP then
			myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
			return true
		end
	end
	return false
end
TPTab:Button({
	Title = "TP to selected player",
	Icon  = "locate",
	Callback = function()
		if selectedPlayer and TpToPlayer(selectedPlayer) then
			Notify("QOL Hub", "Teleported to " .. selectedPlayer, "check", 2)
		else
			Notify("QOL Hub", "Player not found", "circle-alert", 3)
		end
	end,
})
TPTab:Button({
	Title = "TP to random player",
	Icon  = "dices",
	Callback = function()
		local list = PlayerNames()
		if #list > 0 then TpToPlayer(list[math.random(1, #list)]) end
	end,
})
TPTab:Section({ Title = "Positioning" })
TPTab:Toggle({
	Flag  = "ClickTP",
	Title = "Click TP",
	Desc  = "Ctrl + LMB = teleport to the clicked spot",
	Icon  = "mouse-pointer-click",
	Value = false,
	Callback = function(state) Move.ClickTP = state end,
})
local Mouse = LocalPlayer:GetMouse()
Track(Mouse.Button1Down:Connect(function()
	if Running and Move.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local hrp = GetHRP()
		if hrp and Mouse.Hit then
			hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 4, 0))
		end
	end
end))
TPTab:Button({
	Title = "TP forward 10 studs",
	Icon  = "arrow-right",
	Callback = function()
		local hrp = GetHRP()
		if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -10) end
	end,
})
TPTab:Toggle({
	Flag  = "AntiVoid",
	Title = "Anti-Void",
	Desc  = "Teleports you back to safety when falling into the void",
	Icon  = "shield",
	Value = false,
	Callback = function(state) Move.AntiVoid = state end,
})
TPTab:Section({ Title = "Waypoints" })
local waypointName = "spot1"
local selectedWaypoint = nil
local waypointDropdown
TPTab:Input({
	Title = "Waypoint name",
	Value = "spot1",
	Placeholder = "Enter a name...",
	Callback = function(text)
		if text and text ~= "" then waypointName = text end
	end,
})
TPTab:Button({
	Title = "Save waypoint",
	Desc  = "Remember the current position",
	Icon  = "bookmark",
	Callback = function()
		local hrp = GetHRP()
		if hrp then
			Waypoints[waypointName] = hrp.CFrame
			local names = {}
			for n in pairs(Waypoints) do table.insert(names, n) end
			table.sort(names)
			pcall(function() waypointDropdown:Refresh(names) end)
			Notify("QOL Hub", "Saved: " .. waypointName, "bookmark", 2)
		end
	end,
})
waypointDropdown = TPTab:Dropdown({
	Title  = "Select waypoint",
	Values = {},
	Callback = function(option) selectedWaypoint = option end,
})
TPTab:Button({
	Title = "TP to waypoint",
	Icon  = "map-pin",
	Callback = function()
		local hrp = GetHRP()
		if hrp and selectedWaypoint and Waypoints[selectedWaypoint] then
			hrp.CFrame = Waypoints[selectedWaypoint]
		end
	end,
})
TPTab:Button({
	Title = "Delete all waypoints",
	Icon  = "trash-2",
	Callback = function()
		table.clear(Waypoints)
		pcall(function() waypointDropdown:Refresh({}) end)
	end,
})
ESPTab:Section({ Title = "Players" })
ESPTab:Toggle({
	Flag  = "EspNames",
	Title = "Names + distance",
	Desc  = "Nickname and distance above heads",
	Icon  = "tag",
	Value = false,
	Callback = function(state)
		Esp.Names = state
		RefreshAllEsp()
	end,
})
ESPTab:Toggle({
	Flag  = "EspHighlight",
	Title = "Highlight",
	Desc  = "Players visible through walls",
	Icon  = "lightbulb",
	Value = false,
	Callback = function(state)
		Esp.Highlight = state
		RefreshAllEsp()
	end,
})
ESPTab:Button({
	Title = "Refresh ESP",
	Icon  = "refresh-cw",
	Callback = function()
		RefreshAllEsp()
		Notify("QOL Hub", "ESP refreshed", "refresh-cw", 2)
	end,
})
VisTab:Section({ Title = "Crosshair" })
VisTab:Toggle({
	Flag  = "Crosshair",
	Title = "Custom crosshair",
	Desc  = "Cosmetic overlay in the middle of the screen",
	Icon  = "crosshair",
	Value = false,
	Callback = function(state) Cross.Enabled = state end,
})
VisTab:Dropdown({
	Flag   = "CrossStyle",
	Title  = "Style",
	Values = { "Cross", "Dot" },
	Value  = "Cross",
	Callback = function(style)
		CrossStyle = style
		RebuildCrosshair()
	end,
})
VisTab:Slider({
	Flag  = "CrossSize",
	Title = "Size",
	Step  = 1,
	Value = { Min = 4, Max = 20, Default = 8 },
	Callback = function(value)
		CrossSize = value
		RebuildCrosshair()
	end,
})
VisTab:Dropdown({
	Flag   = "CrossColor",
	Title  = "Color",
	Values = { "White", "Red", "Green", "Cyan", "Yellow", "Magenta" },
	Value  = "White",
	Callback = function(name)
		CrossColor = ({
			White   = Color3.fromRGB(255, 255, 255),
			Red     = Color3.fromRGB(255, 70, 70),
			Green   = Color3.fromRGB(80, 255, 120),
			Cyan    = Color3.fromRGB(80, 220, 255),
			Yellow  = Color3.fromRGB(255, 230, 80),
			Magenta = Color3.fromRGB(255, 90, 220),
		})[name] or Color3.new(1, 1, 1)
		RebuildCrosshair()
	end,
})
VisTab:Section({ Title = "Camera" })
VisTab:Slider({
	Flag  = "FOV",
	Title = "Field of view",
	Desc  = "Default is 70",
	Step  = 1,
	Value = { Min = 40, Max = 120, Default = math.floor(DefaultFOV) },
	Callback = function(value)
		pcall(function() workspace.CurrentCamera.FieldOfView = value end)
	end,
})
VisTab:Button({
	Title = "Reset FOV",
	Icon  = "rotate-ccw",
	Callback = function()
		pcall(function() workspace.CurrentCamera.FieldOfView = DefaultFOV end)
	end,
})
VisTab:Button({
	Title = "Unlock zoom",
	Desc  = "Remove the camera zoom-out limit",
	Icon  = "zoom-out",
	Callback = function()
		LocalPlayer.CameraMaxZoomDistance = math.huge
		Notify("QOL Hub", "Zoom unlocked", "check", 2)
	end,
})
VisTab:Section({ Title = "Lighting & world" })
VisTab:Toggle({
	Flag  = "Fullbright",
	Title = "Fullbright",
	Desc  = "Maximum brightness, no darkness",
	Icon  = "sun",
	Value = false,
	Callback = function(state)
		if state then
			Lighting.Brightness    = 2
			Lighting.ClockTime     = 14
			Lighting.GlobalShadows = false
			Lighting.Ambient       = Color3.fromRGB(178, 178, 178)
		else
			Lighting.Brightness    = OriginalLighting.Brightness
			Lighting.ClockTime     = OriginalLighting.ClockTime
			Lighting.GlobalShadows = OriginalLighting.GlobalShadows
			Lighting.Ambient       = OriginalLighting.Ambient
		end
	end,
})
VisTab:Toggle({
	Flag  = "NoFog",
	Title = "No Fog",
	Desc  = "Remove fog",
	Icon  = "cloud-off",
	Value = false,
	Callback = function(state)
		Lighting.FogEnd = state and 1e9 or OriginalLighting.FogEnd
	end,
})
VisTab:Slider({
	Flag  = "ClockTime",
	Title = "Time of day",
	Step  = 1,
	Value = { Min = 0, Max = 24, Default = math.floor(OriginalLighting.ClockTime) },
	Callback = function(v) Lighting.ClockTime = v end,
})
VisTab:Slider({
	Flag  = "Gravity",
	Title = "Gravity",
	Desc  = "Default is 196",
	Step  = 5,
	Value = { Min = 0, Max = 350, Default = math.floor(DefaultGravity) },
	Callback = function(v) workspace.Gravity = v end,
})
VisTab:Section({ Title = "Screenshot mode" })
VisTab:Toggle({
	Flag  = "HideNames",
	Title = "Hide player names",
	Desc  = "Hides nametags above characters (client-side)",
	Icon  = "venetian-mask",
	Value = false,
	Callback = SetNamesHidden,
})
VisTab:Button({
	Title = "Screenshot mode: everything off",
	Desc  = "Hides Roblox UI, this hub, overlay and nametags for 5 seconds",
	Icon  = "camera",
	Callback = function()
		local namesWere = NamesHidden
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
		pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
		SetNamesHidden(true)
		Box.Visible = false
		Cross.Enabled = false
		pcall(function() Window:ToggleUI() end)
		task.delay(5, function()
			if not Running then return end
			pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not CleanScreen) end)
			pcall(function() StarterGui:SetCore("TopbarEnabled", not CleanScreen) end)
			SetNamesHidden(namesWere)
			SyncOverlay()
			pcall(function() Window:ToggleUI() end)
			Notify("Screenshot mode", "Back to normal", "camera", 2)
		end)
	end,
})
PerfTab:Section({ Title = "Graphics presets" })
local Saved = {}
local SavedCaptured = false
local function CaptureDefaults()
	if SavedCaptured then return end
	SavedCaptured = true
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	pcall(function()
		Saved.Quality       = settings().Rendering.QualityLevel
		Saved.GlobalShadows = Lighting.GlobalShadows
		Saved.FogEnd        = Lighting.FogEnd
		if terrain then
			Saved.WaveSize     = terrain.WaterWaveSize
			Saved.WaveSpeed    = terrain.WaterWaveSpeed
			Saved.Reflectance  = terrain.WaterReflectance
			Saved.Transparency = terrain.WaterTransparency
			Saved.Decoration   = terrain.Decoration
		end
	end)
end
local function ApplyPreset(name)
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	CaptureDefaults()
	if name == "Default" then
		pcall(function() settings().Rendering.QualityLevel = Saved.Quality or Enum.QualityLevel.Automatic end)
		pcall(function()
			if Saved.GlobalShadows ~= nil then Lighting.GlobalShadows = Saved.GlobalShadows end
			if Saved.FogEnd then Lighting.FogEnd = Saved.FogEnd end
		end)
		if terrain then
			pcall(function()
				terrain.WaterWaveSize     = Saved.WaveSize or 0.15
				terrain.WaterWaveSpeed    = Saved.WaveSpeed or 10
				terrain.WaterReflectance  = Saved.Reflectance or 1
				terrain.WaterTransparency = Saved.Transparency or 0.3
				if Saved.Decoration ~= nil then terrain.Decoration = Saved.Decoration end
			end)
		end
		Notify("Graphics", "Restored defaults", "check", 2)
		return
	end
	local level = (name == "Ultra Low") and Enum.QualityLevel.Level01
		or (name == "Low") and Enum.QualityLevel.Level03
		or Enum.QualityLevel.Level07
	pcall(function() settings().Rendering.QualityLevel = level end)
	if name == "Ultra Low" or name == "Low" then
		pcall(function()
			Lighting.GlobalShadows = false
			if name == "Ultra Low" then Lighting.FogEnd = 9e9 end
		end)
		if terrain and name == "Ultra Low" then
			pcall(function()
				terrain.WaterWaveSize     = 0
				terrain.WaterWaveSpeed    = 0
				terrain.WaterReflectance  = 0
				terrain.WaterTransparency = 0
				terrain.Decoration        = false
			end)
		end
	end
	Notify("Graphics", name .. " applied", "zap", 2)
end
PerfTab:Dropdown({
	Flag   = "GfxPreset",
	Title  = "Quality preset",
	Values = { "Default", "Medium", "Low", "Ultra Low" },
	Value  = "Default",
	Callback = ApplyPreset,
})
PerfTab:Section({ Title = "Granular" })
PerfTab:Toggle({
	Flag  = "NoParticles",
	Title = "Disable particles",
	Desc  = "Turns off emitters, trails, smoke, fire (new ones too)",
	Icon  = "sparkles",
	Value = false,
	Callback = function(state)
		local classes = { "ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles" }
		local function isEffect(v)
			for _, c in ipairs(classes) do
				if v:IsA(c) then return true end
			end
			return false
		end
		if state then
			task.spawn(function()
				local n = 0
				for _, v in ipairs(workspace:GetDescendants()) do
					n += 1
					if n % 800 == 0 then task.wait() end
					if isEffect(v) then pcall(function() v.Enabled = false end) end
				end
			end)
			Saved.ParticleConn = Track(workspace.DescendantAdded:Connect(function(v)
				if isEffect(v) then pcall(function() v.Enabled = false end) end
			end))
		else
			if Saved.ParticleConn then
				Saved.ParticleConn:Disconnect()
				Saved.ParticleConn = nil
			end
			Notify("Particles", "New effects allowed again. Existing ones stay off until rejoin.", "info", 4)
		end
	end,
})
PerfTab:Button({
	Title = "Strip textures and effects",
	Desc  = "Big boost, but only revertible by rejoining",
	Icon  = "eraser",
	Callback = function()
		Window:Dialog({
			Title   = "Are you sure?",
			Content = "All textures, decals and particles will be removed until you rejoin the server.",
			Buttons = {
				{ Title = "Cancel" },
				{
					Title   = "Strip",
					Variant = "Primary",
					Callback = function()
						task.spawn(function()
							local char = GetChar()
							local count = 0
							for _, v in ipairs(workspace:GetDescendants()) do
								count += 1
								if count % 700 == 0 then task.wait() end
								if char and v:IsDescendantOf(char) then continue end
								pcall(function()
									if v:IsA("BasePart") then
										v.Material    = Enum.Material.SmoothPlastic
										v.Reflectance = 0
										v.CastShadow  = false
									elseif v:IsA("Decal") or v:IsA("Texture") then
										v.Transparency = 1
									elseif v:IsA("ParticleEmitter") or v:IsA("Trail")
										or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
										v.Enabled = false
									end
								end)
							end
							Notify("Done", "Objects processed: " .. count, "check", 4)
						end)
					end,
				},
			},
		})
	end,
})
PerfTab:Section({ Title = "Frame cap" })
PerfTab:Slider({
	Flag  = "FPSCap",
	Title = "FPS cap",
	Desc  = "Works if your executor supports setfpscap",
	Step  = 10,
	Value = { Min = 30, Max = 360, Default = 240 },
	Callback = function(value)
		local cap = setfpscap or set_fps_cap or (syn and syn.set_fps_cap)
		if cap then pcall(cap, value) end
	end,
})
PerfTab:Section({ Title = "Sound" })
PerfTab:Slider({
	Flag  = "Volume",
	Title = "Master volume",
	Step  = 5,
	Value = { Min = 0, Max = 100, Default = 100 },
	Callback = function(value)
		pcall(function()
			game:GetService("UserSettings"):GetService("UserGameSettings").MasterVolume = value / 100
		end)
	end,
})
PerfTab:Section({ Title = "Other" })
local AfkInfo
PerfTab:Toggle({
	Flag  = "AntiAFK",
	Title = "Anti-AFK",
	Desc  = "Prevents the 20 minute idle kick",
	Icon  = "coffee",
	Value = false,
	Callback = function(state)
		if AfkConnection then
			AfkConnection:Disconnect()
			AfkConnection = nil
		end
		if state then
			local ok = pcall(function()
				local VirtualUser = game:GetService("VirtualUser")
				AfkConnection = Track(LocalPlayer.Idled:Connect(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
					AfkCount += 1
					pcall(function()
						AfkInfo:SetDesc("Idle kicks prevented this session: " .. AfkCount)
					end)
				end))
			end)
			if not ok then
				Notify("Failed", "VirtualUser is not available in this environment", "circle-alert", 4)
			end
		end
	end,
})
AfkInfo = PerfTab:Paragraph({
	Title     = "Anti-AFK stats",
	Desc      = "Idle kicks prevented this session: 0",
	Image     = "shield",
	ImageSize = 22,
})
local Cards = {}
local RefreshPending = false
local function ClearCards()
	for _, card in ipairs(Cards) do
		pcall(function() card:Destroy() end)
	end
	table.clear(Cards)
end
local function BuildCard(plr)
	local config = {
		Title     = plr.DisplayName .. (plr == LocalPlayer and "  (you)" or ""),
		Desc      = string.format("@%s  ·  UserId: %d  ·  account age %d days", plr.Name, plr.UserId, plr.AccountAge),
		Image     = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=48&h=48",
		ImageSize = 36,
		Buttons   = {
			{
				Title = "Username",
				Icon  = "copy",
				Callback = function() CopyWithToast(plr.Name, "@" .. plr.Name) end,
			},
			{
				Title = "Profile",
				Icon  = "link",
				Callback = function()
					CopyWithToast("https://www.roblox.com/users/" .. plr.UserId .. "/profile", "Profile link")
				end,
			},
		},
	}
	local ok, card = pcall(function() return PlrTab:Paragraph(config) end)
	if not ok or not card then
		config.Image = "user"
		config.ImageSize = 22
		card = PlrTab:Paragraph(config)
	end
	return card
end
local function Refresh()
	ClearCards()
	local list = Players:GetPlayers()
	table.sort(list, function(a, b)
		if a == b then return false end
		if a == LocalPlayer then return true end
		if b == LocalPlayer then return false end
		return a.DisplayName:lower() < b.DisplayName:lower()
	end)
	for _, plr in ipairs(list) do
		table.insert(Cards, BuildCard(plr))
	end
end
local function QueueRefresh()
	if RefreshPending then return end
	RefreshPending = true
	task.delay(1, function()
		RefreshPending = false
		if Running then Refresh() end
	end)
end
local function LogEvent(text)
	table.insert(JoinLog, os.date("[%H:%M:%S] ") .. text)
	while #JoinLog > 200 do table.remove(JoinLog, 1) end
end
PlrTab:Section({ Title = "Actions" })
PlrTab:Button({
	Title = "Refresh list",
	Icon  = "refresh-cw",
	Callback = Refresh,
})
PlrTab:Toggle({
	Flag  = "JoinNotify",
	Title = "Join / leave notifications",
	Icon  = "bell",
	Value = true,
	Callback = function(state) NotifyJoins = state end,
})
PlrTab:Button({
	Title = "Copy join/leave log",
	Desc  = "Everything that happened this session, with timestamps",
	Icon  = "clipboard-list",
	Callback = function()
		if #JoinLog == 0 then
			Notify("Log", "Nothing happened yet", "info", 2)
			return
		end
		CopyWithToast(table.concat(JoinLog, "\n"), "Log (" .. #JoinLog .. " events)")
	end,
})
PlrTab:Section({ Title = "In server" })
Refresh()
Track(Players.PlayerAdded:Connect(function(plr)
	LogEvent("+ " .. plr.DisplayName .. " (@" .. plr.Name .. ")")
	if NotifyJoins then
		Notify("Joined", plr.DisplayName .. " (@" .. plr.Name .. ")", "user-plus", 3)
	end
	if NamesHidden then
		task.delay(1, function()
			if NamesHidden then SetNamesHidden(true) end
		end)
	end
	HookEspRespawn(plr)
	task.delay(1.5, function()
		if Running and (Esp.Names or Esp.Highlight) then CreateEsp(plr) end
	end)
	QueueRefresh()
end))
Track(Players.PlayerRemoving:Connect(function(plr)
	LogEvent("- " .. plr.DisplayName .. " (@" .. plr.Name .. ")")
	if NotifyJoins then
		Notify("Left", plr.DisplayName .. " (@" .. plr.Name .. ")", "user-minus", 3)
	end
	RemoveEsp(plr)
	QueueRefresh()
end))
UITab:Section({ Title = "Appearance" })
UITab:Dropdown({
	Flag   = "Theme",
	Title  = "Theme",
	Values = { "Dark", "Light", "Rose", "Plant", "Indigo", "Sky", "Violet", "Amber" },
	Value  = "Dark",
	Callback = function(theme)
		pcall(function() WindUI:SetTheme(theme) end)
	end,
})
UITab:Slider({
	Flag  = "UIScale",
	Title = "Menu scale",
	Step  = 5,
	Value = { Min = 60, Max = 130, Default = 100 },
	Callback = function(value)
		pcall(function() Window:SetUIScale(value / 100) end)
	end,
})
UITab:Keybind({
	Flag  = "ToggleKey",
	Title = "Menu toggle key",
	Desc  = "Opens and closes the hub",
	Value = "RightControl",
	Callback = function(key)
		pcall(function() Window:SetToggleKey(Enum.KeyCode[key]) end)
	end,
})
UITab:Section({ Title = "Roblox UI" })
UITab:Toggle({
	Flag  = "CleanScreen",
	Title = "Clean screen",
	Desc  = "Hides the whole Roblox interface, handy for screenshots",
	Icon  = "camera",
	Value = false,
	Callback = function(state)
		CleanScreen = state
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not state) end)
		pcall(function() StarterGui:SetCore("TopbarEnabled", not state) end)
		SyncOverlay()
	end,
})
UITab:Toggle({
	Flag  = "HideChat",
	Title = "Hide chat",
	Icon  = "message-square-off",
	Value = false,
	Callback = function(state)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not state) end)
	end,
})
UITab:Toggle({
	Flag  = "HideList",
	Title = "Hide player list",
	Icon  = "list-x",
	Value = false,
	Callback = function(state)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not state) end)
	end,
})
UITab:Section({ Title = "Script" })
UITab:Button({
	Title = "Save settings",
	Desc  = "They will be restored on the next launch",
	Icon  = "save",
	Callback = function()
		local ok = pcall(function() Config:Save() end)
		Notify(ok and "Saved" or "Failed",
			ok and "Settings written to disk" or "This executor cannot write files",
			ok and "check" or "circle-alert", 3)
	end,
})
local function Unload()
	if not Running then return end
	Running = false
	for _, conn in ipairs(Connections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(Connections)
	StopFly()
	SetSpin(false)
	pcall(function()
		local hrp = GetHRP()
		if hrp then hrp.Anchored = false end
	end)
	pcall(ResetMovement)
	pcall(function() workspace.Gravity = DefaultGravity end)
	ClearAllEsp()
	pcall(function()
		Lighting.Brightness    = OriginalLighting.Brightness
		Lighting.ClockTime     = OriginalLighting.ClockTime
		Lighting.GlobalShadows = OriginalLighting.GlobalShadows
		Lighting.Ambient       = OriginalLighting.Ambient
		Lighting.FogEnd        = OriginalLighting.FogEnd
	end)
	pcall(function() Overlay:Destroy() end)
	pcall(function() Cross:Destroy() end)
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
	pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
	pcall(function() workspace.CurrentCamera.FieldOfView = DefaultFOV end)
	SetNamesHidden(false)
	pcall(function() ApplyPreset("Default") end)
	pcall(function() Window:Destroy() end)
	_G.QOLHubUnload = nil
end
_G.QOLHubUnload = Unload
UITab:Button({
	Title = "Unload script",
	Desc  = "Disconnects everything, restores UI, FOV, graphics and physics",
	Icon  = "log-out",
	Color = Color3.fromHex("#ff4830"),
	Callback = Unload,
})
pcall(function()
	Window:OnDestroy(Unload)
end)
task.spawn(function()
	while Running and task.wait(0.5) do
		Ping = GetPing()
		pcall(function()
			Info:SetTitle(string.format("FPS: %d   ·   Ping: %d ms", FPS, Ping))
			Info:SetDesc(string.format(
				"Players: %d/%d   ·   in server: %s",
				#Players:GetPlayers(), Players.MaxPlayers, FormatTime(os.time() - StartTime)
			))
			if ShowSpeed then
				Label.Text = string.format("FPS %d  ·  PING %d ms  ·  SPD %d", FPS, Ping, GetSpeed())
			else
				Label.Text = string.format("FPS %d  ·  PING %d ms", FPS, Ping)
			end
		end)
	end
end)
pcall(function()
	Config:Load()
end)
SyncOverlay()
Notify("QOL Hub v4", "Loaded ✓", "check", 4)
print("QOL Hub v4 loaded!")
--enjoy!
