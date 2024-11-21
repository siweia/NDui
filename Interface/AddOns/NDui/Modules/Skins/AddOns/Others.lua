local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

function S:WhatsTraining()
	if not IsAddOnLoaded("WhatsTraining") then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local done
	SpellBookFrame:HookScript("OnShow", function()
		if done then return end

		B.StripTextures(WhatsTrainingFrame)
		local bg = B.CreateBDFrame(WhatsTrainingFrameScrollBar, 1)
		bg:SetPoint("TOPLEFT", 20, 0)
		bg:SetPoint("BOTTOMRIGHT", 4, 0)
		B.ReskinScroll(WhatsTrainingFrameScrollBarScrollBar)
		B:GetModule("Tooltip").ReskinTooltip(WhatsTrainingTooltip)

		for i = 1, 22 do
			local bar = _G["WhatsTrainingFrameRow"..i.."Spell"]
			if bar and bar.icon then
				B.ReskinIcon(bar.icon)
			end
		end

		done = true
	end)
end

function S:ResetRecount()
	Recount:RestoreMainWindowPosition(797, -405, 320, 220)

	Recount.db.profile.Locked = true
	Recount:LockWindows(true)

	Recount.db.profile.MainWindowHeight = 320
	Recount.db.profile.MainWindowWidth = 220
	Recount:ResizeMainWindow()

	Recount.db.profile.MainWindow.RowHeight = 18
	Recount:BarsChanged()

	Recount.db.profile.BarTexture = "normTex"
	Recount.db.profile.Font = nil
	Recount:UpdateBarTextures()

	C.db["Skins"]["ResetRecount"] = false
end

function S:ResetRocountFont()
	for _, row in pairs(Recount.MainWindow.Rows) do
		local font, fontSize = row.LeftText:GetFont()
		row.LeftText:SetFont(font, fontSize, DB.Font[3])
		row.RightText:SetFont(font, fontSize, DB.Font[3])
	end
end

function S:RecountSkin()
	if not C.db["Skins"]["Recount"] then return end
	if not IsAddOnLoaded("Recount") then return end

	local frame = Recount_MainWindow
	B.StripTextures(frame)
	local bg = B.SetBD(frame)
	bg:SetPoint("TOPLEFT", 0, -10)
	frame.bg = bg

	local open, close = S:CreateToggle(frame)
	open:HookScript("OnClick", function()
		Recount.MainWindow:Show()
		Recount:RefreshMainWindow()
	end)
	close:HookScript("OnClick", function()
		Recount.MainWindow:Hide()
	end)

	if C.db["Skins"]["ResetRecount"] then S:ResetRecount() end
	hooksecurefunc(Recount, "ResetPositions", S.ResetRecount)

	S:ResetRocountFont()
	hooksecurefunc(Recount, "BarsChanged", S.ResetRocountFont)

	B.ReskinArrow(frame.LeftButton, "left")
	B.ReskinArrow(frame.RightButton, "right")
	B.ReskinClose(frame.CloseButton, frame.bg, -2, -2)

	-- Force to show window on init
	Recount.MainWindow:Show()
end

