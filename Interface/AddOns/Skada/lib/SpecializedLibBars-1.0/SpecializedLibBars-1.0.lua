-- LibBars-1.0 by Antiarc, all glory to him, ripped into pieces for Skada.
local MAJOR = "SpecializedLibBars-1.0"
local MINOR = 900000 + tonumber(("$Revision: 1 $"):match("%d+"))

local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- No Upgrade needed.

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")

local GetTime = _G.GetTime
local sin, cos, rad = _G.math.sin, _G.math.cos, _G.math.rad
local abs, min, max, floor = _G.math.abs, _G.math.min, _G.math.max, _G.math.floor
local table_sort, tinsert, tremove, tconcat = _G.table.sort, tinsert, tremove, _G.table.concat
local next, pairs, assert, error, type, xpcall = next, pairs, assert, error, type, xpcall

--[[
	 xpcall safecall implementation
]]
local function errorhandler(err)
	return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
	local code = [[
		local xpcall, eh = ...
		local method, ARGS
		local function call() return method(ARGS) end

		local function dispatch(func, ...)
			 method = func
			 if not method then return end
			 ARGS = ...
			 return xpcall(call, eh)
		end

		return dispatch
	]]

	local ARGS = {}
	for i = 1, argCount do ARGS[i] = "arg"..i end
	code = code:gsub("ARGS", tconcat(ARGS, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher = CreateDispatcher(argCount)
	rawset(self, argCount, dispatcher)
	return dispatcher
end})
Dispatchers[0] = function(func)
	return xpcall(func, errorhandler)
end

local function safecall(func, ...)
	-- we check to see if the func is passed is actually a function here and don't error when it isn't
	-- this safecall is used for optional functions like OnInitialize OnEnable etc. When they are not
	-- present execution should continue without hinderance
	if type(func) == "function" then
		return Dispatchers[select('#', ...)](func, ...)
	end
end

local dummyFrame, barFrameMT, barPrototype, barPrototype_mt, barListPrototype
local barListPrototype_mt

lib.LEFT_TO_RIGHT = 1
lib.BOTTOM_TO_TOP = 2
lib.RIGHT_TO_LEFT = 3
lib.TOP_TO_BOTTOM = 4

lib.dummyFrame = lib.dummyFrame or CreateFrame("Frame")
lib.barFrameMT = lib.barFrameMT or {__index = lib.dummyFrame}
lib.barPrototype = lib.barPrototype or setmetatable({}, lib.barFrameMT)
lib.barPrototype_mt = lib.barPrototype_mt or {__index = lib.barPrototype}
lib.barListPrototype = lib.barListPrototype or setmetatable({}, lib.barFrameMT)
lib.barListPrototype_mt = lib.barListPrototype_mt or {__index = lib.barListPrototype}

dummyFrame = lib.dummyFrame
barFrameMT = lib.barFrameMT
barPrototype = lib.barPrototype
barPrototype_mt = lib.barPrototype_mt
barListPrototype = lib.barListPrototype
barListPrototype_mt = lib.barListPrototype_mt

barPrototype.prototype = barPrototype
barPrototype.metatable = barPrototype_mt
barPrototype.super = dummyFrame

barListPrototype.prototype = barListPrototype
barListPrototype.metatable = barListPrototype_mt
barListPrototype.super = dummyFrame

lib.bars = lib.bars or {}
lib.barLists = lib.barLists or {}
lib.recycledBars = lib.recycledBars or {}
lib.embeds = lib.embeds or {}
local bars = lib.bars
local barLists = lib.barLists
local recycledBars = lib.recycledBars

local frame_defaults = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	inset = 4,
	edgeSize = 8,
	tile = true,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

do
	local mixins = { "NewCounterBar", "NewBarFromPrototype", "GetBar", "GetBars", "HasBar", "IterateBars", "NewBarGroup", "ReleaseBar", "GetBarGroup", "GetBarGroups" }
	function lib:Embed(target)
		for k, v in pairs( mixins ) do
			target[v] = self[v]
		end
		lib.embeds[target] = true
		return target
	end
end

