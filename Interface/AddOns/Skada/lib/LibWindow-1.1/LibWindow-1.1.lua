--[[
Name: LibWindow-1.1
Revision: $Rev: 8 $
Author(s): Mikk (dpsgnome@mail.com)
Website: http://old.wowace.com/wiki/LibWindow-1.1
Documentation: http://old.wowace.com/wiki/LibWindow-1.1
SVN: http://svn.wowace.com/root/trunk/WindowLib/Window-1.0
Description: A library that handles the basics of "window" style frames: scaling, smart position saving, dragging..
Dependencies: none
License: Public Domain
]]

local MAJOR = "LibWindow-1.1"
local MINOR = tonumber(("$Revision: 8 $"):match("(%d+)"))

local lib = LibStub:NewLibrary(MAJOR,MINOR)
if not lib then return end

local min,max,abs = min,max,abs
local pairs = pairs
local tostring = tostring
local UIParent,GetScreenWidth,GetScreenHeight,IsAltKeyDown = UIParent,GetScreenWidth,GetScreenHeight,IsAltKeyDown
-- GLOBALS: error, ChatFrame1, assert

local function print(msg) ChatFrame1:AddMessage(MAJOR..": "..tostring(msg)) end

lib.utilFrame = lib.utilFrame or CreateFrame("Frame")
lib.delayedSavePosition = lib.delayedSavePosition or {}
lib.windowData = lib.windowData or {} 
  --[frameref]={ 
  --  names={optional names data from .RegisterConfig()}
  --  storage= -- tableref where config data is read/written
  --  altEnable=true/false
  --}


lib.embeds = lib.embeds or {}

local mixins = {} -- "FuncName"=true



---------------------------------------------------------
-- UTILITIES
---------------------------------------------------------


local function getStorageName(frame, name)
  local names = lib.windowData[frame].names
  if names then
		if names[name] then
			return names[name]
		end
		if names.prefix then
			return names.prefix .. name;
		end
	end
	return name;
end

local function setStorage(frame, name, value)
	lib.windowData[frame].storage[getStorageName(frame, name)] = value
end

local function getStorage(frame, name)
	return lib.windowData[frame].storage[getStorageName(frame, name)]
end


lib.utilFrame:SetScript("OnUpdate", function(this)
	this:Hide()
	for frame,_ in pairs(lib.delayedSavePosition) do
		lib.delayedSavePosition[frame] = nil
		lib.SavePosition(frame)
	end
end)

local function queueSavePosition(frame)
	lib.delayedSavePosition[frame] = true
	lib.utilFrame:Show()
end


---------------------------------------------------------
-- IMPORTANT APIS
---------------------------------------------------------

mixins["RegisterConfig"]=true
function lib.RegisterConfig(frame, storage, names)
	if not lib.windowData[frame] then
		lib.windowData[frame] = {}
	end
	lib.windowData[frame].names = names
	lib.windowData[frame].storage = storage
	
	--[[ debug
	frame.tx = frame:CreateTexture()
	frame.tx:SetTexture(0,0,0, 0.4)
	frame.tx:SetAllPoints(frame)
	frame.tx:Show()
	]]
end




---------------------------------------------------------
-- POSITIONING AND SCALING
---------------------------------------------------------

local nilParent = {
	GetWidth = function()
		return GetScreenWidth() * UIParent:GetScale()
	end,
	GetHeight = function()
		return GetScreenHeight() * UIParent:GetScale()
	end,
	GetScale = function() 
		return 1
	end,
}

mixins["SavePosition"]=true
function lib.SavePosition(frame)
	local parent = frame:GetParent() or nilParent
	-- No, this won't work very well with frames that aren't parented to nil or UIParent
	local s = frame:GetScale()
	local left,top = frame:GetLeft()*s, frame:GetTop()*s
	local right,bottom = frame:GetRight()*s, frame:GetBottom()*s
	local pwidth, pheight = parent:GetWidth(), parent:GetHeight()

	local x,y,point;
	if left < (pwidth-right) and left < abs((left+right)/2 - pwidth/2) then
		x = left;
		point="LEFT";
	elseif (pwidth-right) < abs((left+right)/2 - pwidth/2) then
		x = right-pwidth;
		point="RIGHT";
	else
		x = (left+right)/2 - pwidth/2;
		point="";
	end
	
	if bottom < (pheight-top) and bottom < abs((bottom+top)/2 - pheight/2) then
		y = bottom;
		point="BOTTOM"..point;
	elseif (pheight-top) < abs((bottom+top)/2 - pheight/2) then
		y = top-pheight;
		point="TOP"..point;
	else
		y = (bottom+top)/2 - pheight/2;
		-- point=""..point;
	end
	
	if point=="" then
		point = "CENTER"
	end
	
	setStorage(frame, "x", x)
	setStorage(frame, "y", y)
	setStorage(frame, "point", point)
	setStorage(frame, "scale", s)
	
	frame:ClearAllPoints()
	frame:SetPoint(point, frame:GetParent(), point, x/s, y/s);
