local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.CreateBD(ReadyCheckFrame)
	B.CreateSD(ReadyCheckFrame)
	ReadyCheckPortrait:SetAlpha(0)
	select(2, ReadyCheckListenerFrame:GetRegions()):Hide()

	ReadyCheckFrame:HookScript("OnShow", function(self)
		if self.initiator and UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	B.Reskin(ReadyCheckFrameYesButton)
	B.Reskin(ReadyCheckFrameNoButton)
end)