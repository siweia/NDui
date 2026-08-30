local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:GetModule("GUI")
local min, max, floor = math.min, math.max, math.floor
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture

--[[
Console frame preview.

The 12.0 aura container bakes the button size in at creation time, so resizing
raid/party-frame auras (and most frame geometry) only takes effect after a /reload.
This window draws a *schematic* of a single raid frame and a single party frame
straight from the live C.db values and redraws itself on a throttled timer, so the
frame size / power height and the buff / debuff icon sizes are visible immediately
while editing the console - no reload.

Conventions used here:
 - One representative unit frame per box, drawn at REAL pixel size (no scaling), so
   the on-screen size tracks C.db["UFs"] exactly (that is the whole point).
 - A visible border is drawn around each unit frame so its real width / height is
   obvious even though the interior is just a health / power strip.
 - Auras are drawn OVERLAPPING the frame, mirrored from the real layout for BOTH the
   raid and the party frame (party reuses the exact same "Raid" aura config + anchors:
   buffs from TOPLEFT growing right+down, debuffs from BOTTOMRIGHT growing left+up,
   big defensives from TOPRIGHT growing left) so the in-frame icon position is visible
   - that is what a future "move aura" option would adjust.
 - Icon backdrop uses the NDui API (B:CreateBDFrame), not a hand-rolled one.
--]]

local preview
local unitPool, iconPool, indicatorPool = {}, {}, {}

local function GetUnit(i, parent)
	local u = unitPool[i]
	if not u then
		local f = CreateFrame("Frame", nil, parent)
		local bd = B.CreateBDFrame(f, 0) -- outline the frame bounds
		bd:SetBackdropBorderColor(.7, .7, .7, 1)
		local health = CreateFrame("StatusBar", nil, f)
		health:SetStatusBarTexture(DB.normTex)
		health:SetAllPoints(f)
		health:SetFrameLevel(1)
		local power = CreateFrame("StatusBar", nil, f)
		power:SetStatusBarTexture(DB.normTex)
		power:SetPoint("BOTTOMLEFT", f)
		power:SetPoint("BOTTOMRIGHT", f)
		power:SetFrameLevel(3)
		local name = B.CreateFS(f, 11, "", false, "CENTER", 0, 5)
		local hp = B.CreateFS(f, 11, "", false, "CENTER", 0, -7)
		u = {f = f, bdFrame = bd, health = health, power = power, name = name, hp = hp}
		f.health = health -- expose for corner-indicator anchoring
		unitPool[i] = u
	end
	u.f:SetShown(true)
	u.f:ClearAllPoints()
	u.f:SetParent(parent)
	return u
end

local function GetIcon(i, parent)
	local bu = iconPool[i]
	if not bu then
		bu = CreateFrame("Frame", nil, parent)
		bu.bdFrame = B.CreateBDFrame(bu, .25) -- NDui backdrop API
		-- Cooldown countdown text (shown only when the live CDText option is on).
		bu.cd = B.CreateFS(bu, 12, "", nil, "CENTER", 0, 0)
		bu.cd:SetTextColor(1, 1, 1)
		bu.cd:Hide()
		iconPool[i] = bu
	end
	bu:SetShown(true)
	bu:ClearAllPoints()
	bu:SetParent(parent)
	return bu
	end

local function GetIndicator(i, parent)
	local bu = indicatorPool[i]
	if not bu then
		bu = CreateFrame("Frame", nil, parent)
		bu.bdFrame = B.CreateBDFrame(bu, .25)
		bu.tex = bu:CreateTexture(nil, "ARTWORK")
		bu.tex:SetAllPoints(bu)
		bu.tex:Hide()
		bu.txt = B.CreateFS(bu, 10, "", nil, "CENTER", 0, 0)
		bu.txt:SetTextColor(1, 1, 1)
		bu.txt:Hide()
		indicatorPool[i] = bu
	end
	bu:SetShown(true)
	bu:ClearAllPoints()
	bu:SetParent(parent)
	return bu
end

