local _, ns = ...
local B, C, L, DB = unpack(ns)

local r, g, b, pairs = DB.r, DB.g, DB.b, pairs
local LE_BATTLE_PET_ALLY = Enum.BattlePetOwner.Ally

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["PetBattle"] then return end

	local mult = C.mult

	-- Head Frame
	local frame = PetBattleFrame
	B.StripTextures(frame)
	frame.TopVersusText:SetPoint("TOP", 0, -45)

	-- Weather
	local weather = frame.WeatherFrame
	weather:ClearAllPoints()
	weather:SetPoint("TOP", frame.TopVersusText, "BOTTOM", 0, -15)
	weather.Label:Hide()
	weather.Name:Hide()
	weather.Icon:ClearAllPoints()
	weather.Icon:SetPoint("TOP", frame.TopVersusText, "BOTTOM", 0, -15)
	B.ReskinIcon(weather.Icon, true)
	weather.BackgroundArt:SetPoint("TOP", UIParent)
	weather.Duration:ClearAllPoints()
	weather.Duration:SetPoint("CENTER", weather.Icon, 1, 0)

	-- Current Pets
	local units = {frame.ActiveAlly, frame.ActiveEnemy}
	for index, unit in pairs(units) do
		unit.HealthBarBG:Hide()
		unit.HealthBarFrame:Hide()
		unit.healthBarWidth = 250
		unit.ActualHealthBar:SetTexture(DB.normTex)
		unit.healthBg = B.SetBD(unit.ActualHealthBar)
		unit.healthBg:ClearAllPoints()
		unit.healthBg:SetWidth(unit.healthBarWidth + 2*mult)
		unit.HealthText:ClearAllPoints()
		unit.HealthText:SetPoint("CENTER", unit.healthBg)

		unit.petIcon = unit:CreateTexture(nil, "ARTWORK")
		unit.petIcon:SetSize(25, 25)
		B.ReskinIcon(unit.petIcon, true)
		unit.PetType:SetAlpha(0)
		unit.PetType:ClearAllPoints()
		unit.PetType:SetAllPoints(unit.petIcon)
		unit.Name:ClearAllPoints()

		unit.Border:SetAlpha(0)
		unit.Border2:SetAlpha(0)
		unit.BorderFlash:SetAlpha(0)
		unit.Iconbg = B.SetBD(unit.Icon)

		unit.LevelUnderlay:SetAlpha(0)
		unit.Level:SetFontObject(SystemFont_Shadow_Huge1)
		unit.Level:ClearAllPoints()
		if unit.SpeedIcon then
			unit.SpeedUnderlay:SetAlpha(0)
			unit.SpeedIcon:SetSize(30, 30)
			unit.SpeedIcon:ClearAllPoints()
		end

		if index == 1 then
			unit.ActualHealthBar:SetPoint("BOTTOMLEFT", unit.Icon, "BOTTOMRIGHT", 0, 0)
			unit.healthBg:SetPoint("TOPLEFT", unit.ActualHealthBar, -mult, mult)
			unit.healthBg:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, -mult, -mult)
			if DB.isNewPatch then
				unit.ActualHealthBar:SetGradient("VERTICAL", CreateColor(.26, 1, .22, 1), CreateColor(.13, .5, .11, 1))
			else
				unit.ActualHealthBar:SetGradient("VERTICAL", .26, 1, .22, .13, .5, .11)
			end
			unit.petIcon:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, "TOPLEFT", 0, 4)
			unit.Name:SetPoint("LEFT", unit.petIcon, "RIGHT", 5, 0)
			unit.Level:SetPoint("BOTTOMLEFT", unit.Icon, 2, 2)
			if unit.SpeedIcon then
				unit.SpeedIcon:SetPoint("LEFT", unit.healthBg, "RIGHT", 5, 0)
				unit.SpeedIcon:SetTexCoord(0, .5, .5, 1)
			end
		else
			unit.ActualHealthBar:SetPoint("BOTTOMRIGHT", unit.Icon, "BOTTOMLEFT", 0, 0)
			unit.healthBg:SetPoint("TOPRIGHT", unit.ActualHealthBar, mult, mult)
			unit.healthBg:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, mult, -mult)
			if DB.isNewPatch then
				unit.ActualHealthBar:SetGradient("VERTICAL", CreateColor(1, .12, .24, 1), CreateColor(.5, .06, .12, 1))
			else
				unit.ActualHealthBar:SetGradient("VERTICAL", 1, .12, .24, .5, .06, .12)
			end
			unit.petIcon:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, "TOPRIGHT", 0, 4)
			unit.Name:SetPoint("RIGHT", unit.petIcon, "LEFT", -5, 0)
			unit.Level:SetPoint("BOTTOMRIGHT", unit.Icon, 2, 2)
			if unit.SpeedIcon then
				unit.SpeedIcon:SetPoint("RIGHT", unit.healthBg, "LEFT", -5, 0)
				unit.SpeedIcon:SetTexCoord(.5, 0, .5, 1)
			end
		end
	end

	-- Pending Pets
	local buddy = {frame.Ally2,	frame.Ally3, frame.Enemy2, frame.Enemy3}
	for index, unit in pairs(buddy) do
		unit:ClearAllPoints()
		unit.HealthBarBG:SetAlpha(0)
		unit.HealthDivider:SetAlpha(0)
		unit.BorderAlive:SetAlpha(0)
		unit.BorderDead:SetAlpha(0)
		unit.Iconbg = B.ReskinIcon(unit.Icon, true)

		unit.deadIcon = unit:CreateTexture(nil, "ARTWORK")
		unit.deadIcon:SetAllPoints(unit.Icon)
		unit.deadIcon:SetTexture("Interface\\PETBATTLES\\DeadPetIcon")
		unit.deadIcon:Hide()

		unit.healthBarWidth = 36
		unit.ActualHealthBar:ClearAllPoints()
		unit.ActualHealthBar:SetPoint("TOPLEFT", unit.Icon, "BOTTOMLEFT", 1, -4)
		unit.ActualHealthBar:SetTexture(DB.normTex)
		unit.healthBg = B.SetBD(unit.ActualHealthBar)
		unit.healthBg:ClearAllPoints()
		unit.healthBg:SetPoint("TOPLEFT", unit.ActualHealthBar, -mult, mult)
		unit.healthBg:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, -mult, -mult)
		unit.healthBg:SetWidth(unit.healthBarWidth + 2*mult)
		unit.healthBg:SetFrameLevel(unit:GetFrameLevel())

		if index < 3 then
			if DB.isNewPatch then
				unit.ActualHealthBar:SetGradient("VERTICAL", CreateColor(.26, 1, .22, 1), CreateColor(.13, .5, .11, 1))
			else
				unit.ActualHealthBar:SetGradient("VERTICAL", .26, 1, .22, .13, .5, .11)
			end
		else
			if DB.isNewPatch then
				unit.ActualHealthBar:SetGradient("VERTICAL", CreateColor(1, .12, .24, 1), CreateColor(.5, .06, .12, 1))
			else
				unit.ActualHealthBar:SetGradient("VERTICAL", 1, .12, .24, .5, .06, .12)
			end
		end
	end
	frame.Ally2:SetPoint("BOTTOMRIGHT", frame.ActiveAlly, "BOTTOMLEFT", -10, 20)
	frame.Ally3:SetPoint("BOTTOMRIGHT", frame.Ally2, "BOTTOMLEFT", -8, 0)
	frame.Enemy2:SetPoint("BOTTOMLEFT", frame.ActiveEnemy, "BOTTOMRIGHT", 10, 20)
	frame.Enemy3:SetPoint("BOTTOMLEFT", frame.Enemy2, "BOTTOMRIGHT", 8, 0)

	-- Update Status
	hooksecurefunc("PetBattleUnitFrame_UpdatePetType", function(self)
		if self.PetType and self.petIcon then
			local petType = C_PetBattles.GetPetType(self.petOwner, self.petIndex)
			self.petIcon:SetTexture("Interface\\ICONS\\Icon_PetFamily_"..PET_TYPE_SUFFIX[petType])
		end
	end)

	hooksecurefunc("PetBattleUnitFrame_UpdateDisplay", function(self)
		local petOwner = self.petOwner
		if (not petOwner) or self.petIndex > C_PetBattles.GetNumPets(petOwner) then return end

		if self.Icon then
			if petOwner == LE_BATTLE_PET_ALLY then
				self.Icon:SetTexCoord(.92, .08, .08, .92)
			else
				self.Icon:SetTexCoord(unpack(DB.TexCoord))
			end
		end
		if self.glow then self.glow:Hide() end
		if self.Iconbg then
			local quality = C_PetBattles.GetBreedQuality(self.petOwner, self.petIndex) - 1 or 1
			local color = DB.QualityColors[quality]
			self.Iconbg:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	hooksecurefunc("PetBattleUnitFrame_UpdateHealthInstant", function(self)
		if self.BorderDead and self.BorderDead:IsShown() and self.Iconbg then
			self.Iconbg:SetBackdropBorderColor(1, .12, .24)
		end
		if self.BorderDead and self.deadIcon then
			self.deadIcon:SetShown(self.BorderDead:IsShown())
		end
	end)

	hooksecurefunc("PetBattleAuraHolder_Update", function(self)
		if not self.petOwner or not self.petIndex then return end

		local nextFrame = 1
		for i = 1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, _, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i)
			if (isBuff and self.displayBuffs) or (not isBuff and self.displayDebuffs) then
				local frame = self.frames[nextFrame]
				frame.DebuffBorder:Hide()
				if not frame.styled then
					B.ReskinIcon(frame.Icon, true)
					frame.styled = true
				end

				nextFrame = nextFrame + 1
			end
		end
	end)

	-- Bottom Frame
	local bottomFrame = frame.BottomFrame
	for i = 1, 3 do
		select(i, bottomFrame:GetRegions()):Hide()
	end
	bottomFrame.Delimiter:Hide()
	bottomFrame.MicroButtonFrame:Hide()
	bottomFrame.TurnTimer.ArtFrame:SetTexture("")
	bottomFrame.TurnTimer.ArtFrame2:SetTexture("")
	bottomFrame.TurnTimer.TimerBG:SetTexture("")
	for i = 1, 3 do
		select(i, bottomFrame.FlowFrame:GetRegions()):SetAlpha(0)
	end

	-- Reskin Petbar
	local bar = CreateFrame("Frame", "NDuiPetBattleBar", UIParent, "SecureHandlerStateTemplate")
	bar:SetPoint("BOTTOM", UIParent, 0, 28)
	bar:SetSize(310, 40)
	local visibleState = "[petbattle] show; hide"
	RegisterStateDriver(bar, "visibility", visibleState)

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function(self)
		local f = self.BottomFrame
		local buttonList = {f.abilityButtons[1], f.abilityButtons[2], f.abilityButtons[3], f.SwitchPetButton, f.CatchButton, f.ForfeitButton}

		for i = 1, 6 do
			local bu = buttonList[i]
			bu:SetParent(bar)
			bu:SetSize(42, 42)
			bu:ClearAllPoints()
			if i == 1 then
				bu:SetPoint("LEFT", bar)
			else
				bu:SetPoint("LEFT", buttonList[i-1], "RIGHT", 3, 0)
			end

			bu:SetNormalTexture(0)
			bu:GetPushedTexture():SetTexture(DB.textures.pushed)
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			if not bu.bg then
				bu.bg = B.ReskinIcon(bu.Icon, true)
				bu.Icon:SetInside()
			end

			B.SetFontSize(bu.Cooldown, 26)
			bu.SelectedHighlight:ClearAllPoints()
			bu.SelectedHighlight:SetPoint("TOPLEFT", bu, -12, 12)
			bu.SelectedHighlight:SetPoint("BOTTOMRIGHT", bu, 12, -12)
		end
		buttonList[4]:GetCheckedTexture():SetColorTexture(r, g, b, .3)
	end)

	local skipButton = bottomFrame.TurnTimer.SkipButton
	skipButton:SetParent(bar)
	skipButton:SetSize(42, 42)
	B.StripTextures(skipButton)
	B.PixelIcon(skipButton, "Interface\\Icons\\Ability_Foundryraid_Dormant", true)
	B.CreateSD(skipButton)
	skipButton.HL:SetAllPoints(skipButton)
	skipButton:SetPushedTexture(DB.textures.pushed)

	local xpbar = PetBattleFrameXPBar
	B.StripTextures(xpbar)
	xpbar:SetParent(bar)
	xpbar:SetWidth(bar:GetWidth())
	xpbar:SetStatusBarTexture(DB.normTex)
	B.SetBD(xpbar)

	local turnTimer = bottomFrame.TurnTimer
	turnTimer:SetParent(bar)
	turnTimer:SetSize(xpbar:GetWidth()+4, xpbar:GetHeight()+10)
	turnTimer:ClearAllPoints()
	turnTimer:SetPoint("BOTTOM", bar, "TOP", 0, 7)
	turnTimer.bg = B.SetBD(turnTimer)
	turnTimer.Bar:ClearAllPoints()
	turnTimer.Bar:SetPoint("LEFT", 2, 0)
	turnTimer.TimerText:ClearAllPoints()
	turnTimer.TimerText:SetPoint("CENTER", turnTimer)

	hooksecurefunc("PetBattleFrame_UpdatePassButtonAndTimer", function()
		skipButton:ClearAllPoints()
		skipButton:SetPoint("LEFT", bottomFrame.ForfeitButton, "RIGHT", 3, 0)

		local pveBattle = C_PetBattles.IsPlayerNPC(LE_BATTLE_PET_ENEMY)
		turnTimer.bg:SetShown(not pveBattle)

		xpbar:ClearAllPoints()
		if pveBattle then
			xpbar:SetPoint("BOTTOM", bar, "TOP", 0, 7)
		else
			xpbar:SetPoint("BOTTOM", turnTimer, "TOP", 0, 4)
		end
	end)

	-- Pet Changing
	for i = 1, NUM_BATTLE_PETS_IN_BATTLE do
		local unit = bottomFrame.PetSelectionFrame["Pet"..i]
		local icon = unit.Icon

		unit.Iconbg = B.ReskinIcon(icon, true)
		unit.HealthBarBG:Hide()
		unit.Framing:Hide()
		unit.HealthDivider:Hide()
		unit.Name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, -3)

		unit.ActualHealthBar:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 5, 0)
		unit.ActualHealthBar:SetTexture(DB.normTex)
		local bg = B.SetBD(unit.ActualHealthBar)
		bg:SetPoint("TOPLEFT", unit.ActualHealthBar, -1, 1)
		bg:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, "BOTTOMLEFT", 129, -1)
	end

	-- Petbar Background
	local width, height = 180, 68
	local anchors = {
		["BOTTOMRIGHT"] = {0, .5},
		["BOTTOMLEFT"] = {.5, 0}
	}
	for anchor, v in pairs(anchors) do
		local frame = CreateFrame("Frame", nil, UIParent)
		frame:SetSize(width, height)
		frame:SetPoint(anchor, UIParent, "BOTTOM", 0, 3)
		frame:SetFrameLevel(0)
		local tex = B.SetGradient(frame, "H", 0, 0, 0, v[1], v[2], width, height)
		tex:SetPoint("CENTER")
		local line = B.SetGradient(frame, "H", r, g, b, v[1], v[2], width, C.mult)
		line:SetPoint("BOTTOM", frame, "TOP")

		RegisterStateDriver(frame, "visibility", visibleState)
	end
end)