local ComputeGradient
do
	local new, del
	do
		local list = lib.garbageList or setmetatable({}, {__mode='k'})
		lib.garbageList = list
		-- new is always called with the exact same arguments, no need to
		-- iterate over a vararg
		function new(a1, a2, a3, a4, a5)
			local t = next(list)
			if t then
				list[t] = nil
				t[1] = a1
				t[2] = a2
				t[3] = a3
				t[4] = a4
				t[5] = a5
			else
				t = {a1, a2, a3, a4, a5}
			end
			return t
		end

		-- del is called over the same tables produced from new, no need for
		-- fancy stuff
		function del(t)
			t[1] = nil
			t[2] = nil
			t[3] = nil
			t[4] = nil
			t[5] = nil
			t[''] = true
			t[''] = nil
			list[t] = true
			return nil
		end
	end

	local function sort_colors(a, b)
		return a[1] < b[1]
	end

	local colors = {}
	local function getColor(point)
		local lowerBound = colors[1]
		local upperBound = colors[#colors]
		local lowerBoundIndex, upperBoundIndex = 0, 1
		for i = 1, #colors do
			if colors[i][1] >= point then
				if i > 1 then
					lowerBound = colors[i-1]
					lowerBoundIndex = colors[i-1][1]
				end
				upperBound = colors[i]
				upperBoundIndex = colors[i][1]
				break
			end
		end
		--local pct = (point - lowerBoundIndex) / (upperBoundIndex - lowerBoundIndex)
		local diff = (upperBoundIndex - lowerBoundIndex)
		local pct = 1
		if diff ~= 0 then
			pct = (point - lowerBoundIndex) / diff
		end
		local r = lowerBound[2] + ((upperBound[2] - lowerBound[2]) * pct)
		local g = lowerBound[3] + ((upperBound[3] - lowerBound[3]) * pct)
		local b = lowerBound[4] + ((upperBound[4] - lowerBound[4]) * pct)
		local a = lowerBound[5] + ((upperBound[5] - lowerBound[5]) * pct)
		return r, g, b, a
	end

	function ComputeGradient(self)
		self.gradMap = self.gradMap or {}
		if not self.colors then return end
		if #self.colors == 0 then
			for k in pairs(self.gradMap) do
				self.gradMap[k] = nil
			end
			return
		end

		for i = 1, #colors do
			del(tremove(colors))
		end
		for i = 1, #self.colors, 5 do
			tinsert(colors, new(self.colors[i], self.colors[i+1], self.colors[i+2], self.colors[i+3], self.colors[i+4]))
		end
		table_sort(colors, sort_colors)

		for i = 0, 200 do
			local r, g, b, a = getColor(i / 200)
			self.gradMap[(i*4)] = r
			self.gradMap[(i*4)+1] = g
			self.gradMap[(i*4)+2] = b
			self.gradMap[(i*4)+3] = a
		end
	end
end

function lib:GetBar(name)
	return bars[self] and bars[self][name]
end

function lib:GetBars(name)
	return bars[self]
end

function lib:HasAnyBar()
	return not not (bars[self] and next(bars[self]))
end

do
	local function NOOP() end
	function lib:IterateBars()
		if bars[self] then
			return pairs(bars[self])
		else
			return NOOP
		end
	end
end

-- Convenient method to create a new, empty bar prototype
function lib:NewBarPrototype(super)
	assert(super == nil or (type(super) == "table" and type(super.metatable) == "table"),
		"!NewBarPrototype: super must either be nil or a valid prototype")
	super = super or barPrototype
	local prototype = setmetatable({}, super.metatable)
	prototype.prototype = prototype
	prototype.super = super
	prototype.metatable = { __index = prototype }
	return prototype
end

--[[ Individual bars ]]--

function lib:NewBarFromPrototype(prototype, name, ...)
	assert(self ~= lib, "You may only call :NewBar as an embedded function")
	assert(type(prototype) == "table" and type(prototype.metatable) == "table", "Invalid bar prototype")
	bars[self] = bars[self] or {}
	local bar = bars[self][name]
	local isNew = false
	if not bar then
		isNew = true
		bar = tremove(recycledBars)
		if not bar then
			bar = CreateFrame("Frame")
		else
			bar:Show()
		end
	end
	bar = setmetatable(bar, prototype.metatable)
	bar.name = name
	bar:Create(...)
	bar:SetFont(self.font, self.fontSize, self.fontFlags)

	bars[self][name] = bar

	return bar, isNew
end

function lib:NewCounterBar(name, text, value, maxVal, icon, orientation, length, thickness)
	return self:NewBarFromPrototype(barPrototype, name, text, value, maxVal, icon, orientation, length, thickness)
end

function lib:ReleaseBar(name)
	if not bars[self] then return end

	local bar
	if type(name) == "string" then
		bar = bars[self][name]
	elseif type(name) == "table" then
		if name.name and bars[self][name.name] == name then
			bar = name
		end
	end

	if bar then
		bar:SetScript("OnEnter", nil)
		bar:SetScript("OnLeave", nil)
		bar:OnBarReleased()
		bars[self][bar.name] = nil
		tinsert(recycledBars, bar)
	end
end

---[[ Bar Groups ]]---
function barListPrototype:AddButton(title, description, normaltex, highlighttex, clickfunc)
	-- Create button frame.
	local btn = CreateFrame("Button", nil, self.button)
	btn.title = title
	btn:SetFrameLevel(5)
	btn:ClearAllPoints()
	btn:SetHeight(12)
	btn:SetWidth(12)
	btn:SetNormalTexture(normaltex)
	btn:SetHighlightTexture(highlighttex, 1.0)
	btn:SetAlpha(0.25)
	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	btn:SetScript("OnClick", clickfunc)
	btn:SetScript("OnEnter",
		function(this)
			GameTooltip_SetDefaultAnchor(GameTooltip, this)
			GameTooltip:SetText(title)
            GameTooltip:AddLine(description, 1, 1, 1, true)
			GameTooltip:Show()
		end)
	btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btn:Show()

	-- Add to our list of buttons.
	tinsert(self.buttons, btn)

	self:AdjustButtons()
end

function barListPrototype:SetSmoothing(smoothing)
    self.smoothing = smoothing
    
    if smoothing then
        self:SetScript("OnUpdate", function()
        
            if bars[self] then
                for k, v in pairs(bars[self]) do
                    if v.targetamount and v:IsShown() then
                        
                        local amt
                        if v.targetamount > v.lastamount then
                            amt = min(((v.targetamount - v.lastamount) / 10) + v.lastamount, v.targetamount)
                        else
                            amt = max(v.lastamount - ((v.lastamount - v.targetamount) / 10), v.targetamount)
                        end
                        v.lastamount = amt
                        if amt == v.targetamount then
                            v.targetamount = nil
                        end
                        v:SetTextureValue(amt, v.targetdist)
                        
                    end
                end
            end

        end)
        
    else
        self:SetScript("OnUpdate", nil)
    end
end

function barListPrototype:SetButtonsOpacity(alpha)
	for i, btn in ipairs(self.buttons) do
        btn:SetAlpha(alpha)
	end
end

function barListPrototype:AdjustButtons()
	local nr = 0
	local lastbtn = nil
	for i, btn in ipairs(self.buttons) do
		btn:ClearAllPoints()

		if btn:IsShown() then
			if nr == 0 then
				btn:SetPoint("TOPRIGHT", self.button, "TOPRIGHT", -5, 0 - (max(self.button:GetHeight() - btn:GetHeight(), 0) / 2))
			else
				btn:SetPoint("TOPRIGHT", lastbtn, "TOPLEFT", 0, 0)
			end
			lastbtn = btn
			nr = nr + 1
		end
	end
	if lastbtn then
		self.button:GetFontString():SetPoint("RIGHT", lastbtn, "LEFT")
	else
		self.button:GetFontString():SetPoint("RIGHT", self.button, "RIGHT")
	end
end

function barListPrototype:SetBarBackgroundColor(r, g, b, a)
	self.barbackgroundcolor = {r,g,b,a}
	for i, bar in pairs(self:GetBars()) do
		bar.bgtexture:SetVertexColor(unpack(self.barbackgroundcolor))
	end
end

function barListPrototype:ShowButton(title, visible)
	for i, b in ipairs(self.buttons) do
		if b.title == title then
			if visible then
				b:Show()
			else
				b:Hide()
			end
		end
	end
	self:AdjustButtons()
end

do
	local function move(self)
		if not self:GetParent().locked then
			self.startX = self:GetParent():GetLeft()
			self.startY = self:GetParent():GetTop()
			self:GetParent():StartMoving()
		end
	end
	local function stopMove(self)
		if not self:GetParent().locked then
			self:GetParent():StopMovingOrSizing()
			local endX = self:GetParent():GetLeft()
			local endY = self:GetParent():GetTop()
			if self.startX ~= endX or self.startY ~= endY then
				self:GetParent().callbacks:Fire("AnchorMoved", self:GetParent(), endX, endY)
			end
		end
	end

	local DEFAULT_TEXTURE = [[Interface\TARGETINGFRAME\UI-StatusBar]]
	function lib:NewBarGroup(name, orientation, height, length, thickness, frameName)
		if self == lib then
			error("You may only call :NewBarGroup as an embedded function")
		end

		barLists[self] = barLists[self] or {}
		if barLists[self][name] then
			error("A bar list named " .. name .. " already exists.")
		end

		orientation = orientation or lib.LEFT_TO_RIGHT
		orientation = orientation == "LEFT" and lib.LEFT_TO_RIGHT or orientation
		orientation = orientation == "RIGHT" and lib.RIGHT_TO_LEFT or orientation

		local list = setmetatable(CreateFrame("Frame", frameName, UIParent), barListPrototype_mt)
		list:SetMovable(true)
		list:SetClampedToScreen(true)
		list.enablemouse = true

		list.callbacks = list.callbacks or CallbackHandler:New(list)
		barLists[self][name] = list
		list.name = name

		--[[
		list:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			inset = 0,
			edgeSize = 12,
			tile = true
		})
		--]]

		local myfont = CreateFont("MyTitleFont")
		myfont:CopyFontObject(ChatFontSmall)

		list.button = CreateFrame("Button", nil, list)
		list.button:SetText(name)
		list.button:SetBackdrop(frame_defaults)
		list.button:SetNormalFontObject(myfont)

		list.length = length or 200
		list.thickness = thickness or 15
		list:SetOrientation(orientation)

		list:UpdateOrientationLayout()

		list.button:SetScript("OnMouseDown", move)
		list.button:SetScript("OnMouseUp", stopMove)
		list.button:SetBackdropColor(0,0,0,1)
		list.button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up")

		list.buttons = {}

		list.barbackgroundcolor = {0.3, 0.3, 0.3, 0.6},

		list:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 0)
		list:SetHeight(height)
		list:SetWidth(length)
		list:SetResizable(true)
		list:SetMinResize(60,40)
		list:SetMaxResize(800,800)

		list.showIcon = true
		list.showLabel = true
		list.showTimerLabel = true

		list.lastBar = list
		list.locked = false

		list.texture = DEFAULT_TEXTURE
		list.spacing = 0

		list.offset = 0

		list.resizebutton = CreateFrame("Button", "BarGroupResizeButton", list)
		list.resizebutton:Show()
		list.resizebutton:SetFrameLevel(11)
		list.resizebutton:SetWidth(16)
		list.resizebutton:SetHeight(16)
		list.resizebutton:EnableMouse(true)
		list.resizebutton:SetScript("OnMouseDown",
			function(self,button)
				local p = self:GetParent()
				if(button == "LeftButton") then
					p.isResizing = true
					if p.growup then
						p:StartSizing("TOPRIGHT")
					else
						p:StartSizing("BOTTOMRIGHT")
					end

					p:SetScript("OnUpdate", function()
								if p.isResizing then
									-- Adjust bar sizes.
									p:SetLength(p:GetWidth())
								else
									p:SetScript("OnUpdate", nil)
								end
							end)
				end
			end)
		list.resizebutton:SetScript("OnMouseUp",
			function(self,button)
				local p = self:GetParent()
				local top, left = p:GetTop(), p:GetLeft()
				if p.isResizing == true then
					p:StopMovingOrSizing()
					p:SetLength(p:GetWidth())
					p.callbacks:Fire("WindowResized", self:GetParent())
					p.isResizing = false
					p:SortBars()
				end
			end)

		list:ReverseGrowth(false)

		return list
	end
