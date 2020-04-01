local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinReforgeUI(frame, index)
	B.StripTextures(frame, index)
	B.CreateBDFrame(frame.Background)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinIcon(frame.ItemSlot.Icon)

	local buttonFrame = frame.ButtonFrame
	B.StripTextures(buttonFrame)
	buttonFrame.MoneyFrameEdge:SetAlpha(0)
	local bg = B.CreateBDFrame(buttonFrame, .25)
	bg:SetPoint("TOPLEFT", buttonFrame.MoneyFrameEdge, 3, 0)
	bg:SetPoint("BOTTOMRIGHT", buttonFrame.MoneyFrameEdge, 0, 2)
	if buttonFrame.AzeriteRespecButton then B.Reskin(buttonFrame.AzeriteRespecButton) end
	if buttonFrame.ActionButton then B.Reskin(buttonFrame.ActionButton) end
	if buttonFrame.Currency then B.ReskinIcon(buttonFrame.Currency.icon) end
end

C.themes["Blizzard_AzeriteRespecUI"] = function()
	reskinReforgeUI(AzeriteRespecFrame, 15)
end

C.themes["Blizzard_ItemInteractionUI"] = function()
	reskinReforgeUI(ItemInteractionFrame)
end