end


mixins["RestorePosition"]=true
function lib.RestorePosition(frame)
	local x = getStorage(frame, "x")
	local y = getStorage(frame, "y")
	local point = getStorage(frame, "point")
	
	local s = getStorage(frame, "scale")
	if s then
		(frame.lw11origSetScale or frame.SetScale)(frame,s)
	else
		s = frame:GetScale()
	end
	
	if not x or not y then		-- nothing stored in config yet, smack it in the center
		x=0; y=0; point="CENTER"
	end

	x = x/s
	y = y/s
	
	frame:ClearAllPoints()
	if not point and y==0 then	-- errr why did i do this check again? must have been a reason, but i can't remember it =/
		point="CENTER"
	end
		
	if not point then	-- we have position, but no point, which probably means we're going from data stored by the addon itself before LibWindow was added to it. It was PROBABLY topleft->bottomleft anchored. Most do it that way.
		frame:SetPoint("TOPLEFT", frame:GetParent(), "BOTTOMLEFT", x, y)
		-- make it compute a better attachpoint (on next update)
		queueSavePosition(frame)
		return
	end
	
	frame:SetPoint(point, frame:GetParent(), point, x, y)
end


mixins["SetScale"]=true
function lib.SetScale(frame, scale)
	setStorage(frame, "scale", scale);
	(frame.lw11origSetScale or frame.SetScale)(frame,scale)
	lib.RestorePosition(frame)
end



---------------------------------------------------------
-- DRAG SUPPORT
---------------------------------------------------------


function lib.OnDragStart(frame)
	lib.windowData[frame].isDragging = true
	frame:StartMoving()
end


function lib.OnDragStop(frame)
	frame:StopMovingOrSizing()
	lib.SavePosition(frame)
	lib.windowData[frame].isDragging = false
	if lib.windowData[frame].altEnable and not IsAltKeyDown() then
		frame:EnableMouse(false)
	end
end

local function onDragStart(...) return lib.OnDragStart(...) end  -- upgradable
local function onDragStop(...) return lib.OnDragStop(...) end  -- upgradable

mixins["MakeDraggable"]=true
function lib.MakeDraggable(frame)
	assert(lib.windowData[frame])
	frame:SetMovable(true)
	frame:SetScript("OnDragStart", onDragStart)
	frame:SetScript("OnDragStop", onDragStop)
	frame:RegisterForDrag("LeftButton")
end


---------------------------------------------------------
-- MOUSEWHEEL
---------------------------------------------------------

function lib.OnMouseWheel(frame, dir)
	local scale = getStorage(frame, "scale")
	if dir<0 then
		scale=max(scale*0.9, 0.1)
	else
		scale=min(scale/0.9, 3)
	end
	lib.SetScale(frame, scale)
end

local function onMouseWheel(...) return lib.OnMouseWheel(...) end  -- upgradable

mixins["EnableMouseWheelScaling"]=true
function lib.EnableMouseWheelScaling(frame)
	frame:SetScript("OnMouseWheel", onMouseWheel)
end


---------------------------------------------------------
-- ENABLEMOUSE-ON-ALT
---------------------------------------------------------

lib.utilFrame:SetScript("OnEvent", function(this, event, key, state)
	if event=="MODIFIER_STATE_CHANGED" then
		if key == "LALT" or key == "RALT" then
			for frame,_ in pairs(lib.altEnabledFrames) do
				if not lib.windowData[frame].isDragging then		-- if it's already dragging, it'll disable mouse on DragStop instead
					frame:EnableMouse(state == 1)
				end
			end
		end
	end
end)

mixins["EnableMouseOnAlt"]=true
function lib.EnableMouseOnAlt(frame)
	assert(lib.windowData[frame])
	lib.windowData[frame].altEnable = true
	frame:EnableMouse(not not IsAltKeyDown())
	if not lib.altEnabledFrames then
		lib.altEnabledFrames = {}
		lib.utilFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
	end
	lib.altEnabledFrames[frame] = true
end



---------------------------------------------------------
-- Embed support (into FRAMES, not addons!)
---------------------------------------------------------

function lib:Embed(target)
	if not target or not target[0] or not target.GetObjectType then
		error("Usage: LibWindow:Embed(frame)", 1)
	end
	target.lw11origSetScale = target.SetScale
	for name, _ in pairs(mixins) do
		target[name] = self[name]
	end
	lib.embeds[target] = true
	return target
end

for target, _ in pairs(lib.embeds) do
	lib:Embed(target)
end