end

function lib:GetBarGroups()
	return barLists[self]
end

function lib:GetBarGroup(name)
	return barLists[self] and barLists[self][name]
end

--[[ BarList prototype ]]--

function barListPrototype:NewBarFromPrototype(prototype, ...)
	local bar, isNew = lib.NewBarFromPrototype(self, prototype, ...)
	bar:SetTexture(self.texture)
	bar:SetFill(self.fill)
	-- if isNew then bar:SetValue(0) end

	if self.showIcon then bar:ShowIcon() else bar:HideIcon(bar) end
	if self.showLabel then bar:ShowLabel() else bar:HideLabel(bar) end
	if self.showTimerLabel then bar:ShowTimerLabel() else bar:HideTimerLabel(bar) end
	self:SortBars()
	bar.ownerGroup = self
	bar:SetParent(self)

	bar:EnableMouse(self.enablemouse)
	return bar, isNew
end

function barListPrototype:SetEnableMouse(enablemouse)
	self.enablemouse = enablemouse
	self:EnableMouse(enablemouse)
	for i, bar in pairs(self:GetBars()) do
		bar:EnableMouse(enablemouse)
	end
end

function barListPrototype:SetBarWidth(width)
	self:SetLength(width)
end

function barListPrototype:SetBarHeight(height)
	self:SetThickness(height)