function S:BindPad()
	if not IsAddOnLoaded("BindPad") then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	BindPadFrame.bg = B.ReskinPortraitFrame(BindPadFrame, 10, -10, -30, 70)
	for i = 1, 4 do
		B.ReskinTab(_G["BindPadFrameTab"..i])
	end
	B.ReskinScroll(BindPadScrollFrameScrollBar)
	B.ReskinCheck(BindPadFrameCharacterButton)
	B.ReskinCheck(BindPadFrameSaveAllKeysButton)
	B.ReskinCheck(BindPadFrameShowHotkeyButton)
	B.Reskin(BindPadFrameExitButton)
	B.ReskinArrow(BindPadShowLessSlotButton, "left")
	B.ReskinArrow(BindPadShowMoreSlotButton, "right")

	B.StripTextures(BindPadDialogFrame)
	B.SetBD(BindPadDialogFrame)
	B.Reskin(BindPadDialogFrame.cancelbutton)
	B.Reskin(BindPadDialogFrame.okaybutton)

	hooksecurefunc("BindPadSlot_UpdateState", function(slot)
		if slot.styled then return end

		slot:DisableDrawLayer("ARTWORK")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.icon:SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(slot, .25)
		slot.border:SetTexture()

		B.StripTextures(slot.addbutton)
		local nt = slot.addbutton:GetNormalTexture()
		nt:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		nt:SetTexCoord(0, .4375, 0, .4375)

		slot.styled = true
	end)

	B.StripTextures(BindPadMacroPopupFrame)
	BindPadMacroPopupFrame:SetPoint("TOPLEFT", BindPadFrame.bg, "TOPRIGHT", 3, -40)
	B.SetBD(BindPadMacroPopupFrame)
	B.StripTextures(BindPadMacroPopupEditBox)
	B.CreateBDFrame(BindPadMacroPopupEditBox, .25)
	B.ReskinScroll(BindPadMacroPopupScrollFrameScrollBar)
	B.Reskin(BindPadMacroPopupOkayButton)
	B.Reskin(BindPadMacroPopupCancelButton)

	hooksecurefunc("BindPadMacroPopupFrame_Update", function()
		for i = 1, 20 do
			local bu = _G["BindPadMacroPopupButton"..i]
			local ic = _G["BindPadMacroPopupButton"..i.."Icon"]

			if not bu.styled then
				bu:SetCheckedTexture(DB.pushedTex)
				select(2, bu:GetRegions()):Hide()
				local hl = bu:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(ic)

				ic:SetPoint("TOPLEFT", C.mult, -C.mult)
				ic:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
				ic:SetTexCoord(unpack(DB.TexCoord))
				B.CreateBDFrame(ic, .25)

				bu.styled = true
			end
		end
	end)

	B.StripTextures(BindPadBindFrame)
	B.SetBD(BindPadBindFrame)
	B.ReskinClose(BindPadBindFrameCloseButton)
	B.ReskinCheck(BindPadBindFrameForAllCharacterButton)
	B.Reskin(BindPadBindFrameUnbindButton)
	B.Reskin(BindPadBindFrameExitButton)

	B.ReskinPortraitFrame(BindPadMacroFrame, 10, -10, -30, 70)
	B.ReskinScroll(BindPadMacroFrameScrollFrameScrollBar)
	B.Reskin(BindPadMacroFrameEditButton)
	B.Reskin(BindPadMacroDeleteButton)
	B.Reskin(BindPadMacroFrameTestButton)
	B.Reskin(BindPadMacroFrameExitButton)
	B.StripTextures(BindPadMacroFrameTextBackground)
	B.CreateBDFrame(BindPadMacroFrameTextBackground, .25)
	B.StripTextures(BindPadMacroFrameSlotButton)
	B.ReskinIcon(BindPadMacroFrameSlotButtonIcon)
end

