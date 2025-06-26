local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function colorMinimize(f)
	if f:IsEnabled() then
		f.minimize:SetVertexColor(r, g, b)
	end
end

local function clearMinimize(f)
	f.minimize:SetVertexColor(1, 1, 1)
end

local function updateMinorButtonState(button)
	if button:GetChecked() then
		button.bg:SetBackdropColor(1, .8, 0, .25)
	else
		button.bg:SetBackdropColor(0, 0, 0, .25)
	end
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for i = 1, 4 do
		local frame = _G["StaticPopup"..i]
		local bu = _G["StaticPopup"..i.."ItemFrame"]
		local icon = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local close = _G["StaticPopup"..i.."CloseButton"]

		local gold = _G["StaticPopup"..i.."MoneyInputFrameGold"]
		local silver = _G["StaticPopup"..i.."MoneyInputFrameSilver"]
		local copper = _G["StaticPopup"..i.."MoneyInputFrameCopper"]

		local ItemFrameNameFrame = _G["StaticPopup"..i.."ItemFrameNameFrame"]
		if ItemFrameNameFrame then
			ItemFrameNameFrame:Hide()
		end

		if bu then
			bu:SetNormalTexture(0)
			bu:SetHighlightTexture(0)
			bu:SetPushedTexture(0)
			bu.bg = B.ReskinIcon(icon)
			B.ReskinIconBorder(bu.IconBorder)

			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT", bu.bg, "TOPRIGHT", 2, 0)
			bg:SetPoint("BOTTOMRIGHT", bu.bg, 115, 0)
		end

		silver:SetPoint("LEFT", gold, "RIGHT", 1, 0)
		copper:SetPoint("LEFT", silver, "RIGHT", 1, 0)

		if not DB.isNewPatch then
			frame.Border:Hide()
			for j = 1, 4 do
				B.Reskin(frame["button"..j])
			end
			B.Reskin(frame.extraButton)
		else
			B.StripTextures(frame)
			for j = 1, 4 do
				B.Reskin(_G["StaticPopup"..i.."Button"..j])
			end
		end
		B.SetBD(frame)
		B.ReskinClose(close)

		close.minimize = close:CreateTexture(nil, "OVERLAY")
		close.minimize:SetSize(9, C.mult)
		close.minimize:SetPoint("CENTER")
		close.minimize:SetTexture(DB.bdTex)
		close.minimize:SetVertexColor(1, 1, 1)
		close:HookScript("OnEnter", colorMinimize)
		close:HookScript("OnLeave", clearMinimize)

		B.ReskinInput(_G["StaticPopup"..i.."EditBox"], 20)
		B.ReskinInput(gold)
		B.ReskinInput(silver)
		B.ReskinInput(copper)
	end

	hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
		local info = StaticPopupDialogs[which]

		if not info then return end

		local dialog = nil
		dialog = StaticPopup_FindVisible(which, data)

		if not dialog then
			local index = 1
			if info.preferredIndex then
				index = info.preferredIndex
			end
			for i = index, STATICPOPUP_NUMDIALOGS do
				local frame = _G["StaticPopup"..i]
				if not frame:IsShown() then
					dialog = frame
					break
				end
			end

			if not dialog and info.preferredIndex then
				for i = 1, info.preferredIndex do
					local frame = _G["StaticPopup"..i]
					if not frame:IsShown() then
						dialog = frame
						break
					end
				end
			end
		end

		if not dialog then return end

		if info.closeButton then
			local closeButton = _G[dialog:GetName().."CloseButton"]

			closeButton:SetNormalTexture(0)
			closeButton:SetPushedTexture(0)

			if info.closeButtonIsHide then
				closeButton.__texture:Hide()
				closeButton.minimize:Show()
			else
				closeButton.__texture:Show()
				closeButton.minimize:Hide()
			end
		end
	end)

	-- Pet battle queue popup

	B.SetBD(PetBattleQueueReadyFrame)
	B.CreateBDFrame(PetBattleQueueReadyFrame.Art)
	PetBattleQueueReadyFrame.Border:Hide()
	B.Reskin(PetBattleQueueReadyFrame.AcceptButton)
	B.Reskin(PetBattleQueueReadyFrame.DeclineButton)

	-- PlayerReportFrame
	B.StripTextures(ReportFrame)
	B.SetBD(ReportFrame)
	B.ReskinClose(ReportFrame.CloseButton)
	B.Reskin(ReportFrame.ReportButton)
	B.ReskinDropDown(ReportFrame.ReportingMajorCategoryDropdown)
	B.ReskinEditBox(ReportFrame.Comment)

	hooksecurefunc(ReportFrame, "AnchorMinorCategory", function(self)
		if self.MinorCategoryButtonPool then
			for button in self.MinorCategoryButtonPool:EnumerateActive() do
				if not button.styled then
					B.StripTextures(button)
					button.bg = B.CreateBDFrame(button, .25)
					button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					button:HookScript("OnClick", updateMinorButtonState)

					button.styled = true
				end

				updateMinorButtonState(button)
			end
		end
	end)
end)