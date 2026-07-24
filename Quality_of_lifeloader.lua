--[[
    QOL Hub · Smart Loader
    - retries the download up to 3 times
    - validates the response (404 pages, empty bodies, truncated files)
    - compile check before running (clear error instead of a crash)
    - caches the script to disk and falls back to the cache if GitHub is down
]]

local CONFIG = {
	Url        = "https://raw.githubusercontent.com/Hack3rN3w/Scripts/refs/heads/main/Quality%20Of%20Life%20Hub.lua",
	Name       = "QOL Hub",
	Marker     = "QOLHubUnload",       -- string that must exist in a valid script
	CacheFile  = "QOLHub/cache.lua",
	Retries    = 3,
	RetryDelay = 1.5,
}

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
		return false, "got a 404 / HTML page instead of the script (check the URL)"
	end
	if not body:find(CONFIG.Marker, 1, true) then
		return false, "content doesn't look like " .. CONFIG.Name .. " (marker missing)"
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
	local fn, compileErr = loadstring(body)
	if not fn then
		Toast("Compile error (" .. sourceLabel .. "): " .. tostring(compileErr), 8)
		return false
	end
	local ok, runErr = pcall(fn)
	if not ok then
		Toast("Runtime error: " .. tostring(runErr), 8)
		return false
	end
	return true
end

--═══════════════ main ═══════════════
local body, lastReason

for attempt = 1, CONFIG.Retries do
	local fetched = Fetch(CONFIG.Url)
	local valid, reason = Validate(fetched)
	if valid then
		body = fetched
		break
	end
	lastReason = reason or "network error"
	if attempt < CONFIG.Retries then
		Toast(("Attempt %d/%d failed: %s. Retrying..."):format(attempt, CONFIG.Retries, lastReason), 3)
		task.wait(CONFIG.RetryDelay * attempt)
	end
end

if body then
	SaveCache(body)
	if Run(body, "GitHub") then
		return
	end
	-- fresh copy compiled/ran badly → try the cache as a known-good fallback
	local cached = LoadCache()
	if cached and cached ~= body and Validate(cached) then
		Toast("Fresh copy failed, falling back to cached version...", 4)
		Run(cached, "cache")
	end
	return
end

-- network completely failed → offline fallback from cache
local cached = LoadCache()
if cached and Validate(cached) then
	Toast("GitHub unreachable (" .. tostring(lastReason) .. "). Loading cached copy...", 5)
	Run(cached, "cache")
else
	Toast("Failed to load: " .. tostring(lastReason) .. ". No cached copy available.", 8)
end
