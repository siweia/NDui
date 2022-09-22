local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	-- BattlefieldFrame
	B.ReskinPortraitFrame(BattlefieldFrame, 15, -15, -35, 73)
	B.Reskin(BattlefieldFrameJoinButton)
	B.Reskin(BattlefieldFrameCancelButton)
	B.Reskin(BattlefieldFrameGroupJoinButton)
	BattlefieldFrameBGTex:Hide()
	B.CreateBDFrame(BattlefieldFrameInfoScrollFrame, .25)

	if WintergraspTimer then -- removed in 45704, needs review
		local wintergraspIcon = WintergraspTimer.texture
		wintergraspIcon:SetTexture(135865) -- Spell_Frost_WizardMark
		B.CreateBDFrame(wintergraspIcon, .25)

		hooksecurefunc(wintergraspIcon, "SetTexCoord", function(self, _, _, y1, y2)
			if self.isCutting then return end
			self.isCutting = true

			if y1 == .5 and y2 == 1 then
				self:SetDesaturated(false) -- can queue
			elseif y1 == 0 and y2 == .5 then
				self:SetDesaturated(true) -- can't queue
			end
			self:SetTexCoord(unpack(DB.TexCoord))

			self.isCutting = nil
		end)
		wintergraspIcon:SetTexCoord(0, 1, 0, .5)
	end

	-- WorldStateScoreFrame
	B.ReskinPortraitFrame(WorldStateScoreFrame, 13, -15, -108, 70)
	B.ReskinScroll(WorldStateScoreScrollFrameScrollBar)
	for i = 1, 3 do
		B.ReskinTab(_G["WorldStateScoreFrameTab"..i])
	end
	B.Reskin(WorldStateScoreFrameLeaveButton)

	-- ArenaFrame
	B.ReskinPortraitFrame(ArenaFrame, 15, -15, -35, 73)
	B.Reskin(ArenaFrameJoinButton)
	B.Reskin(ArenaFrameCancelButton)
	B.Reskin(ArenaFrameGroupJoinButton)

	-- Temp fix for ArenaFrame label
	local relF, parent, relT, x, y = ArenaFrameFrameLabel:GetPoint()
	if parent == BattlefieldFrame then
		ArenaFrameFrameLabel:SetPoint(relF, ArenaFrame, relT, x, y)
	end

	-- ArenaRegistrarFrame
	ArenaAvailableServicesText:SetTextColor(1, 1, 1)
	ArenaAvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(ArenaRegistrarFrame, 15, -15, -30, 65)
	B.StripTextures(ArenaRegistrarGreetingFrame)
	ArenaRegistrarFrameEditBox:SetHeight(20)
	ArenaRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(ArenaRegistrarFrameEditBox)
	B.Reskin(ArenaRegistrarFrameGoodbyeButton)
	B.Reskin(ArenaRegistrarFramePurchaseButton)
	B.Reskin(ArenaRegistrarFrameCancelButton)
end)