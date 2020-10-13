local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinConduitList(frame)
	local header = frame.CategoryButton.Container
	if not header.styled then
		header:DisableDrawLayer("BACKGROUND")
		local bg = B.CreateBDFrame(header, .25)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", 15, 0)

		header.styled = true
	end

	for button in frame.pool:EnumerateActive() do
		if not button.styled then
			for _, element in ipairs(button.Hovers) do
				element:SetColorTexture(1, 1, 1, .25)
			end
			button.PendingBackground:SetColorTexture(1, .8, 0, .25)
			button.Spec.IconOverlay:Hide()
			B.ReskinIcon(button.Spec.Icon):SetFrameLevel(8)

			button.styled = true
		end
	end
end

C.themes["Blizzard_Soulbinds"] = function()
	B.StripTextures(SoulbindViewer)
	SoulbindViewer.Background:SetAlpha(0)
	B.SetBD(SoulbindViewer)
	B.ReskinClose(SoulbindViewer.CloseButton)
	B.Reskin(SoulbindViewer.CommitConduitsButton)
	B.Reskin(SoulbindViewer.ActivateSoulbindButton)

	local scrollBox = SoulbindViewer.ConduitList.ScrollBox
	for i = 1, 3 do
		hooksecurefunc(scrollBox.ScrollTarget.Lists[i], "UpdateLayout", ReskinConduitList)
	end
	select(2, scrollBox:GetChildren()):Hide()
end