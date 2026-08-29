local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:GetModule("GUI")

local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil

--[[
Console frame preview.

The 12.0 aura container bakes the button size in at creation time, so resizing
raid-frame auras (and most frame geometry) only takes effect after a /reload.
This window draws a *schematic* of the raid unit frame straight from the live
C.db values and redraws itself on a throttled timer, so size / icon-count /
spacing changes are visible immediately while editing the console - no reload.

It is a schematic, not a real oUF frame: it shows proportions, the health /
power strips and the buff / debuff icon grid overlaying the frame, but it does
not render actual aura textures or unit colors.
--]]

local preview

local function SetIcon(parent, pool, i, x, y, size, r, g, b)
	local bu = pool[i]
	if not bu then
		bu = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		B.CreateBD(bu, 1)
		pool[i] = bu
	end
	bu:SetShown(true)
	bu:SetSize(size, size)
	bu:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
	bu:SetBackdropColor(r, g, b, 1)
	return bu
end

function G:UpdateFramePreview()
	if not preview or not preview:IsShown() then return end
	if not C.db then return end

	local ufs = C.db["UFs"]
	local W, H = ufs["RaidWidth"], ufs["RaidHeight"]
	local pH = ufs["RaidPowerHeight"]
	local textScale = ufs["RaidTextScale"]

	local f = preview.uf
	f:SetSize(W, H)

	-- Health / power colors follow the raid health color option.
	local idx = ufs["RaidHealthColor"]
	local hr, hg, hb = .1, .1, .1
	if idx == 2 or idx == 5 then
		hr, hg, hb = .3, .6, 1
	elseif idx == 4 then
		hr, hg, hb = 0, 0, 0
	end
	preview.health:SetStatusBarColor(hr, hg, hb)
	preview.power:SetStatusBarColor(.2, .4, .8)
	preview.power:SetShown(pH > 0)
	preview.power:SetHeight(pH)

	preview.uname:SetScale(textScale)
	preview.uhp:SetScale(textScale)
	preview.uname:SetText("Minimal")
	preview.uhp:SetText("100%")

	-- Aura counts (type 1 = none).
	local buffCount = ufs["RaidBuffType"] ~= 1 and ufs["RaidNumBuff"] or 0
	local debuffCount = ufs["RaidDebuffType"] ~= 1 and ufs["RaidNumDebuff"] or 0
	local buffSize = ufs["RaidBuffSize"]
	local debuffSize = ufs["RaidDebuffSize"]
	local spacing = 2

	local pool = preview.icons
	local n = 0
	local bw = W - 2

	-- Buffs: top-left, grow right then down, wrapped within frame width.
	local perRowB = max(1, floor((bw + spacing) / (buffSize + spacing)))
	local rowsB = ceil(buffCount / perRowB)
	for i = 1, buffCount do
		n = n + 1
		local col = (i - 1) % perRowB
		local row = floor((i - 1) / perRowB)
		SetIcon(f, pool, n,
			2 + col * (buffSize + spacing),
			2 + row * (buffSize + spacing),
			buffSize, 0, .6, .1)
	end
	local buffBottom = 2 + rowsB * buffSize + (rowsB - 1) * spacing

	-- Debuffs: bottom-right, grow left then up, wrapped within frame width.
	local perRowD = max(1, floor((bw + spacing) / (debuffSize + spacing)))
	local rowsD = ceil(debuffCount / perRowD)
	for i = 1, debuffCount do
		n = n + 1
		local col = (i - 1) % perRowD
		local row = floor((i - 1) / perRowD)
		SetIcon(f, pool, n,
			W - 2 - debuffSize - col * (debuffSize + spacing),
			(H - 2) - debuffSize - row * (debuffSize + spacing),
			debuffSize, .7, .1, .1)
	end
	local debuffTop = (H - 2) - debuffSize - (rowsD - 1) * (debuffSize + spacing)

	-- Big defensives: top-right, growing left (schematic only).
	if ufs["RaidBigDefensive"] then
		local bdSize = ufs["RaidBigDefensiveSize"]
		for i = 1, 2 do
			n = n + 1
			SetIcon(f, pool, n,
				W - 2 - i * bdSize - (i - 1) * 3,
				2, bdSize, 1, .8, 0)
		end
	end

	-- Hide leftover icons from a previous (larger) draw.
	for i = n + 1, #pool do
		pool[i]:Hide()
	end

	-- Fit the whole thing (frame + aura overflow) into the canvas.
	local boxTop = min(0, debuffTop)
	local boxBottom = max(H, buffBottom)
	local boxH = boxBottom - boxTop
	local canvasW, canvasH = 480, 400
	local margin = 20
	local scale = min(1, (canvasW - margin) / W, (canvasH - margin) / boxH)
	scale = max(scale, .3)
	f:SetScale(scale)
	local scaledBoxH = boxH * scale
	local frameY = (canvasH - scaledBoxH) / 2 - boxTop * scale
	f:SetPoint("TOPLEFT", preview.canvas, "TOPLEFT", (canvasW - W * scale) / 2, -frameY)

	preview.info:SetText(format(
		"Raid %dx%d  |  Buffs %dx%d  |  Debuffs %dx%d  |  Power %d  |  BigDef %s",
		W, H, buffSize, buffCount, debuffSize, debuffCount, pH,
		ufs["RaidBigDefensive"] and "On" or "Off"))