end

function barListPrototype:NewCounterBar(name, text, value, maxVal, icon)
	local bar = self:NewBarFromPrototype(barPrototype, name, text, value, maxVal, icon, self.orientation, self.length, self.thickness)

	-- Apply barlist settings.
	bar.bgtexture:SetVertexColor(unpack(self.barbackgroundcolor))

	return bar
end

function barListPrototype:Lock()
	-- Hide resize button.
	self.resizebutton:Hide()

	self.locked = true
end

function barListPrototype:Unlock()
	-- Show resize button.
	self.resizebutton:Show()

	self.locked = false
end

function barListPrototype:IsLocked()
	return self.locked
end

-- Max number of bars to display. nil to display all.
function barListPrototype:SetMaxBars(num)
	self.maxBars = num
end

function barListPrototype:GetMaxBars()
	return self.maxBars
end

function barListPrototype:SetTexture(tex)
	self.texture = tex
	if bars[self] then
		for k, v in pairs(bars[self]) do
			v:SetTexture(tex)
		end
	end
end

function barListPrototype:SetFont(f, s, m)
	self.font, self.fontSize, self.fontFlags = f, s, m
	if bars[self] then
		for k, v in pairs(bars[self]) do
			v:SetFont(f, s, m)
		end
	end
end

function barListPrototype:SetFill(fill)
	self.fill = fill
	if bars[self] then
		for k, v in pairs(bars[self]) do
			v:SetFill(fill)
		end
	end
end

function barListPrototype:IsFilling()
	return self.fill
end

function barListPrototype:ShowIcon()
	self.showIcon = true
	if not bars[self] then return end
	for name,bar in pairs(bars[self]) do
		bar:ShowIcon()
	end
end

function barListPrototype:HideIcon()
	self.showIcon = false
	if not bars[self] then return end
	for name, bar in pairs(bars[self]) do
		bar:HideIcon()
	end
end

function barListPrototype:IsIconShown()
	return self.showIcon
end

function barListPrototype:ShowLabel()
	self.showLabel = true
	for name,bar in pairs(bars[self]) do
		bar:ShowLabel()
	end
end

function barListPrototype:HideLabel()
	self.showLabel = false
	for name,bar in pairs(bars[self]) do
		bar:HideLabel()
	end
end

function barListPrototype:IsLabelShown()
	return self.showLabel
end

function barListPrototype:ShowTimerLabel()
	self.showTimerLabel = true
	for name,bar in pairs(bars[self]) do
		bar:ShowTimerLabel()
	end
end

function barListPrototype:HideTimerLabel()
	self.showTimerLabel = false
	for name,bar in pairs(bars[self]) do
		bar:HideTimerLabel()
	end
end

function barListPrototype:IsValueLabelShown()
	return self.showTimerLabel
end

function barListPrototype:SetSpacing(spacing)
	self.spacing = spacing
	self:SortBars()
end

function barListPrototype:GetSpacing()
	return self.spacing
end

barListPrototype.GetBar = lib.GetBar
barListPrototype.GetBars = lib.GetBars
barListPrototype.HasAnyBar = lib.HasAnyBar
barListPrototype.IterateBars = lib.IterateBars

function barListPrototype:RemoveBar(bar)
	lib.ReleaseBar(self, bar)
end

function barListPrototype:SetDisplayMax(val)
	self.displayMax = val
end

function barListPrototype:UpdateColors()
	-- Force a color update on all the bars, particularly the counter bars
	if bars[self] then
		for k, v in pairs(bars[self]) do
			v:UpdateColor()
--             if not v.isTimer then
--                 v:UpdateColor()
--             end
		end
	end
end

function barListPrototype:SetColorAt(at, r, g, b, a)
	self.colors = self.colors or {}
	tinsert(self.colors, at)
	tinsert(self.colors, r)
	tinsert(self.colors, g)
	tinsert(self.colors, b)
	tinsert(self.colors, a)
	ComputeGradient(self)
	self:UpdateColors()
