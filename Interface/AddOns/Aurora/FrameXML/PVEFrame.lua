local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	PVEFrame:DisableDrawLayer("ARTWORK")
	PVEFrameLeftInset:DisableDrawLayer("BORDER")
	PVEFrameBlueBg:SetAlpha(0)
	PVEFrameLeftInsetBg:Hide()
	PVEFrame.shadows:SetAlpha(0)
	select(24, PVEFrame:GetRegions()):SetAlpha(0)
	select(25, PVEFrame:GetRegions()):SetAlpha(0)

	PVEFrameTab2:SetPoint("LEFT", PVEFrameTab1, "RIGHT", -15, 0)
	PVEFrameTab3:SetPoint("LEFT", PVEFrameTab2, "RIGHT", -15, 0)

	GroupFinderFrameGroupButton1.icon:SetTexture("Interface\\Icons\\INV_Helmet_08")
	GroupFinderFrameGroupButton2.icon:SetTexture("Interface\\Icons\\Icon_Scenarios")
	GroupFinderFrameGroupButton3.icon:SetTexture("Interface\\Icons\\inv_helmet_06")

	for i = 1, 4 do
		local bu = GroupFinderFrame["groupButton"..i]

		bu.ring:Hide()
		bu.bg:SetTexture(C.media.backdrop)
		bu.bg:SetVertexColor(r, g, b, .2)
		bu.bg:SetAllPoints()

		F.Reskin(bu, true)

		bu.icon:SetTexCoord(.08, .92, .08, .92)
		bu.icon:SetPoint("LEFT", bu, "LEFT")
		bu.icon:SetDrawLayer("OVERLAY")
		bu.icon.bg = F.CreateBG(bu.icon)
		bu.icon.bg:SetDrawLayer("ARTWORK")
	end

	hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
		local self = GroupFinderFrame
		for i = 1, 4 do
			local button = self["groupButton"..i]
			if i == index then
				button.bg:Show()
			else
				button.bg:Hide()
			end
		end
	end)

	F.ReskinPortraitFrame(PVEFrame)
	F.ReskinTab(PVEFrameTab1)
	F.ReskinTab(PVEFrameTab2)
	F.ReskinTab(PVEFrameTab3)
end)