function S:PostalSkin()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not IsAddOnLoaded("Postal") then return end
	if not PostalOpenAllButton then return end -- update your postal

	B.Reskin(PostalSelectOpenButton)
	B.Reskin(PostalSelectReturnButton)
	B.Reskin(PostalOpenAllButton)
	B.Reskin(PostalForwardButton)
	B.ReskinArrow(Postal_ModuleMenuButton, "down")
	B.ReskinArrow(Postal_OpenAllMenuButton, "down")
	B.ReskinArrow(Postal_BlackBookButton, "down")
	for i = 1, 7 do
		local cb = _G["PostalInboxCB"..i]
		if cb then
			B.ReskinCheck(cb)
		end
	end

	Postal_ModuleMenuButton:ClearAllPoints()
	Postal_ModuleMenuButton:SetPoint("RIGHT", MailFrame.CloseButton, "LEFT", -2, 0)
	Postal_OpenAllMenuButton:SetPoint("LEFT", PostalOpenAllButton, "RIGHT", 2, 0)
	Postal_BlackBookButton:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 2, 0)

	for i = 1, 16 do
		local button = _G["Postal_QuickAttachButton"..i]
		if button then
			button:GetNormalTexture():SetAlpha(0)
			button:GetPushedTexture():SetAlpha(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.ReskinIcon(button.icon)
		end
	end
end

local function DecreaseTextSize(parent)
	for i = 1, parent:GetNumChildren() do
		local child = select(i, parent:GetChildren())
		if child.Label then
			child.Label:SetFontObject(Game13Font)

			if child.Label:GetPoint() == "CENTER" and child.BackgroundTex then
				child.BackgroundTex:Hide()

				local line = child:CreateTexture(nil, "ARTWORK")
				line:SetSize(130, C.mult)
				line:SetPoint("BOTTOM", child.BackgroundTex)
				line:SetColorTexture(1, 1, 1, .25)
			end
		end
		if child.Value then child.Value:SetFontObject(Game13Font) end
	end
end

function S:CharacterStatsTBC()
	if not IsAddOnLoaded("CharacterStatsTBC") then return end

	for i = 1, CharacterFrame:GetNumChildren() do
		local child = select(i, CharacterFrame:GetChildren())
		if child and child.leftStatsDropDown then
			B.ReskinDropDown(child.leftStatsDropDown)
			DecreaseTextSize(child.leftStatsDropDown)
		end
		if child and child.rightStatsDropDown then
			B.ReskinDropDown(child.rightStatsDropDown)
			DecreaseTextSize(child.rightStatsDropDown)
		end
	end

	local sideStatsFrame = _G.CSC_SideStatsFrame
	if sideStatsFrame then
		B.StripTextures(sideStatsFrame)
		B.SetBD(sideStatsFrame)
		B.ReskinClose(sideStatsFrame.CloseButton)
		B.ReskinScroll(sideStatsFrame.ScrollFrame.ScrollBar)

		sideStatsFrame:SetHeight(422)
		sideStatsFrame:SetPoint("LEFT", PaperDollItemsFrame, "RIGHT", -32, 29)
		DecreaseTextSize(sideStatsFrame.ScrollChild)
	end
end

local function restyleMRTWidget(self)
	local iconTexture = self.iconTexture
	local bar = self.statusbar
	local parent = self.parent
	local width = parent.barWidth or 100
	local mult = (parent.iconSize or 24) + 5
	local offset = 3

	if not self.styled then
		B.SetBD(iconTexture)
		self.__bg = B.SetBD(bar)
		self.background:SetAllPoints(bar)

		self.styled = true
	end
	iconTexture:SetTexCoord(unpack(DB.TexCoord))
	self.__bg:SetShown(parent.optionAlphaTimeLine ~= 0)

	if parent.optionIconPosition == 3 or parent.optionIconTitles then
		self.statusbar:SetPoint("RIGHT", self, -offset, 0)
		mult = 0
	elseif parent.optionIconPosition == 2 then
		self.icon:SetPoint("RIGHT", self, -offset, 0)
		self.statusbar:SetPoint("LEFT", self, offset, 0)
		self.statusbar:SetPoint("RIGHT", self, -mult, 0)
	else
		self.icon:SetPoint("LEFT", self, offset, 0)
		self.statusbar:SetPoint("LEFT", self, mult, 0)
		self.statusbar:SetPoint("RIGHT", self, -offset, 0)
	end

	self.timeline.width = width - mult - offset
	self.timeline:SetWidth(self.timeline.width)
	self.border.top:Hide()
	self.border.bottom:Hide()
	self.border.left:Hide()
	self.border.right:Hide()
end

local MRTLoaded
local function LoadMRTSkin()
	if MRTLoaded then return end
	MRTLoaded = true

	local name = "MRTRaidCooldownCol"
	for i = 1, 10 do
		local column = _G[name..i]
		local lines = column and column.lines
		if lines then
			for j = 1, #lines do
				local line = lines[j]
				if line.UpdateStyle then
					hooksecurefunc(line, "UpdateStyle", restyleMRTWidget)
					line:UpdateStyle()
				end
			end
		end
	end
end

function S:MRT_Skin()
	if not IsAddOnLoaded("MRT") then return end

	local isEnabled = VMRT and VMRT.ExCD2 and VMRT.ExCD2.enabled
	if isEnabled then
		LoadMRTSkin()
	else
		hooksecurefunc(MRTOptionsFrameExCD2, "Load", function(self)
			if self.chkEnable then
				self.chkEnable:HookScript("OnClick", LoadMRTSkin)
			end
		end)
	end
end

function S:CodexLite()
	if not IsAddOnLoaded("CodexLite") then return end

	local frame = _G.CODEX_LITE_SETTING_UI
	if frame then
		local styled
		hooksecurefunc(frame, "Show", function()
			if styled then return end
			frame.BG:Hide()
			B.SetBD(frame)

			for i = 1, frame:GetNumChildren() do
				local tab = select(i, frame:GetChildren())
				local panel = tab and tab.Panel
				if panel then
					for j = 1, panel:GetNumChildren() do
						local child = select(j, panel:GetChildren())
						if not child.styled then
							if child:IsObjectType("CheckButton") then
								B.ReskinCheck(child)
							elseif child:IsObjectType("Slider") then
								B.ReskinSlider(child)
							end
							child.styled = true
						end
					end
				end
			end

			styled = true
		end)
	end
end

function S:LoadOtherSkins()
	S:WhatsTraining()
	S:RecountSkin()
	S:BindPad()
	C_Timer.After(1, S.PostalSkin)
	S:CharacterStatsTBC()
	S:MRT_Skin()
	S:CodexLite()
end