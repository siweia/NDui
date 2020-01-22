local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	ReputationDetailCorner:Hide()
	ReputationDetailDivider:Hide()
	ReputationListScrollFrame:GetRegions():Hide()
	select(2, ReputationListScrollFrame:GetRegions()):Hide()

	ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 2, -28)

	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]

			if statusbar then
				statusbar:SetStatusBarTexture(DB.bdTex)

				if not statusbar.reskinned then
					B.CreateBD(statusbar, .25)
					statusbar.reskinned = true
				end

				_G["ReputationBar"..i.."Background"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
			end
		end
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local bu = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
		B.ReskinExpandOrCollapse(bu)
	end

	B.StripTextures(ReputationDetailFrame)
	B.SetBD(ReputationDetailFrame)
	B.ReskinClose(ReputationDetailCloseButton)
	B.ReskinCheck(ReputationDetailAtWarCheckBox)
	B.ReskinCheck(ReputationDetailInactiveCheckBox)
	B.ReskinCheck(ReputationDetailMainScreenCheckBox)
	B.ReskinCheck(ReputationDetailLFGBonusReputationCheckBox)
	B.ReskinScroll(ReputationListScrollFrameScrollBar)
	select(3, ReputationDetailFrame:GetRegions()):Hide()
end)