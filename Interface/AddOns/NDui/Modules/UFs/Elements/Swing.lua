local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

function UF:CreateSwingBar(self)
	local width, height = C.db["UFs"]["SwingWidth"], C.db["UFs"]["SwingHeight"]

	local element = CreateFrame("Frame", nil, self)
	element:SetSize(width, height)
	element.mover = B.Mover(element, L["UFs SwingBar"], "Swing", {"BOTTOM", UIParent, "BOTTOM", 0, 170}, width, height)
	element:ClearAllPoints()
	element:SetPoint("CENTER", element.mover)
	element:Hide()

	local function CreateBar(barHeight, point, relative, relativePoint, offset)
		local bar = CreateFrame("StatusBar", nil, element)
		bar:SetHeight(barHeight)
		bar:SetPoint(point, relative, relativePoint, 0, offset)
		bar:SetWidth(element:GetWidth())
		bar:SetMinMaxValues(0, 1)
		B.CreateSB(bar)
		bar.Time = B.CreateFS(bar, 10)
		bar.Time:ClearAllPoints()
		bar.Time:SetPoint("CENTER")
		bar.Time:SetShown(C.db["UFs"]["SwingTimer"])
		bar:Hide()
		return bar
	end

	element.Main = CreateBar(height, "TOPLEFT", element, "TOPLEFT", 0)
	element.Offhand = CreateBar(height, "TOPLEFT", element.Main, "BOTTOMLEFT", -3)

	if C.db["UFs"]["OffOnTop"] then
		element.Offhand:ClearAllPoints()
		element.Offhand:SetPoint("BOTTOMLEFT", element, "TOPLEFT", 0, 3)
		element.Offhand:SetPoint("BOTTOMRIGHT", element, "TOPRIGHT", 0, 3)
	end

	self.Swing = element
end
