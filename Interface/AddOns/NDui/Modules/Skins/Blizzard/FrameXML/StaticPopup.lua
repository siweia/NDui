local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local r, g, b = DB.r, DB.g, DB.b

	local function colourMinimize(f)
		if f:IsEnabled() then
			f.minimize:SetVertexColor(r, g, b)
		end
	end

	local function clearMinimize(f)
		f.minimize:SetVertexColor(1, 1, 1)
	end

	for i = 1, 4 do
		local frame = _G["StaticPopup"..i]
		local bu = _G["StaticPopup"..i.."ItemFrame"]
		local close = _G["StaticPopup"..i.."CloseButton"]

		local gold = _G["StaticPopup"..i.."MoneyInputFrameGold"]
		local silver = _G["StaticPopup"..i.."MoneyInputFrameSilver"]
		local copper = _G["StaticPopup"..i.."MoneyInputFrameCopper"]

		_G["StaticPopup"..i.."ItemFrameNameFrame"]:Hide()
		_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(.08, .92, .08, .92)

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")
		bu:SetPushedTexture("")
		B.CreateBDFrame(bu)
		bu.IconBorder:SetAlpha(0)

		B.StripTextures(frame)
		B.SetBD(frame)
		for j = 1, 4 do
			B.Reskin(frame["button"..j])
		end
		B.Reskin(frame["extraButton"])
		B.ReskinClose(close)

		close.minimize = close:CreateTexture(nil, "OVERLAY")
		close.minimize:SetSize(9, 1)
		close.minimize:SetPoint("CENTER")
		close.minimize:SetTexture(DB.bdTex)
		close.minimize:SetVertexColor(1, 1, 1)
		close:HookScript("OnEnter", colourMinimize)
		close:HookScript("OnLeave", clearMinimize)

		B.ReskinInput(_G["StaticPopup"..i.."EditBox"], 20)
		B:UpdateMoneyDisplay(gold, silver, copper)
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

			closeButton:SetNormalTexture("")
			closeButton:SetPushedTexture("")

			if info.closeButtonIsHide then
				for _, pixel in pairs(closeButton.pixels) do
					pixel:Hide()
				end
				closeButton.minimize:Show()
			else
				for _, pixel in pairs(closeButton.pixels) do
					pixel:Show()
				end
				closeButton.minimize:Hide()
			end
		end
	end)

	-- PlayerReportFrame
	PlayerReportFrame:HookScript("OnShow", function(self)
		if not self.styled then
			B.StripTextures(self)
			B.SetBD(self)
			B.StripTextures(self.Comment)
			B.ReskinInput(self.Comment)
			B.Reskin(self.ReportButton)
			B.Reskin(self.CancelButton)

			self.styled = true
		end
	end)

	-- PVP ready dialog
	local PVPReadyDialog = PVPReadyDialog

	B.StripTextures(PVPReadyDialog)
	B.SetBD(PVPReadyDialog)
	B.Reskin(PVPReadyDialog.enterButton)
	B.Reskin(PVPReadyDialog.hideButton)
end)