-- Draw the raid-style aura overlay on a given frame (party reuses the same config).
-- Returns the next free icon index. iconIndex is the running counter across both frames.
-- cd = {buffText, buffSize, debuffText, debuffSize, bigText, bigSize} mirrors the live
-- per-type raid aura cooldown-text options (RaidBuffCDText / RaidDebuffCDText /
-- RaidBigDefensiveCDText + their *CDSize, each slider is clamped 5..16 in-game).
local function DrawAuras(frame, frameW, ufs, iconIndex, cd)
	local sp = 2 -- raid style spacing (party shares the raid config, so also 2)

	local buffCount = ufs["RaidBuffType"] ~= 1 and ufs["RaidNumBuff"] or 0
	local debuffCount = ufs["RaidDebuffType"] ~= 1 and ufs["RaidNumDebuff"] or 0
	local buffSize = ufs["RaidBuffSize"]
	local debuffSize = ufs["RaidDebuffSize"]

	local function SetCD(bu, on, size)
		if on then
			B.SetFontSize(bu.cd, size)
			bu.cd:SetText("8")
			bu.cd:Show()
		else
			bu.cd:Hide()
		end
	end

	local ii = iconIndex

	-- Buffs: TOPLEFT, grow right + down (overlay the frame).
	local perRowB = max(1, floor((frameW + sp) / (buffSize + sp)))
	for i = 1, buffCount do
		ii = ii + 1
		local col = (i - 1) % perRowB
		local row = floor((i - 1) / perRowB)
		local bu = GetIcon(ii, frame)
		bu:SetSize(buffSize, buffSize)
		bu:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 + col * (buffSize + sp), -(2 + row * (buffSize + sp)))
		bu.bdFrame:SetBackdropColor(0, .6, .1, 1)
		SetCD(bu, cd.buffText, cd.buffSize)
	end

	-- Debuffs: BOTTOMRIGHT, grow left + up (overlay the frame).
	local perRowD = max(1, floor((frameW + sp) / (debuffSize + sp)))
	for i = 1, debuffCount do
		ii = ii + 1
		local col = (i - 1) % perRowD
		local row = floor((i - 1) / perRowD)
		local bu = GetIcon(ii, frame)
		bu:SetSize(debuffSize, debuffSize)
		bu:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -(2 + col * (debuffSize + sp)), 2 + row * (debuffSize + sp))
		bu.bdFrame:SetBackdropColor(.7, .1, .1, 1)
		SetCD(bu, cd.debuffText, cd.debuffSize)
	end

	-- Big defensives: TOPRIGHT, grow left (overlay the frame, top-right corner).
	if ufs["RaidBigDefensive"] then
		local bd = ufs["RaidBigDefensiveSize"]
		for i = 1, 2 do
			ii = ii + 1
			local bu = GetIcon(ii, frame)
			bu:SetSize(bd, bd)
			bu:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -((i - 1) * (bd + 3)), -2)
		bu.bdFrame:SetBackdropColor(1, .8, 0, 1)
		SetCD(bu, cd.bigText, cd.bigSize)
	end
	end

	return ii
end

-- Draw the corner buff indicators (SpellsIndicator) on a frame, mirrored from the
-- live RaidBuffIndicator / BuffIndicatorType / BuffIndicatorScale / RaidSpellSize.
-- Each configured corner spell anchors to a corner of the Health bar.
local function DrawCornerIndicators(frame, ufs, indIndex)
	if not ufs["RaidBuffIndicator"] then return indIndex end
	local UF = B:GetModule("UnitFrames")
	local spells = UF.CornerSpells
	if not spells or not next(spells) then return indIndex end
	local spellSize = ufs["RaidSpellSize"] or 10
	local scale = ufs["BuffIndicatorScale"] or 1
	local iType = ufs["BuffIndicatorType"] or 1
	local size = max(4, floor(spellSize * scale + .5))
	-- counterOffsets[anchor][3] mirrors SpellsIndicator.lua (unscaled point offset).
	local off = {
		TOPLEFT = {2, -2}, TOPRIGHT = {-2, -2},
		BOTTOMLEFT = {2, 2}, BOTTOMRIGHT = {-2, 2},
		LEFT = {2, 0}, RIGHT = {-2, 0},
		TOP = {0, -2}, BOTTOM = {0, 2},
	}
	-- Use a SEPARATE sequential index (ind) so indicatorPool stays a dense 1..n
	-- sequence. Reusing the shared aura index would leave holes at the front and
	-- make #indicatorPool unreliable (Lua # on sparse tables), so leftover chips
	-- would never get hidden when the toggle is turned off.
	local ind = indIndex
	for spellID, value in pairs(spells) do
		local anchor = value[1]
		local col = value[2]
		ind = ind + 1
		local bu = GetIndicator(ind, frame)
		bu:SetSize(size, size)
		local x, y = unpack(off[anchor] or off.TOPLEFT)
		bu:SetPoint(anchor, frame.health, anchor, x, y)
		if iType == 3 then -- numbers / timer mode: dark chip with a colored letter
			bu.tex:Hide()
			bu.bdFrame:SetBackdropColor(.1, .1, .1, 1)
			bu.txt:SetTextColor(col[1], col[2], col[3])
			bu.txt:SetText("T")
			bu.txt:Show()
		elseif iType == 2 then -- icon mode: the spell's own icon (e.g. Rejuvenation)
			local tex = GetSpellTexture and GetSpellTexture(spellID)
			if tex then
				bu.tex:SetTexture(tex)
				bu.tex:Show()
			else
				bu.tex:Hide()
			end
			bu.bdFrame:SetBackdropColor(col[1], col[2], col[3], 1)
			bu.txt:Hide()
		else -- blocks (1): solid colored chip, no label
			bu.tex:Hide()
			bu.bdFrame:SetBackdropColor(col[1], col[2], col[3], 1)
			bu.txt:Hide()
		end
	end
	return ind
