local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local pairs = pairs
local x1, x2, y1, y2 = unpack(DB.TexCoord)

local function UpdateIconBgAlpha(icon, _, _, _, alpha)
	icon.bg:SetAlpha(alpha)
	if icon.bg.__shadow then
		icon.bg.__shadow:SetAlpha(alpha)
	end
end

local function UpdateIconTexCoord(icon)
	if icon.isCutting then return end
	icon.isCutting = true

	local width, height = icon:GetSize()
	if width ~= 0 and height ~= 0 then
		local left, right, top, bottom = x1, x2, y1, y2 -- normal icon
		local ratio = width/height
		if ratio > 1 then -- fat icon
			local offset = (1 - 1/ratio) / 2
			top = top + offset
			bottom = bottom - offset
		elseif ratio < 1 then -- thin icon
			local offset = (1 - ratio) / 2
			left = left + offset
			bottom = bottom - offset
		end
		icon:SetTexCoord(left, right, top, bottom)
	end

	icon.isCutting = nil
end

local function ReskinWAIcon(icon)
	UpdateIconTexCoord(icon)
	hooksecurefunc(icon, "SetTexCoord", UpdateIconTexCoord)
	icon.bg = B.SetBD(icon, 0)
	icon.bg:SetFrameLevel(0)
	hooksecurefunc(icon, "SetVertexColor", UpdateIconBgAlpha)
end

local function ResetBGLevel(frame)
	frame.bg:SetFrameLevel(0)
end

local function Skin_WeakAuras(f, fType)
	if fType == "icon" then
		if not f.styled then
			ReskinWAIcon(f.icon)
			f.styled = true
		end
	elseif fType == "aurabar" then
		if not f.styled then
			f.bg = B.SetBD(f.bar, 0)
			f.bg:SetFrameLevel(0)
			ReskinWAIcon(f.icon)
			hooksecurefunc(f, "SetFrameStrata", ResetBGLevel)
			f.styled = true
		end

		f.icon.bg:SetShown(not not f.iconVisible)
	end
end

local function ReskinWA()
	if not C.db["Skins"]["WeakAuras"] then return end

	if not WeakAuras or not WeakAuras.Private then
		return
	end

	if WeakAuras.Private.regionPrototype then
		local function OnPrototypeCreate(region)
			Skin_WeakAuras(region, region.regionType)
		end
		local function OnPrototypeModifyFinish(_, region)
			Skin_WeakAuras(region, region.regionType)
		end
		hooksecurefunc(WeakAuras.Private.regionPrototype, "create", OnPrototypeCreate)
		hooksecurefunc(WeakAuras.Private.regionPrototype, "modifyFinish", OnPrototypeModifyFinish)
	end
end

S:RegisterSkin("WeakAuras", ReskinWA)