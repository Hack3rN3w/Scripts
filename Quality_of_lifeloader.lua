--[[
    QOL Hub · Smart Loader + Animated Splash
    - animated loading screen (title, spinner, particles, real progress)
    - retries the download up to 3 times
    - validates the response (404 pages, empty bodies, truncated files)
    - compile check before running (clear error instead of a crash)
    - caches the script to disk and falls back to the cache if GitHub is down
]]

local CONFIG = {
	Url        = "https://raw.githubusercontent.com/Hack3rN3w/Scripts/refs/heads/main/Quality%20Of%20Life%20Hub.lua",
	Name       = "QOL Hub",
	Marker     = "QOLHubUnload",
	CacheFile  = "QOLHub/cache.lua",
	Retries    = 3,
	RetryDelay = 1.5,
}

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer

--═══════════════════ SPLASH SCREEN ═══════════════════
local Splash = {}

do
	local ACCENT  = Color3.fromRGB(120, 200, 255)
	local ACCENT2 = Color3.fromRGB(190, 120, 255)

	local gui = Instance.new("ScreenGui")
	gui.Name           = "QOL_Splash"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder   = 10000
	gui.ResetOnSpawn   = false

	-- kill leftovers from a previous run
	pcall(function()
		local parent = (gethui and gethui()) or game:GetService("CoreGui")
		local old = parent:FindFirstChild("QOL_Splash")
		if old then old:Destroy() end
	end)
	if not pcall(function()
		gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
	end) then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	-- dark backdrop
	local back = Instance.new("Frame")
	back.Size                   = UDim2.fromScale(1, 1)
	back.BackgroundColor3       = Color3.fromRGB(8, 8, 14)
	back.BackgroundTransparency = 1
	back.BorderSizePixel        = 0
	back.Parent                 = gui

	local vignette = Instance.new("UIGradient")
	vignette.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(14, 10, 26)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 14)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 14, 26)),
	})
	vignette.Rotation = 25
	vignette.Parent   = back

	-- center container
	local center = Instance.new("Frame")
	center.AnchorPoint            = Vector2.new(0.5, 0.5)
	center.Position               = UDim2.fromScale(0.5, 0.5)
	center.Size                   = UDim2.fromOffset(520, 260)
	center.BackgroundTransparency = 1
	center.Parent                 = back

	-- title: QUALITY OF LIFE
	local title = Instance.new("TextLabel")
	title.AnchorPoint            = Vector2.new(0.5, 0.5)
	title.Position               = UDim2.new(0.5, 0, 0, 50)
	title.Size                   = UDim2.new(1, 0, 0, 52)
	title.BackgroundTransparency = 1
	title.Font                   = Enum.Font.GothamBlack
	title.TextSize               = 44
	title.Text                   = "QUALITY OF LIFE"
	title.TextColor3             = Color3.fromRGB(240, 240, 250)
	title.TextTransparency       = 1
	title.Parent                 = center

	local titleGrad = Instance.new("UIGradient")
	titleGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, ACCENT),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, ACCENT2),
	})
	titleGrad.Parent = title

	-- subtitle: HUB (letter-spaced)
	local sub = Instance.new("TextLabel")
	sub.AnchorPoint            = Vector2.new(0.5, 0.5)
	sub.Position               = UDim2.new(0.5, 0, 0, 92)
	sub.Size                   = UDim2.new(1, 0, 0, 26)
	sub.BackgroundTransparency = 1
	sub.Font                   = Enum.Font.GothamBold
	sub.TextSize               = 18
	sub.Text                   = "H   U   B"
	sub.TextColor3             = ACCENT
	sub.TextTransparency       = 1
	sub.Parent                 = center

	-- thin divider lines left/right of "HUB"
	local function line(xScale, anchor)
		local l = Instance.new("Frame")
		l.AnchorPoint            = anchor
		l.Position               = UDim2.new(xScale, 0, 0, 92)
		l.Size                   = UDim2.fromOffset(150, 1)
		l.BackgroundColor3       = ACCENT
		l.BackgroundTransparency = 1
		l.BorderSizePixel        = 0
		l.Parent                 = center
		return l
	end
	local lineL = line(0.08, Vector2.new(0, 0.5))
	local lineR = line(0.92, Vector2.new(1, 0.5))

	-- spinner (arc made of dots orbiting)
	local spinner = Instance.new("Frame")
	spinner.AnchorPoint            = Vector2.new(0.5, 0.5)
	spinner.Position               = UDim2.new(0.5, 0, 0, 150)
	spinner.Size                   = UDim2.fromOffset(44, 44)
	spinner.BackgroundTransparency = 1
	spinner.Parent                 = center

	local spinDots = {}
	for i = 1, 8 do
		local d = Instance.new("Frame")
		d.AnchorPoint            = Vector2.new(0.5, 0.5)
		d.Size                   = UDim2.fromOffset(6, 6)
		d.BackgroundColor3       = ACCENT
		d.BackgroundTransparency = 1
		d.BorderSizePixel        = 0
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = d
		d.Parent = spinner
		spinDots[i] = d
	end

	-- progress bar
	local barBack = Instance.new("Frame")
	barBack.AnchorPoint            = Vector2.new(0.5, 0.5)
	barBack.Position               = UDim2.new(0.5, 0, 0, 200)
	barBack.Size                   = UDim2.fromOffset(360, 6)
	barBack.BackgroundColor3       = Color3.fromRGB(30, 30, 44)
	barBack.BackgroundTransparency = 1
	barBack.BorderSizePixel        = 0
	barBack.Parent                 = center
	local bbc = Instance.new("UICorner")
	bbc.CornerRadius = UDim.new(1, 0)
	bbc.Parent = barBack

	local barFill = Instance.new("Frame")
	barFill.Size                   = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3       = ACCENT
	barFill.BackgroundTransparency = 1
	barFill.BorderSizePixel        = 0
	barFill.Parent                 = barBack
	local bfc = Instance.new("UICorner")
	bfc.CornerRadius = UDim.new(1, 0)
	bfc.Parent = barFill
	local bfGrad = Instance.new("UIGradient")
	bfGrad.Color = ColorSequence.new(ACCENT, ACCENT2)
	bfGrad.Parent = barFill

	-- glow under the bar
	local glow = Instance.new("Frame")
	glow.AnchorPoint            = Vector2.new(0.5, 0.5)
	glow.Position               = UDim2.new(0.5, 0, 0, 200)
	glow.Size                   = UDim2.fromOffset(360, 18)
	glow.BackgroundColor3       = ACCENT
	glow.BackgroundTransparency = 1
	glow.BorderSizePixel        = 0
	glow.ZIndex                 = 0
	glow.Parent                 = center
	local gc = Instance.new("UICorner")
	gc.CornerRadius = UDim.new(1, 0)
	gc.Parent = glow

	-- status + percent
	local status = Instance.new("TextLabel")
	status.AnchorPoint            = Vector2.new(0.5, 0.5)
	status.Position               = UDim2.new(0.5, 0, 0, 226)
	status.Size                   = UDim2.new(1, 0, 0, 20)
	status.BackgroundTransparency = 1
	status.Font                   = Enum.Font.Gotham
	status.TextSize               = 14
	status.Text                   = "Initializing..."
	status.TextColor3             = Color3.fromRGB(170, 175, 195)
	status.TextTransparency       = 1
	status.Parent                 = center

	local percent = Instance.new("TextLabel")
	percent.AnchorPoint            = Vector2.new(1, 0.5)
	percent.Position               = UDim2.new(0.5, 180, 0, 182)
	percent.Size                   = UDim2.fromOffset(60, 16)
	percent.BackgroundTransparency = 1
	percent.Font                   = Enum.Font.GothamBold
	percent.TextSize               = 12
	percent.TextXAlignment         = Enum.TextXAlignment.Right
	percent.Text                   = "0%"
	percent.TextColor3             = ACCENT
	percent.TextTransparency       = 1
	percent.Parent                 = center

	-- footer
	local footer = Instance.new("TextLabel")
	footer.AnchorPoint            = Vector2.new(0.5, 1)
	footer.Position               = UDim2.new(0.5, 0, 1, -18)
	footer.Size                   = UDim2.new(1, 0, 0, 16)
	footer.BackgroundTransparency = 1
	footer.Font                   = Enum.Font.Gotham
	footer.TextSize               = 12
	footer.Text                   = "smart loader  ·  v4  ·  github/Hack3rN3w"
	footer.TextColor3             = Color3.fromRGB(110, 115, 135)
	footer.TextTransparency       = 1
	footer.Parent                 = back

	-- state
	local alive = true
	local targetProgress = 0
	local shownProgress  = 0

	-- animation loop: spinner rotation, dots pulse, smooth bar, particles
	task.spawn(function()
		local t = 0
		while alive do
			local dt = task.wait()
			t += dt
			-- spinner
			for i, d in ipairs(spinDots) do
				local ang = t * 4 + (i / #spinDots) * math.pi * 2
				d.Position = UDim2.new(0.5, math.cos(ang) * 18, 0.5, math.sin(ang) * 18)
				local phase = (math.sin(t * 6 - i * 0.7) + 1) / 2
				d.BackgroundTransparency = 0.15 + phase * 0.6
			end
			-- smooth progress
			shownProgress += (targetProgress - shownProgress) * math.min(dt * 6, 1)
			barFill.Size = UDim2.new(shownProgress, 0, 1, 0)
			percent.Text = math.floor(shownProgress * 100 + 0.5) .. "%"
			-- gradient shimmer on the title
			titleGrad.Offset = Vector2.new((t * 0.25) % 2 - 1, 0)
			-- glow pulse
			glow.BackgroundTransparency = 0.9 + math.sin(t * 3) * 0.05
		end
	end)

	-- floating particles
	task.spawn(function()
		local rng = Random.new()
		while alive do
			task.wait(rng:NextNumber(0.15, 0.35))
			if not alive then break end
			pcall(function()
				local p = Instance.new("Frame")
				local size = rng:NextInteger(2, 5)
				p.Size                   = UDim2.fromOffset(size, size)
				p.Position               = UDim2.new(rng:NextNumber(), 0, 1.05, 0)
				p.BackgroundColor3       = rng:NextNumber() > 0.5 and ACCENT or ACCENT2
				p.BackgroundTransparency = 0.55
				p.BorderSizePixel        = 0
				p.ZIndex                 = 0
				local c = Instance.new("UICorner")
				c.CornerRadius = UDim.new(1, 0)
				c.Parent = p
				p.Parent = back
				local tw = TweenService:Create(p,
					TweenInfo.new(rng:NextNumber(3, 6), Enum.EasingStyle.Linear),
					{
						Position = UDim2.new(p.Position.X.Scale + rng:NextNumber(-0.06, 0.06), 0, -0.05, 0),
						BackgroundTransparency = 1,
					})
				tw:Play()
				tw.Completed:Connect(function() p:Destroy() end)
			end)
		end
	end)

	-- fade in
	local FADE = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(back, FADE, { BackgroundTransparency = 0.06 }):Play()
	for _, obj in ipairs({ title, sub, status, percent, footer }) do
		TweenService:Create(obj, FADE, { TextTransparency = 0 }):Play()
	end
	TweenService:Create(barBack,  FADE, { BackgroundTransparency = 0 }):Play()
	TweenService:Create(barFill,  FADE, { BackgroundTransparency = 0 }):Play()
	TweenService:Create(lineL,    FADE, { BackgroundTransparency = 0.5 }):Play()
	TweenService:Create(lineR,    FADE, { BackgroundTransparency = 0.5 }):Play()

	-- public api
	function Splash.Set(progress, text)
		targetProgress = math.clamp(progress, 0, 1)
		if text then status.Text = text end
	end

	function Splash.Fail(text)
		status.Text       = text
		status.TextColor3 = Color3.fromRGB(255, 110, 100)
		barFill.BackgroundColor3 = Color3.fromRGB(255, 90, 80)
		bfGrad.Enabled = false
		targetProgress = 1
		task.delay(4, function()
			if alive then Splash.Close() end
		end)
	end

	function Splash.Close()
		if not alive then return end
		alive = false
		local OUT = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(back, OUT, { BackgroundTransparency = 1 }):Play()
		for _, obj in ipairs({ title, sub, status, percent, footer }) do
			TweenService:Create(obj, OUT, { TextTransparency = 1 }):Play()
		end
		TweenService:Create(barBack, OUT, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(barFill, OUT, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(lineL,   OUT, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(lineR,   OUT, { BackgroundTransparency = 1 }):Play()
		for _, d in ipairs(spinDots) do
			TweenService:Create(d, OUT, { BackgroundTransparency = 1 }):Play()
		end
		task.delay(0.7, function() gui:Destroy() end)
	end
end

--═══════════════ notifications ═══════════════
local function Toast(text, duration)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title    = CONFIG.Name .. " Loader",
			Text     = text,
			Duration = duration or 5,
		})
	end)
	print("[" .. CONFIG.Name .. " Loader] " .. text)
end

--═══════════════ http (with fallbacks) ═══════════════
local function Fetch(url)
	local req = (syn and syn.request) or request or http_request
	if req then
		local ok, res = pcall(req, { Url = url, Method = "GET" })
		if ok and res and (res.StatusCode == 200 or res.Success) and res.Body then
			return res.Body
		end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	return ok and body or nil
end

--═══════════════ validation ═══════════════
local function Validate(body)
	if type(body) ~= "string" or #body < 500 then
		return false, "response is empty or too short"
	end
	if body:find("^404") or body:lower():find("<!doctype html") then
		return false, "got a 404 / HTML page instead of the script"
	end
	if not body:find(CONFIG.Marker, 1, true) then
		return false, "content doesn't look like " .. CONFIG.Name
	end
	return true
end

--═══════════════ cache ═══════════════
local canFiles = writefile and readfile and isfile

local function SaveCache(body)
	if not canFiles then return end
	pcall(function()
		if makefolder and not (isfolder and isfolder("QOLHub")) then
			makefolder("QOLHub")
		end
		writefile(CONFIG.CacheFile, body)
	end)
end

local function LoadCache()
	if not canFiles then return nil end
	local ok, body = pcall(function()
		if isfile(CONFIG.CacheFile) then return readfile(CONFIG.CacheFile) end
	end)
	return ok and body or nil
end

--═══════════════ compile + run ═══════════════
local function Run(body, sourceLabel)
	Splash.Set(0.8, "Compiling...")
	local fn, compileErr = loadstring(body)
	if not fn then
		Toast("Compile error (" .. sourceLabel .. "): " .. tostring(compileErr), 8)
		return false, "compile error"
	end
	Splash.Set(0.92, "Starting " .. CONFIG.Name .. "...")
	local ok, runErr = pcall(fn)
	if not ok then
		Toast("Runtime error: " .. tostring(runErr), 8)
		return false, "runtime error"
	end
	return true
end

--═══════════════ main ═══════════════
task.wait(0.4) -- let the splash fade in

local body, lastReason

for attempt = 1, CONFIG.Retries do
	Splash.Set(0.1 + attempt * 0.12,
		attempt == 1 and "Downloading from GitHub..."
		or ("Retrying (%d/%d)..."):format(attempt, CONFIG.Retries))
	local fetched = Fetch(CONFIG.Url)
	Splash.Set(0.55, "Validating...")
	local valid, reason = Validate(fetched)
	if valid then
		body = fetched
		break
	end
	lastReason = reason or "network error"
	if attempt < CONFIG.Retries then
		task.wait(CONFIG.RetryDelay * attempt)
	end
end

if body then
	SaveCache(body)
	local ok = Run(body, "GitHub")
	if ok then
		Splash.Set(1, "Done!")
		task.wait(0.5)
		Splash.Close()
		return
	end
	-- fresh copy failed → try the cached known-good version
	local cached = LoadCache()
	if cached and cached ~= body and Validate(cached) then
		Splash.Set(0.7, "Fresh copy failed, using cache...")
		if Run(cached, "cache") then
			Splash.Set(1, "Done (cached)!")
			task.wait(0.5)
			Splash.Close()
			return
		end
	end
	Splash.Fail("Script failed to start — check the console (F9)")
	return
end

-- network completely failed → offline fallback
local cached = LoadCache()
if cached and Validate(cached) then
	Splash.Set(0.7, "GitHub unreachable, loading cache...")
	if Run(cached, "cache") then
		Splash.Set(1, "Done (offline)!")
		task.wait(0.5)
		Splash.Close()
		return
	end
	Splash.Fail("Cached copy failed to start")
else
	Splash.Fail("Download failed: " .. tostring(lastReason))
	Toast("Failed to load: " .. tostring(lastReason) .. ". No cached copy available.", 8)
end
