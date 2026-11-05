local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

function UF:CreateSwingBar(self)
	local element = CreateFrame("Frame", nil, self)
	element:SetSize(self:GetWidth(), 21)
	element:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -12)
	element:Hide()

	local function CreateBar(height, point, relative, relativePoint, offset)
		local bar = CreateFrame("StatusBar", nil, element)
		bar:SetHeight(height)
		bar:SetPoint(point, relative, relativePoint, 0, offset)
		bar:SetWidth(element:GetWidth())
		bar:SetMinMaxValues(0, 1)
		B.CreateSB(bar)
		bar.Time = B.CreateFS(bar, 10)
		bar.Time:ClearAllPoints()
		bar.Time:SetPoint("CENTER")
		bar:Hide()
		return bar
	end

	element.Main = CreateBar(10, "TOPLEFT", element, "TOPLEFT", 0)
	element.Offhand = CreateBar(8, "TOPLEFT", element.Main, "BOTTOMLEFT", -3)
	self.Swing = element
end
