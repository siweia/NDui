local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local GAP = 3 -- spacing between the main and offhand bars
local MIN_MOVER_HEIGHT = 14 -- keep the mover draggable on thin bars
local CAST_TIME = .5 -- Auto Shot cast time, drawn as the tail of a ranged swing

-- Auto Shot needs the hunter to stand still for its cast, so the last 0.5s of a
-- ranged swing is drawn as its own zone on the main bar.
function UF:UpdateSwingCastZone(swing)
	local bar = swing.Main
	local duration = bar.duration
	if not duration or duration <= 0 then return end

	bar.Cast:SetWidth(math.min(CAST_TIME, duration) / duration * bar:GetWidth())
end

-- Shared by creation and the GUI, so the layout is only maintained in one place.
function UF:UpdateSwingBarLayout(swing)
	local width, height = C.db["UFs"]["SwingWidth"], C.db["UFs"]["SwingHeight"]

	swing:SetSize(width, height)
	swing.Main:SetSize(width, height)
	swing.Offhand:SetSize(width, height)

	swing.Offhand:ClearAllPoints()
	if C.db["UFs"]["OffOnTop"] then
		swing.Offhand:SetPoint("BOTTOMLEFT", swing, "TOPLEFT", 0, GAP)
	else
		swing.Offhand:SetPoint("TOPLEFT", swing.Main, "BOTTOMLEFT", 0, -GAP)
	end

	-- The bars hang from the top edge of the mover, so changing the height keeps
	-- the bar in place and grows it downwards. The mover is kept at a draggable
	-- height and covers both bars in the default (offhand below) layout.
	swing:ClearAllPoints()
	swing:SetPoint("TOPLEFT", swing.mover)
	swing.mover:SetSize(width, math.max(2*height + GAP, MIN_MOVER_HEIGHT))

	UF:UpdateSwingCastZone(swing)
end

function UF:CreateSwingBar(self)
	local width, height = C.db["UFs"]["SwingWidth"], C.db["UFs"]["SwingHeight"]
	local moverHeight = math.max(2*height + GAP, MIN_MOVER_HEIGHT)

	local element = CreateFrame("Frame", nil, self)
	element:SetSize(width, height)
	element.mover = B.Mover(element, L["UFs SwingBar"], "Swing", {"TOP", UIParent, "BOTTOM", 0, 173}, width, moverHeight)
	element:Hide()

	local function CreateBar(barHeight, point, relative, relativePoint, offset)
		local bar = CreateFrame("StatusBar", nil, element)
		bar:SetSize(element:GetWidth(), barHeight)
		bar:SetPoint(point, relative, relativePoint, 0, offset)
		bar:SetMinMaxValues(0, 1)
		B.CreateSB(bar, true)
		bar:Hide()
		return bar
	end

	element.Main = CreateBar(height, "TOPLEFT", element, "TOPLEFT", 0)
	element.Offhand = CreateBar(height, "TOPLEFT", element.Main, "BOTTOMLEFT", -GAP)

	-- Red zone at the end of the main bar: the Auto Shot cast window.
	element.Main.Cast = element.Main:CreateTexture(nil, "BACKGROUND", nil, 1)
	element.Main.Cast:SetPoint("TOPRIGHT")
	element.Main.Cast:SetPoint("BOTTOMRIGHT")
	element.Main.Cast:SetWidth(1)
	element.Main.Cast:SetColorTexture(.9, 0, 0)
	element.Main.Cast:Hide()

	-- A 10pt text does not fit into two 3px bars, a single one is used instead.
	-- The bars are child frames of the element (one frame level above it), so the
	-- text needs its own frame above them or the statusbar fill would cover it.
	local overlay = CreateFrame("Frame", nil, element)
	overlay:SetAllPoints(element)
	overlay:SetFrameLevel(element.Main:GetFrameLevel() + 2)
	element.Time = B.CreateFS(overlay, C.db["UFs"]["SwingFontSize"] or 10)
	element.Time:SetShown(C.db["UFs"]["SwingTimer"])

	UF:UpdateSwingBarLayout(element)

	self.Swing = element
end
