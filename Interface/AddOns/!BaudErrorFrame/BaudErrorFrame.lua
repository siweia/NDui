local _, BEF = ...
local format, max = string.format, math.max
local issecretvalue = issecretvalue
local EscapeDecimalNonPrintables = C_StringUtil.EscapeDecimalNonPrintables
local errors, errorsByMessage = {}, {}
local MAX_ERRORS, MAX_COUNT = 1000, 99
local soundTime = 0
local handlingError, refreshPending
local previousErrorHandler = geterrorhandler()

BEF.errors = errors
BEF.selected = 1

function BEF.GetConfig()
	if issecretvalue(BaudErrorFrameConfig) or type(BaudErrorFrameConfig) ~= "table" then
		BaudErrorFrameConfig = {}
	end
	return BaudErrorFrameConfig
end

-- EditBox:SetText cannot accept secrets from addon code. Check conversions too:
-- a public object can have a __tostring metamethod that returns a secret string.
local function PrepareText(value, fallback)
	if issecretvalue(value) then return "<secret value>", true end
	if value == nil then return fallback end

	if type(value) ~= "string" then
		local success, text = pcall(tostring, value)
		if not success then return "<unprintable value>" end
		if issecretvalue(text) then return "<secret value>", true end
		value = text
	end

	local text = EscapeDecimalNonPrintables(value)
	if issecretvalue(text) then return "<secret value>", true end
	return text
end
BEF.PrepareText = PrepareText

local function RefreshDisplay()
	refreshPending = false
	if BEF.Refresh then BEF.Refresh() end
end

local function QueueRefresh()
	if refreshPending then return end
	refreshPending = true
	C_Timer.After(0, RefreshDisplay)
end

local function AddCaptured(message, stack, locals)
	local secretMessage
	message, secretMessage = PrepareText(message, "error handler received nil.")
	stack = PrepareText(stack, "debugstack() returned nil.")
	locals = PrepareText(locals, "")
	locals = locals:gsub("|([kK])", "%1")

	-- Never use a secret as a table key, or merge unrelated secret messages.
	local existing = not secretMessage and errorsByMessage[message]
	if existing then
		if existing.Count < MAX_COUNT then
			existing.Count = existing.Count + 1
			existing.Detail = nil
			QueueRefresh()
		end
		return
	end
	if #errors >= MAX_ERRORS then return end

	local entry = {Error = message, Stack = stack, Locals = locals, Count = 1}
	errors[#errors + 1] = entry
	if not secretMessage then errorsByMessage[message] = entry end
	QueueRefresh()

	if BEF.GetConfig().enableSound and GetTime() > soundTime then
		soundTime = GetTime() + 1
		PlaySound(48942, "Master")
	end
end

local function CaptureError(message)
	local currentHeight = GetCallstackHeight()
	local errorHeight = GetErrorCallstackHeight()
	local level = max(1, currentHeight - (errorHeight and (errorHeight - 1) or 0))
	local stack = debugstack(level)
	local locals = debuglocals(level, true)
	AddCaptured(message, stack, locals)
end

function BaudErrorFrameHandler(message)
	if handlingError then return end

	handlingError = true
	local success, failure = pcall(CaptureError, message)
	if not success then
		-- Keep the original error even if stack/local capture itself fails.
		pcall(AddCaptured, message, "<stack capture failed>", "")
		local prepared, failureText = pcall(PrepareText, failure, "BaudErrorFrame could not capture an error.")
		pcall(previousErrorHandler, prepared and failureText or "BaudErrorFrame could not format an error.")
	end
	handlingError = false
end

function BaudErrorFrameAdd(message, retrace)
	AddCaptured(message, debugstack(retrace or 2), "")
end

function BaudErrorFrameScrollValue()
	return #errors
end

function BEF.Clear()
	wipe(errors)
	wipe(errorsByMessage)
	BEF.selected = 1
	QueueRefresh()
end

local function ColorStack(text)
	text = text:gsub("Interface[\\/]", "")
	text = text:gsub("|([^chHr])", "||%1"):gsub("|$", "||")
	text = text:gsub("<(.-)>", "|cffffd200<%1>|r")
	text = text:gsub("%[(.-)%]", "|cffffd200[%1]|r")
	text = text:gsub("([\"`'])(.-)([\"`'])", "|cff82c5ff%1%2%3|r")
	text = text:gsub(":(%d+)([%S\n])", ":|cff7fff7f%1|r%2")
	return (text:gsub("([^\\/]+%.lua)", "|cffffffff%1|r"))
end

local function ColorLocals(text)
	text = text:gsub("Interface[\\/]", "")
	text = text:gsub("|([^chHr])", "||%1"):gsub("|$", "||")
	text = text:gsub("(%s-)([%a_%(][%a_%d%*%)]+) = ", "%1|cffffff80%2|r = ")
	text = text:gsub("= (%-?[%d%p]+)\n", "= |cffff7fff%1|r\n")
	text = text:gsub("= nil\n", "= |cffff7f7fnil|r\n")
	text = text:gsub("= true\n", "= |cffff9100true|r\n")
	text = text:gsub("= false\n", "= |cffff9100false|r\n")
	return (text:gsub("= <(.-)>", "= |cffffd200<%1>|r"))
end

function BEF.GetSummary(entry)
	if not entry.Summary then entry.Summary = ColorStack(entry.Error) end
	return entry.Summary
end

function BEF.GetDetail(entry)
	if not entry.Detail then
		local message = entry.Error
		local errorString = message:match("near '(.*)'")
		if errorString and errorString:byte() == 229 then
			message = message:gsub("('.*')$", "UTF8 string")
		end

		entry.Detail = ColorStack(format("%s\nCount: %d\n\nCall Stack:\n%s", message, entry.Count, entry.Stack))
		if entry.Locals ~= "" then
			entry.Detail = entry.Detail.."\n\nLocals:\n"..ColorLocals(entry.Locals)
		end
	end
	return entry.Detail
end

-- Leave the global setter available to other addons and Blizzard.
seterrorhandler(BaudErrorFrameHandler)