end

function G:UpdateFramePreview()
	if not preview or not preview:IsShown() then return end
	if not C.db then return end
	local ufs = C.db["UFs"]

	-- Raid geometry (real values, drawn 1:1).
	local rW, rH = ufs["RaidWidth"], ufs["RaidHeight"]
	local rpH = ufs["RaidPowerHeight"]
	local rFH = rH + rpH + C.mult

	-- Party geometry (real values, drawn 1:1).
	local pW, pH = ufs["PartyWidth"], ufs["PartyHeight"]
	local pPH = ufs["PartyPowerHeight"]
	local pFH = pH + pPH + C.mult

	-- Health / power colour follow the live RaidHealthColor option. Party reuses the
	-- same "raid" aura + colour config, so both boxes read the same index.
	local hIdx = ufs["RaidHealthColor"]
	local cr, cg, cb = B.ClassColor(DB.MyClass)
	local hr, hg, hb, ha = .1, .1, .1, 1
	local hTex = DB.normTex
	if hIdx == 2 then -- class colour
		hr, hg, hb = cr, cg, cb
	elseif hIdx == 3 then -- gradient by health %
		hr, hg, hb = .7, 1, 0
	elseif hIdx == 4 then -- transparent
		hr, hg, hb, ha = 0, 0, 0, 0
	elseif hIdx == 5 then -- class gradient texture
		hr, hg, hb = cr, cg, cb
		hTex = DB.classGradientTex
	end
	-- Power: power-type colour for idx 2/5, else class colour.
	local pr, pg, pb
	if hIdx == 2 or hIdx == 5 then
		pr, pg, pb = .2, .4, .8
	else
		pr, pg, pb = cr, cg, cb
	end

	-- Raid single frame (real size).
	local u = GetUnit(1, preview.raidBox)
	u.f:SetSize(rW, rFH)
	u.f:SetPoint("CENTER", preview.raidBox, "CENTER", 0, 0)
	u.health:SetStatusBarTexture(hTex)
	u.health:SetStatusBarColor(hr, hg, hb, ha)
	u.power:SetStatusBarColor(pr, pg, pb)
	u.power:SetHeight(rpH)
	u.power:SetShown(rpH > 0)
	u.name:SetText("Name")
	u.hp:SetText("100%")

	-- Party single frame (real size).
	local p = GetUnit(2, preview.partyBox)
	p.f:SetSize(pW, pFH)
	p.f:SetPoint("CENTER", preview.partyBox, "CENTER", 0, 0)
	p.health:SetStatusBarTexture(hTex)
	p.health:SetStatusBarColor(hr, hg, hb, ha)
	p.power:SetStatusBarColor(pr, pg, pb)
	p.power:SetHeight(pPH)
	p.power:SetShown(pPH > 0)
	p.name:SetText("Name")
	p.hp:SetText("100%")

	-- Aura overlay on BOTH frames (party reuses the raid aura config + layout).
	-- Cooldown countdown text follows the live per-type raid aura options.
	local cd = {
		buffText   = ufs["RaidBuffCDText"],
		buffSize   = min(max(ufs["RaidBuffCDSize"] or 12, 5), 16),
		debuffText = ufs["RaidDebuffCDText"],
		debuffSize = min(max(ufs["RaidDebuffCDSize"] or 12, 5), 16),
		bigText    = ufs["RaidBigDefensiveCDText"],
		bigSize    = min(max(ufs["RaidBigDefensiveCDSize"] or 12, 5), 16),
	}

	local ii = 0
	ii = DrawAuras(unitPool[1].f, rW, ufs, ii, cd)
	ii = DrawAuras(unitPool[2].f, pW, ufs, ii, cd)

	-- Corner indicators use their own dense index so #indicatorPool is reliable.
	local ind = 0
	ind = DrawCornerIndicators(unitPool[1].f, ufs, ind)
	ind = DrawCornerIndicators(unitPool[2].f, ufs, ind)

	-- Hide leftovers from a previous (larger) draw.
	for i = 2 + 1, #unitPool do unitPool[i].f:Hide() end
	for i = ii + 1, #iconPool do iconPool[i]:Hide() end
	for i = ind + 1, #indicatorPool do indicatorPool[i]:Hide() end

	local sp = 2
	local hpModes = {L["Default Dark"], L["ClassColorHP"], L["GradientHP"], L["ClearHealth"], L["ClearClass"]}
	local hpMode = hpModes[hIdx] or hpModes[1]
	local bOn = cd.buffText and L["PreviewOn"] or L["PreviewOff"]
	local dOn = cd.debuffText and L["PreviewOn"] or L["PreviewOff"]
	preview.raidTitle:SetText(format(
		L["PreviewRaidTitle"], rW, rH, rpH, sp))
	preview.partyTitle:SetText(format(
		L["PreviewPartyTitle"], pW, pH, pPH, sp))
	preview.info1:SetText(format(
		L["PreviewAuraInfo1"],
		hpMode,
		ufs["RaidBuffSize"], ufs["RaidNumBuff"], ufs["RaidDebuffSize"], ufs["RaidNumDebuff"],
		ufs["RaidBigDefensive"] and L["PreviewOn"] or L["PreviewOff"])
	)
	preview.info2:SetText(format(
		L["PreviewAuraInfo2"],
		bOn, cd.buffSize, dOn, cd.debuffSize)
	)

	-- Corner indicator summary (SpellsIndicator).
	local biOn = ufs["RaidBuffIndicator"] and L["PreviewOn"] or L["PreviewOff"]
	local biModes = {L["BI_Blocks"], L["BI_Icons"], L["BI_Numbers"]}
	local biMode = biModes[ufs["BuffIndicatorType"] or 1] or biModes[1]
	local biSize = floor((ufs["RaidSpellSize"] or 10) * (ufs["BuffIndicatorScale"] or 1) + .5)
	local biCount = 0
	local UF = B:GetModule("UnitFrames")
	if UF.CornerSpells then
		for _ in pairs(UF.CornerSpells) do biCount = biCount + 1 end
	end
	preview.cornerInfo:SetText(format(
		L["PreviewCornerInfo"],
		biOn, biSize, biMode, biCount)
	)
