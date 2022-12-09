local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local margin = C.Bars.margin

local function hasPetActionHighlightMark(index)
	return PET_ACTION_HIGHLIGHT_MARKS[index];
end

function Bar:UpdatePetBar()
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine;
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		petActionButton = self.actionButtons[i];
		petActionIcon = petActionButton.icon;
		petAutoCastableTexture = petActionButton.AutoCastable;
		petAutoCastShine = petActionButton.AutoCastShine;
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i);
		if ( not isToken ) then
			petActionIcon:SetTexture(texture);
			petActionButton.tooltipName = name;
		else
			petActionIcon:SetTexture(_G[texture]);
			petActionButton.tooltipName = _G[name];
		end
		petActionButton.isToken = isToken;
		if spellID then
			local spell = Spell:CreateFromSpellID(spellID);
			petActionButton.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
				petActionButton.tooltipSubtext = spell:GetSpellSubtext();
			end);
		end
		if ( isActive ) then
			if ( IsPetAttackAction(i) ) then
				petActionButton:StartFlash();
				-- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
				petActionButton:GetCheckedTexture():SetAlpha(0.5);
			else
				petActionButton:StopFlash();
				petActionButton:GetCheckedTexture():SetAlpha(1.0);
			end
			petActionButton:SetChecked(true);
		else
			petActionButton:StopFlash();
			petActionButton:SetChecked(false);
		end
		if ( autoCastAllowed ) then
			petAutoCastableTexture:Show();
		else
			petAutoCastableTexture:Hide();
		end
		if ( autoCastEnabled ) then
			AutoCastShine_AutoCastStart(petAutoCastShine);
		else
			AutoCastShine_AutoCastStop(petAutoCastShine);
		end
		if ( texture ) then
			if ( GetPetActionSlotUsable(i) ) then
				petActionIcon:SetVertexColor(1, 1, 1);
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4);
			end
			petActionIcon:Show();
		else
			petActionIcon:Hide();
		end

		SharedActionButton_RefreshSpellHighlight(petActionButton, hasPetActionHighlightMark(i));
	end
	self:UpdateCooldowns();
	self.rangeTimer = -1
end

function Bar.PetBarOnEvent(event)
	if event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar:UpdateCooldowns()
	else
		Bar.UpdatePetBar(PetActionBar)
	end
end

function Bar:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Pet Actionbar"], "PetBar", {"BOTTOM", _G.NDui_ActionBar2, "TOP", 0, margin})
	Bar.movers[10] = frame.mover

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Fix pet bar updating
	Bar:PetBarOnEvent()
	B:RegisterEvent("UNIT_PET", Bar.PetBarOnEvent)
	B:RegisterEvent("UNIT_FLAGS", Bar.PetBarOnEvent)
	B:RegisterEvent("PET_UI_UPDATE", Bar.PetBarOnEvent)
	B:RegisterEvent("PET_BAR_UPDATE", Bar.PetBarOnEvent)
	B:RegisterEvent("PLAYER_CONTROL_LOST", Bar.PetBarOnEvent)
	B:RegisterEvent("PLAYER_CONTROL_GAINED", Bar.PetBarOnEvent)
	B:RegisterEvent("PLAYER_TARGET_CHANGED", Bar.PetBarOnEvent)
	B:RegisterEvent("PET_BAR_UPDATE_USABLE", Bar.PetBarOnEvent)
	B:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", Bar.PetBarOnEvent)
	B:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", Bar.PetBarOnEvent)
	B:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", Bar.PetBarOnEvent)
	B:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", Bar.PetBarOnEvent)
end