end

function barListPrototype:UnsetColorAt(at)
	if not self.colors then return end
	for i = 1, #self.colors, 5 do
		if self.colors[i] == at then
			for j = 1, 5 do
				tremove(self.colors, i)
			end
			ComputeGradient(self)
			self:UpdateColors()
			return
		end
	end
end

function barListPrototype:UnsetAllColors()
	if not self.colors then return end
	for i = 1, #self.colors do
		tremove(self.colors)
	end
	return
end


function barListPrototype:ShowAnchor()
	self.button:Show()
	self:SortBars()
end

function barListPrototype:HideAnchor()
	self.button:Hide()
	self:SortBars()
end

function barListPrototype:IsAnchorVisible()
	return self.button:IsVisible()
end

function barListPrototype:ToggleAnchor()
	if self.button:IsVisible() then
		self.button:Hide()
	else
		self.button:Show()
	end
	self:SortBars()
end

function barListPrototype:GetBarAttachPoint()
	local growup, lastBar = self.growup, self.lastBar
	if growup then
		return lastBar:GetLeft(), lastBar:GetTop() + lastBar:GetHeight()
	else
		return lastBar:GetLeft(), lastBar:GetBottom() - lastBar:GetHeight()
	end
end

function barListPrototype:ReverseGrowth(reverse)
	self.growup = reverse
	self.button:ClearAllPoints()

	if reverse then
		self.button:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
		self.button:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
	else
		self.button:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
		self.button:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
	end

	if self.resizebutton then
		self.resizebutton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
		self.resizebutton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
		self.resizebutton:ClearAllPoints()
		if reverse then
			self.resizebutton:GetNormalTexture():SetRotation(math.pi/2)
			self.resizebutton:GetHighlightTexture():SetRotation(math.pi/2)
			self.resizebutton:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		else
			self.resizebutton:GetNormalTexture():SetRotation(0)
			self.resizebutton:GetHighlightTexture():SetRotation(0)
			self.resizebutton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		end
	end

	self:SortBars()
end

function barListPrototype:HasReverseGrowth()
	return self.growup
end

function barListPrototype:UpdateOrientationLayout()
	local length, thickness = self.length, self.thickness
	barListPrototype.super.SetWidth(self, length)
	self.button:SetWidth(length)
	self:ReverseGrowth(self.growup)
end

function barListPrototype:SetLength(length)
	self.length = length
	if bars[self] then
		for k, v in pairs(bars[self]) do
			v:SetLength(length)
			v:OnSizeChanged() -- widget fires this before .length is set, do it again to ensure update
		end
	end
	self:UpdateOrientationLayout()
end

function barListPrototype:GetLength()
	return self.length
end

function barListPrototype:SetThickness(thickness)
	self.thickness = thickness
	if bars[self] then
		for k, v in pairs(bars[self]) do
			v:SetThickness(thickness)
		end
	end
	self:UpdateOrientationLayout()
end

function barListPrototype:GetThickness()
	return self.thickness
end

function barListPrototype:SetOrientation(orientation)
	self.orientation = orientation
	if bars[self] then
		for k, v in pairs(bars[self]) do
			v:SetOrientation(orientation)
		end
	end
	self:UpdateOrientationLayout()
end

function barListPrototype:GetOrientation()
	return self.orientation
end

-- MODIFIED
-- Allows nil sort function.
function barListPrototype:SetSortFunction(func)
	if func then
		assert(type(func) == "function")
	end
	self.sortFunc = func
end

function barListPrototype:GetSortFunction(func)
	return self.sortFunc
end

-- MODIFIED
function barListPrototype:SetBarOffset(offset)
	self.offset = offset
	self:SortBars()
end

-- MODIFIED
function barListPrototype:GetBarOffset()
	return self.offset
end

-- group:SetSortFunction(group.NOOP) to disable sorting
function barListPrototype.NOOP() end

