local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Infobar")

function module:RegisterInfobar(point)
	if not self.modules then self.modules = {} end

	local info = CreateFrame("Frame", nil, UIParent)
	info:SetHitRectInsets(0, 0, -10, -10)
	info.text = info:CreateFontString(nil, "OVERLAY")
	info.text:SetFont(unpack(C.Infobar.Fonts))
	info.text:SetPoint(unpack(point))
	info:SetAllPoints(info.text)
	tinsert(self.modules, info)

	return info
end

function module:LoadInfobar(info)
	if info.eventList then
		for _, event in pairs(info.eventList) do
			info:RegisterEvent(event)
		end
		info:SetScript("OnEvent", info.onEvent)
	end
	if info.onEnter then
		info:SetScript("OnEnter", info.onEnter)
	end
	if info.onLeave then
		info:SetScript("OnLeave", info.onLeave)
	end
	if info.onMouseUp then
		info:SetScript("OnMouseUp", info.onMouseUp)
	end
	if info.onUpdate then
		info:SetScript("OnUpdate", info.onUpdate)
	end
end

function module:OnLogin()
	if not self.modules then return end
	for _, info in pairs(self.modules) do
		self:LoadInfobar(info)
	end
end