end

function G:ToggleFramePreview()
	if preview and preview:IsShown() then
		preview:Hide()
	else
		G:CreateFramePreview()
	end
end

function G:CreateFramePreview()
	if preview then
		preview:Show()
		G:UpdateFramePreview()
		return
	end

	preview = CreateFrame("Frame", "NDuiFramePreview", UIParent)
	preview:SetSize(600, 380)
	preview:SetPoint("CENTER")
	preview:SetFrameStrata("DIALOG")
	B.CreateMF(preview)
	B.SetBD(preview)
	B.CreateFS(preview, 16, L["FramePreview"], true, "TOP", 0, -10)
	B.AddTooltip(preview, "ANCHOR_TOP", L["FramePreviewTip"], "info", true)

	local close = B.CreateButton(preview, 80, 20, CLOSE)
	close:SetPoint("BOTTOMRIGHT", -20, 15)
	close:SetScript("OnClick", function() preview:Hide() end)

	local raidBox = CreateFrame("Frame", nil, preview)
	raidBox:SetPoint("TOPLEFT", 20, -50)
	raidBox:SetSize(270, 220)
	B.CreateBDFrame(raidBox, .25)
	preview.raidBox = raidBox

	local partyBox = CreateFrame("Frame", nil, preview)
	partyBox:SetPoint("TOPLEFT", 300, -50)
	partyBox:SetSize(270, 220)
	B.CreateBDFrame(partyBox, .25)
	preview.partyBox = partyBox

	preview.raidTitle = B.CreateFS(raidBox, 12, "", true, "TOP", 0, -2)
	preview.partyTitle = B.CreateFS(partyBox, 12, "", true, "TOP", 0, -2)
	preview.info1 = B.CreateFS(preview, 12, "", true, "BOTTOM", 0, 42)
	preview.info2 = B.CreateFS(preview, 12, "", true, "BOTTOM", 0, 62)
	preview.cornerInfo = B.CreateFS(preview, 12, "", true, "BOTTOM", 0, 84)

	preview:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > .15 then
			self.elapsed = 0
			G:UpdateFramePreview()
		end
	end)

	G:UpdateFramePreview()
end