end

function G:CreateFramePreview()
	if preview then
		preview:Show()
		G:UpdateFramePreview()
		return
	end

	preview = CreateFrame("Frame", "NDuiFramePreview", UIParent)
	preview:SetSize(520, 500)
	preview:SetPoint("CENTER")
	preview:SetFrameStrata("DIALOG")
	B.CreateMF(preview)
	B.SetBD(preview)
	B.CreateFS(preview, 16, L["FramePreview"], true, "TOP", 0, -10)
	B.AddTooltip(preview, "ANCHOR_TOP", L["FramePreviewTip"], "info", true)

	local close = B.CreateButton(preview, 80, 20, CLOSE)
	close:SetPoint("BOTTOMRIGHT", -20, 15)
	close:SetScript("OnClick", function() preview:Hide() end)

	local canvas = CreateFrame("Frame", nil, preview)
	canvas:SetPoint("TOPLEFT", 20, -40)
	canvas:SetSize(480, 400)
	B.CreateBDFrame(canvas, .25)
	preview.canvas = canvas

	-- Representative unit frame.
	local f = CreateFrame("Frame", nil, canvas)
	local health = CreateFrame("StatusBar", nil, f)
	health:SetStatusBarTexture(DB.normTex)
	health:SetAllPoints(f)
	health:SetFrameLevel(1)
	local power = CreateFrame("StatusBar", nil, f)
	power:SetStatusBarTexture(DB.normTex)
	power:SetPoint("BOTTOMLEFT", f)
	power:SetPoint("BOTTOMRIGHT", f)
	power:SetFrameLevel(3)
	local name = B.CreateFS(f, 13, "", false, "CENTER", 0, 1)
	name:SetPoint("CENTER", 0, 4)
	local hp = B.CreateFS(f, 13, "", false, "CENTER", 0, -1)
	hp:SetPoint("CENTER", 0, -8)
	preview.uf = f
	preview.health = health
	preview.power = power
	preview.uname = name
	preview.uhp = hp
	preview.icons = {}

	B.CreateFS(preview, 12, L["FramePreviewTip"], false, "BOTTOM", 0, 38)
	preview.info = B.CreateFS(preview, 13, "", true, "BOTTOM", 0, 18)

	preview:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > .15 then
			self.elapsed = 0
			G:UpdateFramePreview()
		end
	end)

	G:UpdateFramePreview()
end