do
	local values = {}

	local function sortFunc(a, b)
		local apct, bpct = a.value / a.maxValue, b.value / b.maxValue
		if apct == bpct then
			if a.maxValue == b.maxValue then
				return a.name > b.name
			else
				return a.maxValue > b.maxValue
			end
		else
			return apct > bpct
		end
	end

	function barListPrototype:SortBars()
		local lastBar = self
		local ct = 0
        local has_fixed = false
        
		if not bars[self] then return end
		for k, v in pairs(bars[self]) do
			ct = ct + 1
			values[ct] = v
			v:Hide()
            if v.fixed then
                has_fixed = true
            end
		end
		for i = ct + 1, #values do
			values[i] = nil
		end
		if #values == 0 then return end

		table_sort(values, self.sortFunc or sortFunc)

		local orientation = self.orientation
		local growup = self.growup
		local spacing = self.spacing

		local from, to
		local thickness, showIcon = self.thickness, self.showIcon
		local offset = self.offset
		local x1, y1, x2, y2 = 0, 0, 0, 0
		local maxbars = min(#values, floor(self:GetHeight() / (thickness + spacing)))

		local start, stop, step
		if growup then
			from = "BOTTOM"
			to = "TOP"
			start = min(#values, maxbars + offset)
			stop = min(#values, 1 + offset)
			step = -1
		else
			from = "TOP"
			to = "BOTTOM"
			start = min(1 + offset, #values)
			stop = min(maxbars + offset, #values)
			step = 1
		end
        
        -- Fixed bar replaces the last bar
        if has_fixed and stop < #values then
            for i = stop + 1, #values, 1 do
                if values[i].fixed then
                    tinsert(values, stop, values[i])
                    break
                end
            end
        end

		local shown = 0
		local last_icon = false
		for i = start, stop, step do
			local origTo = to
			local v = values[i]
			if lastBar == self then
				to = from
				y1, y2 = 0, 0
			else
				if growup then
					y1, y2 = spacing, spacing
				else
					y1, y2 = -spacing, -spacing
				end
			end

			x1, x2 = 0, 0

			-- Silly hack to fix icon positions. I should just rewrite the whole thing, really. WTB energy.
			if showIcon and lastBar == self then
                if orientation == 1 then
                    x1 = thickness
                else
                    x2 = -thickness
                end
			end

			if shown <= maxbars then
				v:ClearAllPoints()

				v:SetPoint(from.."LEFT", lastBar, to.."LEFT", x1, y1)
				v:SetPoint(from.."RIGHT", lastBar, to.."RIGHT", x2, y2)

				v:Show()
				shown = shown + 1
				if v.showIcon then
					last_icon = true
				end
				lastBar = v
			end

			to = origTo
		end

		self.lastBar = lastBar
	end
end

--[[
****************************************************************
***	Bar methods
****************************************************************
]]--

--[[ Bar Prototype ]]--
do
	local function barClick(self, button)
		self:GetParent().callbacks:Fire("BarClick", self:GetParent(), button)
	end
	local function barEnter(self, button)
		self:GetParent().callbacks:Fire("BarEnter", self:GetParent(), button)
	end
	local function barLeave(self, button)
		self:GetParent().callbacks:Fire("BarLeave", self:GetParent(), button)
	end


	local DEFAULT_ICON = 134400
	function barPrototype:Create(text, value, maxVal, icon, orientation, length, thickness)

		self.callbacks = self.callbacks or CallbackHandler:New(self)
		self:SetScript("OnSizeChanged", self.OnSizeChanged)
		self.texture = self.texture or self:CreateTexture(nil, "ARTWORK")

		self.bgtexture = self.bgtexture or self:CreateTexture(nil, "BACKGROUND")
		self.bgtexture:SetAllPoints()
		self.bgtexture:SetVertexColor(0.3, 0.3, 0.3, 0.6)

		self.icon = self.icon or self:CreateTexture(nil, "OVERLAY")
		self.icon:SetPoint("LEFT", self, "LEFT", 0, 0)
		self:SetIcon(icon or DEFAULT_ICON)
		if icon then
			self:ShowIcon()
		end
		self.icon:SetTexCoord(0.07,0.93,0.07,0.93);

		-- Lame frame solely used for handling mouse input on icon.
		self.iconFrame = self.iconFrame or CreateFrame("Frame", nil, self)
		self.iconFrame:SetAllPoints(self.icon)

		self.label = self.label or self:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
        self.label:SetWordWrap(false);
		self.label:SetText(text)
		self.label:ClearAllPoints()
		self.label:SetPoint("LEFT", self, "LEFT", 3, 0)
		self:ShowLabel()

		local f, s, m = self.label:GetFont()
		self.label:SetFont(f, s or 10, m)

		self.timerLabel = self.timerLabel or self:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
		self:SetTimerLabel("")
		self.timerLabel:ClearAllPoints()
		self.timerLabel:SetPoint("RIGHT", self, "RIGHT", -6, 0)
		self:HideTimerLabel()

		local f, s, m = self.timerLabel:GetFont()
		self.timerLabel:SetFont(f, s or 10, m)

		self:SetScale(1)
		self:SetAlpha(1)

		self.length = length or 200
		self.thickness = thickness or 15
		self:SetOrientation(orientation or 1)

		value = value or 1
		maxVal = maxVal or value
		self.value = value
		self.maxValue = maxVal

		self:SetMaxValue(maxVal)
		self:SetValue(value)
	end

end

barPrototype.SetWidth = barListPrototype.SetBarWidth
barPrototype.SetHeight = barListPrototype.SetBarHeight

function barPrototype:OnBarReleased()
	self.callbacks:Fire('BarReleased', self, self.name)

	-- Reset our attributes
	self.ownerGroup = nil
	self.fill = false
	if self.colors then
		for k, v in pairs(self.colors) do
			self.colors[k] = nil
		end
	end
	if self.gradMap then
		for k, v in pairs(self.gradMap) do
			self.gradMap[k] = nil
		end
	end

	-- Reset widget
	self.texture:SetVertexColor(1, 1, 1, 0)
	self:SetScript("OnUpdate", nil)
	self:SetParent(UIParent)
	self:ClearAllPoints()
	self:Hide()
	local f, s, m = ChatFontNormal:GetFont()
	self.label:SetFont(f, s or 10, m)
	self.timerLabel:SetFont(f, s or 10, m)

	-- Cancel all registered callbacks. CBH doesn't seem to provide a method to do this.
	if self.callbacks.insertQueue then
		for eventname, callbacks in pairs(self.callbacks.insertQueue) do
			for k, v in pairs(callbacks) do
				callbacks[k] = nil
			end
		end
	end
	for eventname, callbacks in pairs(self.callbacks.events) do
		for k, v in pairs(callbacks) do
			callbacks[k] = nil
		end
		if self.callbacks.OnUnused then
			self.callbacks.OnUnused(self.callbacks, target, eventname)
		end
	end
end

function barPrototype:GetGroup()
	return self.ownerGroup
end

function barPrototype:OnSizeChanged()
	self:SetValue(self.value)
end

function barPrototype:SetFont(newFont, newSize, newFlags)
	local t, font, size, flags
	t = self.label
	font, size, flags = t:GetFont()
	t:SetFont(newFont or font, newSize or size, newFlags or flags)

	t = self.timerLabel
	font, size, flags = t:GetFont()
	t:SetFont(newFont or font, newSize or size, newFlags or flags)
end

function barPrototype:SetIconWithCoord(icon, coord)
	if icon then
		self.icon:SetTexture(icon)
		self.icon:SetTexCoord(unpack(coord))
		if self.showIcon then
			self.icon:Show()
		end
	else
		self.icon:Hide()
	end
	self.iconTexture = icon or nil
end

function barPrototype:SetIcon(icon)
	if icon then
		self.icon:SetTexture(icon)
		if self.showIcon then
			self.icon:Show()
		end
	else
		self.icon:Hide()
	end
	self.iconTexture = icon or nil
end

function barPrototype:ShowIcon()
	self.showIcon = true
	if self.iconTexture then
		self.icon:Show()
	end
end

function barPrototype:HideIcon()
	self.showIcon = false
	self.icon:Hide()
end

function barPrototype:IsIconShown()
	return self.showIcon
end

function barPrototype:SetLabel(text)
	self.label:SetText(text)
end

function barPrototype:GetLabel(text)
	return self.label:GetText(text)
end

barPrototype.SetText = barPrototype.SetLabel -- for API compatibility
barPrototype.GetText = barPrototype.GetLabel -- for API compatibility

function barPrototype:ShowLabel()
	self.showLabel = true
	self.label:Show()
end

function barPrototype:HideLabel()
	self.showLabel = false
	self.label:Hide()
end

function barPrototype:IsLabelShown()
	return self.showLabel
end

function barPrototype:SetTimerLabel(text)
	self.timerLabel:SetText(text)
end

function barPrototype:GetTimerLabel(text)
	return self.timerLabel:GetText(text)
end

function barPrototype:ShowTimerLabel()
	self.showTimerLabel = true
	self.timerLabel:Show()
end

function barPrototype:HideTimerLabel()
	self.showTimerLabel = false
	self.timerLabel:Hide()
end

function barPrototype:IsValueLabelShown()
	return self.showTimerLabel
end

function barPrototype:SetTexture(texture)
	self.texture:SetTexture(texture)
	self.bgtexture:SetTexture(texture)
end

-- Added by Ulic
-- Allows for the setting of background colors for a specific bar
-- Someday I'll figure out to do it at the group level
function barPrototype:SetBackgroundColor(r, g, b, a)
	a = a or .6
	if r and g and b and a then
		self.bgtexture:SetVertexColor(r, g, b, a)
	end
end

function barPrototype:SetColorAt(at, r, g, b, a)
	self.colors = self.colors or {}
	tinsert(self.colors, at)
	tinsert(self.colors, r)
	tinsert(self.colors, g)
	tinsert(self.colors, b)
	tinsert(self.colors, a)
	ComputeGradient(self)
	self:UpdateColor()
end

function barPrototype:UnsetColorAt(at)
	if not self.colors then return end
	for i = 1, #self.colors, 5 do
		if self.colors[i] == at then
			for j = 1, 5 do
				tremove(self.colors, i)
			end
			ComputeGradient(self)
			self:UpdateColor()
			return
		end
	end
end

function barPrototype:UnsetAllColors()
	if not self.colors then return end
	for i = 1, #self.colors do
		tremove(self.colors)
	end
end

do
	function barPrototype:UpdateOrientationLayout()
		local o = self.orientation
		local t
		if o == lib.LEFT_TO_RIGHT then
			self.icon:ClearAllPoints()
			self.icon:SetPoint("RIGHT", self, "LEFT", 0, 0)

			t = self.texture
			t.SetValue = t.SetWidth
			t:ClearAllPoints()
			t:SetPoint("TOPLEFT", self, "TOPLEFT")
			t:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
			-- t:SetTexCoord(0, 1, 0, 1)

			t = self.timerLabel
			t:ClearAllPoints()
			t:SetPoint("RIGHT", self, "RIGHT", -6, 0)
			t:SetJustifyH("RIGHT")
			t:SetJustifyV("MIDDLE")

			t = self.label
			t:ClearAllPoints()
			t:SetPoint("LEFT", self, "LEFT", 6, 0)
			t:SetPoint("RIGHT", self.timerLabel, "LEFT", 0, 0)
			t:SetJustifyH("LEFT")
			t:SetJustifyV("MIDDLE")

			self.bgtexture:SetTexCoord(0, 1, 0, 1)
		elseif o == lib.BOTTOM_TO_TOP then
			self.icon:ClearAllPoints()
			self.icon:SetPoint("TOP", self, "BOTTOM", 0, 0)

			t = self.texture
			t.SetValue = t.SetHeight
			t:ClearAllPoints()
			t:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
			t:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
			-- t:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)

			t = self.timerLabel
			t:ClearAllPoints()
			t:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
			t:SetPoint("TOPRIGHT", self, "TOPRIGHT", -3, -3)
			t:SetJustifyH("CENTER")
			t:SetJustifyV("TOP")

			t = self.label
			t:ClearAllPoints()
			t:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
			t:SetPoint("TOPLEFT", self.Label, "BOTTOMLEFT", 0, 0)
			t:SetJustifyH("CENTER")
			t:SetJustifyV("BOTTOM")

			self.bgtexture:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
		elseif o == lib.RIGHT_TO_LEFT then
			self.icon:ClearAllPoints()
			self.icon:SetPoint("LEFT", self, "RIGHT", 0, 0)

			t = self.texture
			t.SetValue = t.SetWidth
			t:ClearAllPoints()
			t:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			t:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
			-- t:SetTexCoord(0, 1, 0, 1)

			t = self.timerLabel
			t:ClearAllPoints()
			t:SetPoint("LEFT", self, "LEFT", 6, 0)
			t:SetJustifyH("LEFT")
			t:SetJustifyV("MIDDLE")

			t = self.label
			t:ClearAllPoints()
			t:SetPoint("RIGHT", self, "RIGHT", -6, 0)
			t:SetPoint("LEFT", self.timerLabel, "RIGHT", 0, 0)
			t:SetJustifyH("RIGHT")
			t:SetJustifyV("MIDDLE")

			self.bgtexture:SetTexCoord(0, 1, 0, 1)
		elseif o == lib.TOP_TO_BOTTOM then
			self.icon:ClearAllPoints()
			self.icon:SetPoint("BOTTOM", self, "TOP", 0, 0)

			t = self.texture
			t.SetValue = t.SetHeight
			t:ClearAllPoints()
			t:SetPoint("TOPLEFT", self, "TOPLEFT")
			t:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			-- t:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)

			t = self.timerLabel
			t:ClearAllPoints()
			t:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 3, 3)
			t:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
			t:SetJustifyH("CENTER")
			t:SetJustifyV("BOTTOM")

			t = self.label
			t:ClearAllPoints()
			t:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
			t:SetPoint("BOTTOMRIGHT", self.timerLabel, "TOPRIGHT", 0, 0)
			t:SetJustifyH("CENTER")
			t:SetJustifyV("TOP")

			self.bgtexture:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
		end
		self:SetValue(self.value or 0)
	end
end

function barPrototype:GetLength()
	return self.length
end

do
	local function updateSize(self)
		local thickness, length = self.thickness, self.length
		local iconSize = self.showIcon and thickness or 0
		local width = max(0.0001, length - iconSize)
		local height = thickness
		barPrototype.super.SetWidth(self, width)
        barPrototype.super.SetHeight(self, height)
		self.icon:SetWidth(thickness)
		self.icon:SetHeight(thickness)
	end

	function barPrototype:SetLength(length)
		self.length = length
		updateSize(self)
	end

	function barPrototype:SetThickness(thickness)
		self.thickness = thickness
		updateSize(self)
	end
end

function barPrototype:GetThickness()
	return self.thickness
end

function barPrototype:SetOrientation(orientation)
	self.orientation = orientation
	self:UpdateOrientationLayout()
	self:SetThickness(self.thickness)
end

function barPrototype:GetOrientation()
	return self.orientation
end

function barPrototype:SetValue(val)
	assert(val ~= nil, "Value cannot be nil!")
	self.value = val
	if not self.maxValue or val > self.maxValue then
		self.maxValue = val
	end
	local ownerGroup = self.ownerGroup
	local displayMax = ownerGroup and ownerGroup.displayMax or self.displayMax
	if displayMax then
		displayMax = min(displayMax, self.maxValue)
	else
		displayMax = self.maxValue
	end
	local amt = min(1, val / max(displayMax, 0.000001))
	local dist = (ownerGroup and ownerGroup:GetLength()) or self.length
    amt = max(amt, 0.000001)
    
    if ownerGroup and ownerGroup.smoothing and self.lastamount then
        self:SetTextureTarget(amt, dist)
    else
        self.lastamount = amt
        self:SetTextureValue(amt, dist)
    end
	self:UpdateColor()
end

function barPrototype:SetTextureTarget(amt, dist)
    self.targetamount = amt
    self.targetdist = dist
end

function barPrototype:SetTextureValue(amt, dist)
	dist = max(0.0001, dist - (self.showIcon and self.thickness or 0))
	local t, o = self.texture, self.orientation
	t:SetValue(amt * dist)

	if o == 1 then
		t:SetTexCoord(0, amt, 0, 1)
	elseif o == 2 then
		t:SetTexCoord(1 - amt, 1, 1, 1, 1 - amt, 0, 1, 0)
	elseif o == 3 then
		t:SetTexCoord(1 - amt, 1, 0, 1)
	elseif o == 4 then
		t:SetTexCoord(0, 1, amt, 1, 0, 0, amt, 0)
	end
end

function barPrototype:SetDisplayMax(val)
	self.displayMax = val
end

function barPrototype:SetMaxValue(val)
	self.maxValue = val
	self:SetValue(self.value)
end


function barPrototype:SetFill(fill)
	self.fill = fill
end

function barPrototype:UpdateColor()
	local amt = floor(self.value / max(self.maxValue,0.000001) * 200) * 4
	local map
	if self.gradMap and #self.gradMap > 0 then
		map = self.gradMap
	elseif self.ownerGroup and self.ownerGroup.gradMap and #self.ownerGroup.gradMap > 0 then
		map = self.ownerGroup.gradMap
	end
	if map then
		self.texture:SetVertexColor(map[amt], map[amt+1], map[amt+2], map[amt+3])
	end
end

--- Finally: upgrade our old embeds
for target, v in pairs(lib.embeds) do
	lib:Embed(target)
end
