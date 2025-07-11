--[[
Copyright (c) 2010-2022, Hendrik "nevcairiel" Leppkes <h.leppkes@gmail.com>

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of the developer nor the names of its contributors
      may be used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]
local MAJOR_VERSION = "LibActionButton-1.0-NDui"
local MINOR_VERSION = 124

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

-- Lua functions
local type, error, tostring, tonumber, assert, select = type, error, tostring, tonumber, assert, select
local setmetatable, wipe, unpack, pairs, next = setmetatable, wipe, unpack, pairs, next
local str_match, format, tinsert, tremove = string.match, format, tinsert, tremove

local WoWRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local WoWClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local WoWBCC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
local WoWWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local WoWCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)

-- Enable custom flyouts for WoW Retail
local UseCustomFlyout = WoWRetail or (FlyoutButtonMixin and not ActionButton_UpdateFlyout)

local KeyBound = LibStub("LibKeyBound-1.0", true)
local CBH = LibStub("CallbackHandler-1.0")
local LCG = LibStub("LibCustomGlow-1.0-NDui", true) -- NDui: use LCG mod
local Masque = LibStub("Masque", true)

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:UnregisterAllEvents()

lib.buttonRegistry = lib.buttonRegistry or {}
lib.activeButtons = lib.activeButtons or {}
lib.actionButtons = lib.actionButtons or {}
lib.nonActionButtons = lib.nonActionButtons or {}

lib.ChargeCooldowns = lib.ChargeCooldowns or {}
lib.NumChargeCooldowns = lib.NumChargeCooldowns or 0

lib.FlyoutInfo = lib.FlyoutInfo or {}
lib.FlyoutButtons = lib.FlyoutButtons or {}

lib.ACTION_HIGHLIGHT_MARKS = lib.ACTION_HIGHLIGHT_MARKS or setmetatable({}, { __index = ACTION_HIGHLIGHT_MARKS })

lib.callbacks = lib.callbacks or CBH:New(lib)

local Generic = CreateFrame("CheckButton")
local Generic_MT = {__index = Generic}

local Action = setmetatable({}, {__index = Generic})
local Action_MT = {__index = Action}

--local PetAction = setmetatable({}, {__index = Generic})
--local PetAction_MT = {__index = PetAction}

local Spell = setmetatable({}, {__index = Generic})
local Spell_MT = {__index = Spell}

local Item = setmetatable({}, {__index = Generic})
local Item_MT = {__index = Item}

local Macro = setmetatable({}, {__index = Generic})
local Macro_MT = {__index = Macro}

local Custom = setmetatable({}, {__index = Generic})
local Custom_MT = {__index = Custom}

local type_meta_map = {
	empty  = Generic_MT,
	action = Action_MT,
	--pet    = PetAction_MT,
	spell  = Spell_MT,
	item   = Item_MT,
	macro  = Macro_MT,
	custom = Custom_MT
}

local ButtonRegistry, ActiveButtons, ActionButtons, NonActionButtons = lib.buttonRegistry, lib.activeButtons, lib.actionButtons, lib.nonActionButtons

local Update, UpdateButtonState, UpdateUsable, UpdateCount, UpdateCooldown, UpdateCooldownNumberHidden, UpdateTooltip, UpdateNewAction, UpdateSpellHighlight, ClearNewActionHighlight
local StartFlash, StopFlash, UpdateFlash, UpdateHotkeys, UpdateRangeTimer, UpdateOverlayGlow
local UpdateFlyout, ShowGrid, HideGrid, UpdateGrid, SetupSecureSnippets, WrapOnClick
local ShowOverlayGlow, HideOverlayGlow
local EndChargeCooldown

local GetFlyoutHandler

local InitializeEventHandler, OnEvent, ForAllButtons, OnUpdate

local function GameTooltip_GetOwnerForbidden()
	if GameTooltip:IsForbidden() then
		return nil
	end
	return GameTooltip:GetOwner()
end

local DefaultConfig = {
	outOfRangeColoring = "button",
	tooltip = "enabled",
	showGrid = false,
	colors = {
		range = { 0.8, 0.1, 0.1 },
		mana = { 0.5, 0.5, 1.0 }
	},
	hideElements = {
		macro = false,
		hotkey = false,
		equipped = false,
		border = false,
		borderIfEmpty = false,
	},
	keyBoundTarget = false,
	keyBoundClickButton = "LeftButton",
	clickOnDown = false,
	cooldownCount = nil, -- nil: use cvar, true/false: enable/disable
	flyoutDirection = "UP",
	text = {
		hotkey = {
			font = {
				font = false, -- "Fonts\\ARIALN.TTF",
				size = WoWRetail and 14 or 13,
				flags = "OUTLINE",
			},
			color = { 0.75, 0.75, 0.75 },
			position = {
				anchor = "TOPRIGHT",
				relAnchor = "TOPRIGHT",
				offsetX = -2,
				offsetY = -4,
			},
			justifyH = "RIGHT",
		},
		count = {
			font = {
				font = false, -- "Fonts\\ARIALN.TTF",
				size = 16,
				flags = "OUTLINE",
			},
			color = { 1, 1, 1 },
			position = {
				anchor = "BOTTOMRIGHT",
				relAnchor = "BOTTOMRIGHT",
				offsetX = -2,
				offsetY = 4,
			},
			justifyH = "RIGHT",
		},
		macro = {
			font = {
				font = false, -- "Fonts\\FRIZQT__.TTF",
				size = 10,
				flags = "OUTLINE",
			},
			color = { 1, 1, 1 },
			position = {
				anchor = "BOTTOM",
				relAnchor = "BOTTOM",
				offsetX = 0,
				offsetY = 2,
			},
			justifyH = "CENTER",
		},
	},
}

--- Create a new action button.
-- @param id Internal id of the button (not used by LibActionButton-1.0, only for tracking inside the calling addon)
-- @param name Name of the button frame to be created (not used by LibActionButton-1.0 aside from naming the frame)
-- @param header Header that drives these action buttons (if any)
function lib:CreateButton(id, name, header, config)
	if type(name) ~= "string" then
		error("Usage: CreateButton(id, name. header): Buttons must have a valid name!", 2)
	end
	if not header then
		error("Usage: CreateButton(id, name, header): Buttons without a secure header are not yet supported!", 2)
	end

	if not KeyBound then
		KeyBound = LibStub("LibKeyBound-1.0", true)
	end

	local button = setmetatable(CreateFrame("CheckButton", name, header, "ActionButtonTemplate, SecureActionButtonTemplate"), Generic_MT)
	button:RegisterForDrag("LeftButton", "RightButton")
	if WoWRetail then
		button:RegisterForClicks("AnyDown", "AnyUp")
	else
		button:RegisterForClicks("AnyUp")
	end

	-- Frame Scripts
	button:SetScript("OnEnter", Generic.OnEnter)
	button:SetScript("OnLeave", Generic.OnLeave)
	button:SetScript("PreClick", Generic.PreClick)
	button:SetScript("PostClick", Generic.PostClick)
	button:SetScript("OnEvent", Generic.OnButtonEvent)

	button.id = id
	button.header = header
	-- Mapping of state -> action
	button.state_types = {}
	button.state_actions = {}

	-- Store the LAB Version that created this button for debugging
	button.__LAB_Version = MINOR_VERSION

	-- just in case we're not run by a header, default to state 0
	button:SetAttribute("state", 0)

	SetupSecureSnippets(button)
	WrapOnClick(button)

	-- if there is no button yet, initialize events later
	local InitializeEvents = not next(ButtonRegistry)

	-- Store the button in the registry, needed for event and OnUpdate handling
	ButtonRegistry[button] = true

	-- setup button configuration
	button:UpdateConfig(config)

	-- run an initial update
	button:UpdateAction()
	UpdateHotkeys(button)

	button:SetAttribute("LABUseCustomFlyout", UseCustomFlyout)

	-- nil out inherited functions from the flyout mixin, we override these in a metatable
	if UseCustomFlyout then
		button.GetPopupDirection = nil
		button.IsPopupOpen = nil
	end

	-- initialize events
	if InitializeEvents then
		InitializeEventHandler()
	end

	-- somewhat of a hack for the Flyout buttons to not error.
	button.action = 0

	lib.callbacks:Fire("OnButtonCreated", button)

	return button
end

function lib:GetSpellFlyoutFrame()
	return lib.flyoutHandler
end

function SetupSecureSnippets(button)
	button:SetAttribute("_custom", Custom.RunCustom)
	-- secure UpdateState(self, state)
	-- update the type and action of the button based on the state
	button:SetAttribute("UpdateState", [[
		local state = ...
		self:SetAttribute("state", state)
		local type, action = (self:GetAttribute(format("labtype-%s", state)) or "empty"), self:GetAttribute(format("labaction-%s", state))

		self:SetAttribute("type", type)
		if type ~= "empty" and type ~= "custom" then
			local action_field = (type == "pet") and "action" or type
			self:SetAttribute(action_field, action)
			self:SetAttribute("action_field", action_field)
		end
		if IsPressHoldReleaseSpell then
			local pressAndHold = false
			if type == "action" then
				self:SetAttribute("typerelease", "actionrelease")
				local actionType, id, subType = GetActionInfo(action)
				if actionType == "spell" then
					pressAndHold = IsPressHoldReleaseSpell(id)
				elseif actionType == "macro" then
					if subType == "spell" then
						pressAndHold = IsPressHoldReleaseSpell(id)
					end
					-- GetMacroSpell is not in the restricted environment
					--[=[
						local spellID = GetMacroSpell(id)
						if spellID then
							pressAndHold = IsPressHoldReleaseSpell(spellID)
						end
					]=]
				end
			elseif type == "spell" then
				self:SetAttribute("typerelease", nil)
				-- XXX: while we can query this attribute, there is no corresponding action to release a spell button, only "actionrelease" exists
				pressAndHold = IsPressHoldReleaseSpell(action)
			else
				self:SetAttribute("typerelease", nil)
			end

			self:SetAttribute("pressAndHoldAction", pressAndHold)
		end
		local onStateChanged = self:GetAttribute("OnStateChanged")
		if onStateChanged then
			self:Run(onStateChanged, state, type, action)
		end
	]])

	-- this function is invoked by the header when the state changes
	button:SetAttribute("_childupdate-state", [[
		self:RunAttribute("UpdateState", message)
		self:CallMethod("UpdateAction")
	]])

	-- secure PickupButton(self, kind, value, ...)
	-- utility function to place a object on the cursor
	button:SetAttribute("PickupButton", [[
		local kind, value = ...
		if kind == "empty" then
			return "clear"
		elseif kind == "action" or kind == "pet" then
			local actionType = (kind == "pet") and "petaction" or kind
			return actionType, value
		elseif kind == "spell" or kind == "item" or kind == "macro" then
			return "clear", kind, value
		else
			print("LibActionButton-1.0: Unknown type: " .. tostring(kind))
			return false
		end
	]])

	button:SetAttribute("OnDragStart", [[
		if (self:GetAttribute("buttonlock") and not IsModifiedClick("PICKUPACTION")) or self:GetAttribute("LABdisableDragNDrop") then return false end
		local state = self:GetAttribute("state")
		local type = self:GetAttribute("type")
		-- if the button is empty, we can't drag anything off it
		if type == "empty" or type == "custom" then
			return false
		end
		-- Get the value for the action attribute
		local action_field = self:GetAttribute("action_field")
		local action = self:GetAttribute(action_field)

		-- non-action fields need to change their type to empty
		if type ~= "action" and type ~= "pet" then
			self:SetAttribute(format("labtype-%s", state), "empty")
			self:SetAttribute(format("labaction-%s", state), nil)
			-- update internal state
			self:RunAttribute("UpdateState", state)
			-- send a notification to the insecure code
			self:CallMethod("ButtonContentsChanged", state, "empty", nil)
		end
		-- return the button contents for pickup
		return self:RunAttribute("PickupButton", type, action)
	]])

	button:SetAttribute("OnReceiveDrag", [[
		if self:GetAttribute("LABdisableDragNDrop") then return false end
		local kind, value, subtype, extra = ...
		if not kind or not value then return false end
		local state = self:GetAttribute("state")
		local buttonType, buttonAction = self:GetAttribute("type"), nil
		if buttonType == "custom" then return false end
		-- action buttons can do their magic themself
		-- for all other buttons, we'll need to update the content now
		if buttonType ~= "action" and buttonType ~= "pet" then
			-- with "spell" types, the 4th value contains the actual spell id
			if kind == "spell" then
				if extra then
					value = extra
				else
					print("no spell id?", ...)
				end
			elseif kind == "item" and value then
				value = format("item:%d", value)
			end

			-- Get the action that was on the button before
			if buttonType ~= "empty" then
				buttonAction = self:GetAttribute(self:GetAttribute("action_field"))
			end

			-- TODO: validate what kind of action is being fed in here
			-- We can only use a handful of the possible things on the cursor
			-- return false for all those we can't put on buttons

			self:SetAttribute(format("labtype-%s", state), kind)
			self:SetAttribute(format("labaction-%s", state), value)
			-- update internal state
			self:RunAttribute("UpdateState", state)
			-- send a notification to the insecure code
			self:CallMethod("ButtonContentsChanged", state, kind, value)
		else
			-- get the action for (pet-)action buttons
			buttonAction = self:GetAttribute("action")
		end
		return self:RunAttribute("PickupButton", buttonType, buttonAction)
	]])

	button:SetScript("OnDragStart", nil)
	-- Wrapped OnDragStart(self, button, kind, value, ...)
	button.header:WrapScript(button, "OnDragStart", [[
		return self:RunAttribute("OnDragStart")
	]])
	-- Wrap twice, because the post-script is not run when the pre-script causes a pickup (doh)
	-- we also need some phony message, or it won't work =/
	button.header:WrapScript(button, "OnDragStart", [[
		return "message", "update"
	]], [[
		self:RunAttribute("UpdateState", self:GetAttribute("state"))
	]])

	button:SetScript("OnReceiveDrag", nil)
	-- Wrapped OnReceiveDrag(self, button, kind, value, ...)
	button.header:WrapScript(button, "OnReceiveDrag", [[
		return self:RunAttribute("OnReceiveDrag", kind, value, ...)
	]])
	-- Wrap twice, because the post-script is not run when the pre-script causes a pickup (doh)
	-- we also need some phony message, or it won't work =/
	button.header:WrapScript(button, "OnReceiveDrag", [[
		return "message", "update"
	]], [[
		self:RunAttribute("UpdateState", self:GetAttribute("state"))
	]])

	if UseCustomFlyout then
		button.header:SetFrameRef("flyoutHandler", GetFlyoutHandler())
	end
end

function WrapOnClick(button, unwrapheader)
	-- unwrap OnClick until we got our old script out
	if unwrapheader and unwrapheader.UnwrapScript then
		local wrapheader
		repeat
			wrapheader = unwrapheader:UnwrapScript(button, "OnClick")
		until (not wrapheader or wrapheader == unwrapheader)
	end

	-- Wrap OnClick, to catch changes to actions that are applied with a click on the button.
	button.header:WrapScript(button, "OnClick", [[
		if self:GetAttribute("type") == "action" then
			local type, action = GetActionInfo(self:GetAttribute("action"))

			if type == "flyout" and self:GetAttribute("LABUseCustomFlyout") then
				local flyoutHandler = owner:GetFrameRef("flyoutHandler")
				if not down and flyoutHandler then
					flyoutHandler:SetAttribute("flyoutParentHandle", self)
					flyoutHandler:RunAttribute("HandleFlyout", action)
				end

				self:CallMethod("UpdateFlyout")
				return false
			end

			-- hide the flyout
			local flyoutHandler = owner:GetFrameRef("flyoutHandler")
			if flyoutHandler then
				flyoutHandler:Hide()
			end

			-- if this is a pickup click, disable on-down casting
			-- it should get re-enabled in the post handler, or the OnDragStart handler, whichever occurs
			if button ~= "Keybind" and ((self:GetAttribute("unlockedpreventdrag") and not self:GetAttribute("buttonlock")) or IsModifiedClick("PICKUPACTION")) and not self:GetAttribute("LABdisableDragNDrop") then
				local useOnkeyDown = self:GetAttribute("useOnKeyDown")
				if useOnkeyDown ~= false then
					self:SetAttribute("LABToggledOnDown", true)
					self:SetAttribute("LABToggledOnDownBackup", useOnkeyDown)
					self:SetAttribute("useOnKeyDown", false)
				end
			end
			return (button == "Keybind") and "LeftButton" or nil, format("%s|%s", tostring(type), tostring(action))
		end

		-- hide the flyout, the extra down/ownership check is needed to not hide the button we're currently pressing too early
		local flyoutHandler = owner:GetFrameRef("flyoutHandler")
		if flyoutHandler and (not down or self:GetParent() ~= flyoutHandler) then
			flyoutHandler:Hide()
		end

		if button == "Keybind" then
			return "LeftButton"
		end
	]], [[
		local type, action = GetActionInfo(self:GetAttribute("action"))
		if message ~= format("%s|%s", tostring(type), tostring(action)) then
			self:RunAttribute("UpdateState", self:GetAttribute("state"))
		end

		-- re-enable ondown casting if needed
		if self:GetAttribute("LABToggledOnDown") then
			self:SetAttribute("useOnKeyDown", self:GetAttribute("LABToggledOnDownBackup"))
			self:SetAttribute("LABToggledOnDown", nil)
			self:SetAttribute("LABToggledOnDownBackup", nil)
		end
	]])
end

function Generic:OnButtonEvent(event, ...)
	if event == "GLOBAL_MOUSE_UP" then
		self:SetButtonState("NORMAL")
		self:UnregisterEvent(event)

		UpdateFlyout(self)
	end
end

-----------------------------------------------------------
--- utility

function lib:GetAllButtons()
	local buttons = {}
	for button in next, ButtonRegistry do
		buttons[button] = true
	end
	return buttons
end

function Generic:ClearSetPoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end

function Generic:NewHeader(header)
	local oldheader = self.header
	self.header = header
	self:SetParent(header)
	SetupSecureSnippets(self)
	WrapOnClick(self, oldheader)
end


-----------------------------------------------------------
--- state management

function Generic:ClearStates()
	for state in pairs(self.state_types) do
		self:SetAttribute(format("labtype-%s", state), nil)
		self:SetAttribute(format("labaction-%s", state), nil)
	end
	wipe(self.state_types)
	wipe(self.state_actions)
end

function Generic:SetStateFromHandlerInsecure(state, kind, action)
	state = tostring(state)
	-- we allow a nil kind for setting a empty state
	if not kind then kind = "empty" end
	if not type_meta_map[kind] then
		error("SetStateAction: unknown action type: " .. tostring(kind), 2)
	end
	if kind ~= "empty" and action == nil then
		error("SetStateAction: an action is required for non-empty states", 2)
	end
	if kind ~= "custom" and action ~= nil and type(action) ~= "number" and type(action) ~= "string" or (kind == "custom" and type(action) ~= "table") then
		error("SetStateAction: invalid action data type, only strings and numbers allowed", 2)
	end

	if kind == "item" then
		if tonumber(action) then
			action = format("item:%s", action)
		else
			local itemString = str_match(action, "^|c[^|]+|H(item[%d:]+)|h%[")
			if itemString then
				action = itemString
			end
		end
	end

	self.state_types[state] = kind
	self.state_actions[state] = action
end

function Generic:SetState(state, kind, action)
	if not state then state = self:GetAttribute("state") end
	state = tostring(state)

	self:SetStateFromHandlerInsecure(state, kind, action)
	self:UpdateState(state)
end

function Generic:UpdateState(state)
	if not state then state = self:GetAttribute("state") end
	state = tostring(state)
	self:SetAttribute(format("labtype-%s", state), self.state_types[state])
	self:SetAttribute(format("labaction-%s", state), self.state_actions[state])
	if state ~= tostring(self:GetAttribute("state")) then return end
	if self.header then
		self.header:SetFrameRef("updateButton", self)
		self.header:Execute([[
			local frame = self:GetFrameRef("updateButton")
			control:RunFor(frame, frame:GetAttribute("UpdateState"), frame:GetAttribute("state"))
		]])
	else
	-- TODO
	end
	self:UpdateAction()
end

function Generic:GetAction(state)
	if not state then state = self:GetAttribute("state") end
	state = tostring(state)
	return self.state_types[state] or "empty", self.state_actions[state]
end

function Generic:UpdateAllStates()
	for state in pairs(self.state_types) do
		self:UpdateState(state)
	end
end

function Generic:ButtonContentsChanged(state, kind, value)
	state = tostring(state)
	self.state_types[state] = kind or "empty"
	self.state_actions[state] = value
	lib.callbacks:Fire("OnButtonContentsChanged", self, state, self.state_types[state], self.state_actions[state])
	self:UpdateAction(self)
end

function Generic:DisableDragNDrop(flag)
	if InCombatLockdown() then
		error("LibActionButton-1.0: You can only toggle DragNDrop out of combat!", 2)
	end
	if flag then
		self:SetAttribute("LABdisableDragNDrop", true)
	else
		self:SetAttribute("LABdisableDragNDrop", nil)
	end
end

function Generic:AddToButtonFacade(group)
	if type(group) ~= "table" or type(group.AddButton) ~= "function" then
		error("LibActionButton-1.0:AddToButtonFacade: You need to supply a proper group to use!", 2)
	end
	group:AddButton(self)
	self.LBFSkinned = true
end

function Generic:AddToMasque(group)
	if type(group) ~= "table" or type(group.AddButton) ~= "function" then
		error("LibActionButton-1.0:AddToMasque: You need to supply a proper group to use!", 2)
	end
	group:AddButton(self, nil, "Action")
	self.MasqueSkinned = true
end

function Generic:UpdateAlpha()
	UpdateCooldown(self)
end

-----------------------------------------------------------
--- flyouts

local DiscoverFlyoutSpells, UpdateFlyoutSpells, UpdateFlyoutHandlerScripts, FlyoutUpdateQueued

if UseCustomFlyout then
	-- params: self, flyoutID
	local FlyoutHandleFunc = [[
		local SPELLFLYOUT_DEFAULT_SPACING = 4
		local SPELLFLYOUT_INITIAL_SPACING = 7
		local SPELLFLYOUT_FINAL_SPACING = 9

		local parent = self:GetAttribute("flyoutParentHandle")
		if not parent then return end

		if self:IsShown() and self:GetParent() == parent then
			self:Hide()
			return
		end

		local flyoutID = ...
		local info = LAB_FlyoutInfo[flyoutID]
		if not info then print("LAB: Flyout missing with ID " .. flyoutID) return end

		local oldParent = self:GetParent()
		self:SetParent(parent)

		local direction = parent:GetAttribute("flyoutDirection") or "UP"

		local usedSlots = 0
		local prevButton
		for slotID, slotInfo in ipairs(info.slots) do
			if slotInfo.isKnown then
				usedSlots = usedSlots + 1
				local slotButton = self:GetFrameRef("flyoutButton" .. usedSlots)

				-- set secure action attributes
				slotButton:SetAttribute("type", "spell")
				slotButton:SetAttribute("spell", slotInfo.spellID)

				-- set LAB attributes
				slotButton:SetAttribute("labtype-0", "spell")
				slotButton:SetAttribute("labaction-0", slotInfo.spellID)

				-- run LAB updates
				slotButton:CallMethod("SetStateFromHandlerInsecure", 0, "spell", slotInfo.spellID)
				slotButton:CallMethod("UpdateAction")

				slotButton:ClearAllPoints()

				if direction == "UP" then
					if prevButton then
						slotButton:SetPoint("BOTTOM", prevButton, "TOP", 0, SPELLFLYOUT_DEFAULT_SPACING)
					else
						slotButton:SetPoint("BOTTOM", self, "BOTTOM", 0, SPELLFLYOUT_INITIAL_SPACING)
					end
				elseif direction == "DOWN" then
					if prevButton then
						slotButton:SetPoint("TOP", prevButton, "BOTTOM", 0, -SPELLFLYOUT_DEFAULT_SPACING)
					else
						slotButton:SetPoint("TOP", self, "TOP", 0, -SPELLFLYOUT_INITIAL_SPACING)
					end
				elseif direction == "LEFT" then
					if prevButton then
						slotButton:SetPoint("RIGHT", prevButton, "LEFT", -SPELLFLYOUT_DEFAULT_SPACING, 0)
					else
						slotButton:SetPoint("RIGHT", self, "RIGHT", -SPELLFLYOUT_INITIAL_SPACING, 0)
					end
				elseif direction == "RIGHT" then
					if prevButton then
						slotButton:SetPoint("LEFT", prevButton, "RIGHT", SPELLFLYOUT_DEFAULT_SPACING, 0)
					else
						slotButton:SetPoint("LEFT", self, "LEFT", SPELLFLYOUT_INITIAL_SPACING, 0)
					end
				end

				slotButton:Show()
				prevButton = slotButton
			end
		end

		-- hide excess buttons
		for i = usedSlots + 1, self:GetAttribute("numFlyoutButtons") do
			local slotButton = self:GetFrameRef("flyoutButton" .. i)
			if slotButton then
				slotButton:Hide()

				-- unset its action, so it stops updating
				slotButton:SetAttribute("labtype-0", "empty")
				slotButton:SetAttribute("labaction-0", nil)

				slotButton:CallMethod("SetStateFromHandlerInsecure", 0, "empty")
				slotButton:CallMethod("UpdateAction")
			end
		end

		if usedSlots == 0 then
			self:Hide()
			return
		end

		-- calculate extent for the long dimension
		-- 3 pixel extra initial padding, button size + padding, and everything at 0.8 scale
		local extent = (3 + (45 + 4) * usedSlots) * 0.8

		self:ClearAllPoints()

		if direction == "UP" then
			self:SetPoint("BOTTOM", parent, "TOP")
			self:SetWidth(45)
			self:SetHeight(extent)
		elseif direction == "DOWN" then
			self:SetPoint("TOP", parent, "BOTTOM")
			self:SetWidth(45)
			self:SetHeight(extent)
		elseif direction == "LEFT" then
			self:SetPoint("RIGHT", parent, "LEFT")
			self:SetWidth(extent)
			self:SetHeight(45)
		elseif direction == "RIGHT" then
			self:SetPoint("LEFT", parent, "RIGHT")
			self:SetWidth(extent)
			self:SetHeight(45)
		end

		self:SetFrameStrata("DIALOG")
		self:Show()

		self:CallMethod("ShowFlyoutInsecure", direction)

		if oldParent and oldParent:GetAttribute("LABUseCustomFlyout") then
			oldParent:CallMethod("UpdateFlyout")
		end
	]]

	local SPELLFLYOUT_INITIAL_SPACING = 7
	local function ShowFlyoutInsecure(self, direction)
		self.Background.End:ClearAllPoints()
		self.Background.Start:ClearAllPoints()
		if direction == "UP" then
			self.Background.End:SetPoint("TOP", 0, SPELLFLYOUT_INITIAL_SPACING)
			SetClampedTextureRotation(self.Background.End, 0)
			SetClampedTextureRotation(self.Background.VerticalMiddle, 0)
			self.Background.Start:SetPoint("TOP", self.Background.VerticalMiddle, "BOTTOM")
			SetClampedTextureRotation(self.Background.Start, 0)
			self.Background.HorizontalMiddle:Hide()
			self.Background.VerticalMiddle:Show()
			self.Background.VerticalMiddle:ClearAllPoints()
			self.Background.VerticalMiddle:SetPoint("TOP", self.Background.End, "BOTTOM")
			self.Background.VerticalMiddle:SetPoint("BOTTOM", 0, 0)
		elseif direction == "DOWN" then
			self.Background.End:SetPoint("BOTTOM", 0, -SPELLFLYOUT_INITIAL_SPACING)
			SetClampedTextureRotation(self.Background.End, 180)
			SetClampedTextureRotation(self.Background.VerticalMiddle, 180)
			self.Background.Start:SetPoint("BOTTOM", self.Background.VerticalMiddle, "TOP")
			SetClampedTextureRotation(self.Background.Start, 180)
			self.Background.HorizontalMiddle:Hide()
			self.Background.VerticalMiddle:Show()
			self.Background.VerticalMiddle:ClearAllPoints()
			self.Background.VerticalMiddle:SetPoint("BOTTOM", self.Background.End, "TOP")
			self.Background.VerticalMiddle:SetPoint("TOP", 0, -0)
		elseif direction == "LEFT" then
			self.Background.End:SetPoint("LEFT", -SPELLFLYOUT_INITIAL_SPACING, 0)
			SetClampedTextureRotation(self.Background.End, 270)
			SetClampedTextureRotation(self.Background.HorizontalMiddle, 180)
			self.Background.Start:SetPoint("LEFT", self.Background.HorizontalMiddle, "RIGHT")
			SetClampedTextureRotation(self.Background.Start, 270)
			self.Background.VerticalMiddle:Hide()
			self.Background.HorizontalMiddle:Show()
			self.Background.HorizontalMiddle:ClearAllPoints()
			self.Background.HorizontalMiddle:SetPoint("LEFT", self.Background.End, "RIGHT")
			self.Background.HorizontalMiddle:SetPoint("RIGHT", -0, 0)
		elseif direction == "RIGHT" then
			self.Background.End:SetPoint("RIGHT", SPELLFLYOUT_INITIAL_SPACING, 0)
			SetClampedTextureRotation(self.Background.End, 90)
			SetClampedTextureRotation(self.Background.HorizontalMiddle, 0)
			self.Background.Start:SetPoint("RIGHT", self.Background.HorizontalMiddle, "LEFT")
			SetClampedTextureRotation(self.Background.Start, 90)
			self.Background.VerticalMiddle:Hide()
			self.Background.HorizontalMiddle:Show()
			self.Background.HorizontalMiddle:ClearAllPoints()
			self.Background.HorizontalMiddle:SetPoint("RIGHT", self.Background.End, "LEFT")
			self.Background.HorizontalMiddle:SetPoint("LEFT", 0, 0)
		end

		if direction == "UP" or direction == "DOWN" then
			self.Background.Start:SetWidth(47)
			self.Background.HorizontalMiddle:SetWidth(47)
			self.Background.VerticalMiddle:SetWidth(47)
			self.Background.End:SetWidth(47)
		else
			self.Background.Start:SetHeight(47)
			self.Background.HorizontalMiddle:SetHeight(47)
			self.Background.VerticalMiddle:SetHeight(47)
			self.Background.End:SetHeight(47)
		end
	end

	function UpdateFlyoutHandlerScripts()
		lib.flyoutHandler:SetAttribute("HandleFlyout", FlyoutHandleFunc)
		lib.flyoutHandler.ShowFlyoutInsecure = ShowFlyoutInsecure
	end

	local function FlyoutOnShowHide(self)
		if self:GetParent() and self:GetParent().UpdateFlyout then
			self:GetParent():UpdateFlyout()
		end
	end

	function GetFlyoutHandler()
		if not lib.flyoutHandler then
			lib.flyoutHandler = CreateFrame("Frame", "LABFlyoutHandlerFrame", UIParent, "SecureHandlerBaseTemplate")
			lib.flyoutHandler.Background = CreateFrame("Frame", nil, lib.flyoutHandler)
			lib.flyoutHandler.Background:SetAllPoints()
			lib.flyoutHandler.Background.End = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.End:SetAtlas("UI-HUD-ActionBar-IconFrame-FlyoutButton", true)
			lib.flyoutHandler.Background.HorizontalMiddle = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.HorizontalMiddle:SetAtlas("_UI-HUD-ActionBar-IconFrame-FlyoutMidLeft", true)
			lib.flyoutHandler.Background.HorizontalMiddle:SetHorizTile(true)
			lib.flyoutHandler.Background.VerticalMiddle = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.VerticalMiddle:SetAtlas("!UI-HUD-ActionBar-IconFrame-FlyoutMid", true)
			lib.flyoutHandler.Background.VerticalMiddle:SetVertTile(true)
			lib.flyoutHandler.Background.Start = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.Start:SetAtlas("UI-HUD-ActionBar-IconFrame-FlyoutBottom", true)

			lib.flyoutHandler.Background.Start:SetVertexColor(0.7, 0.7, 0.7)
			lib.flyoutHandler.Background.HorizontalMiddle:SetVertexColor(0.7, 0.7, 0.7)
			lib.flyoutHandler.Background.VerticalMiddle:SetVertexColor(0.7, 0.7, 0.7)
			lib.flyoutHandler.Background.End:SetVertexColor(0.7, 0.7, 0.7)

			lib.flyoutHandler:Hide()

			lib.flyoutHandler:SetScript("OnShow", FlyoutOnShowHide)
			lib.flyoutHandler:SetScript("OnHide", FlyoutOnShowHide)

			lib.flyoutHandler:SetAttribute("numFlyoutButtons", 0)
			UpdateFlyoutHandlerScripts()
		end

		return lib.flyoutHandler
	end

	-- sync flyout information to the restricted environment
	local InSync = false
	local function SyncFlyoutInfoToHandler()
		if InCombatLockdown() or InSync then return end
		InSync = true

		local maxNumSlots = 0

		local data = "LAB_FlyoutInfo = newtable();\n"
		for flyoutID, info in pairs(lib.FlyoutInfo) do
			if info.isKnown then
				local numSlots = 0
				data = data .. ("LAB_FlyoutInfo[%d] = newtable();LAB_FlyoutInfo[%d].slots = newtable();\n"):format(flyoutID, flyoutID)
				for slotID, slotInfo in ipairs(info.slots) do
					data = data .. ("LAB_FlyoutInfo[%d].slots[%d] = newtable();LAB_FlyoutInfo[%d].slots[%d].spellID = %d;LAB_FlyoutInfo[%d].slots[%d].isKnown = %s;\n"):format(flyoutID, slotID, flyoutID, slotID, slotInfo.spellID, flyoutID, slotID, slotInfo.isKnown and "true" or "nil")
					numSlots = numSlots + 1
				end

				if numSlots > maxNumSlots then
					maxNumSlots = numSlots
				end
			end
		end

		-- load generated data into the restricted environment
		GetFlyoutHandler():Execute(data)

		if maxNumSlots > #lib.FlyoutButtons then
			for i = #lib.FlyoutButtons + 1, maxNumSlots do
				local button = lib:CreateButton(i, "LABFlyoutButton" .. i, lib.flyoutHandler, nil)
				button:SetScale(0.8)
				button:Hide()

				-- disable drag and drop
				button:SetAttribute("LABdisableDragNDrop", true)

				-- link the button to the header
				lib.flyoutHandler:SetFrameRef("flyoutButton" .. i, button)
				table.insert(lib.FlyoutButtons, button)

				lib.callbacks:Fire("OnFlyoutButtonCreated", button)
			end

			lib.flyoutHandler:SetAttribute("numFlyoutButtons", #lib.FlyoutButtons)
		end

		-- hide flyout frame
		GetFlyoutHandler():Hide()

		-- ensure buttons are cleared, they will be filled when the flyout is shown
		for i = 1, #lib.FlyoutButtons do
			lib.FlyoutButtons[i]:SetState(0, "empty")
		end

		InSync = false
	end

	-- discover all possible flyouts
	function DiscoverFlyoutSpells()
		-- 300 is a safe upper limit in 10.0.2, the highest known spell is 229
		for flyoutID = 1, 300 do
			local success, _, _, numSlots, isKnown = pcall(GetFlyoutInfo, flyoutID)
			if success then
				lib.FlyoutInfo[flyoutID] = { numSlots = numSlots, isKnown = isKnown, slots = {} }
				for slotID = 1, numSlots do
					local spellID, overrideSpellID, isKnownSlot = GetFlyoutSlotInfo(flyoutID, slotID)

					-- hide empty pet slots from the flyout
					local petIndex, petName = GetCallPetSpellInfo(spellID)
					if petIndex and (not petName or petName == "") then
						isKnownSlot = false
					end

					lib.FlyoutInfo[flyoutID].slots[slotID] = { spellID = spellID, overrideSpellID = overrideSpellID, isKnown = isKnownSlot }
				end
			end
		end

		SyncFlyoutInfoToHandler()
	end

	-- update flyout information (mostly the isKnown flag)
	function UpdateFlyoutSpells()
		if InCombatLockdown() then
			FlyoutUpdateQueued = true
			return
		end

		for flyoutID, data in pairs(lib.FlyoutInfo) do
			local success, _, _, numSlots, isKnown = pcall(GetFlyoutInfo, flyoutID)
			if success then
				data.isKnown = isKnown
				for slotID = 1, numSlots do
					local spellID, overrideSpellID, isKnownSlot = GetFlyoutSlotInfo(flyoutID, slotID)

					-- hide empty pet slots from the flyout
					local petIndex, petName = GetCallPetSpellInfo(spellID)
					if petIndex and (not petName or petName == "") then
						isKnownSlot = false
					end

					data.slots[slotID].spellID = spellID
					data.slots[slotID].overrideSpellID = overrideSpellID
					data.slots[slotID].isKnown = isKnownSlot
				end
			end
		end

		SyncFlyoutInfoToHandler()
	end
end

-----------------------------------------------------------
--- frame scripts

-- copied (and adjusted) from SecureHandlers.lua
local function PickupAny(kind, target, detail, ...)
	if kind == "clear" then
		ClearCursor()
		kind, target, detail = target, detail, ...
	end

	if kind == 'action' then
		PickupAction(target)
	elseif kind == 'item' then
		C_Item.PickupItem(target)
	elseif kind == 'macro' then
		PickupMacro(target)
	elseif kind == 'petaction' then
		PickupPetAction(target)
	elseif kind == 'spell' then
		if C_Spell and C_Spell.PickupSpell then
			C_Spell.PickupSpell(target)
		else
			PickupSpell(target)
		end
	elseif kind == 'companion' then
		PickupCompanion(target, detail)
	elseif kind == 'equipmentset' then
		C_EquipmentSet.PickupEquipmentSet(target)
	end
end

function Generic:OnEnter()
	if self.config.tooltip ~= "disabled" and (self.config.tooltip ~= "nocombat" or not InCombatLockdown()) then
		UpdateTooltip(self)
	end
	if KeyBound then
		KeyBound:Set(self)
	end

	if self._state_type == "action" and self.NewActionTexture then
		ClearNewActionHighlight(self._state_action, false, false)
		UpdateNewAction(self)
	end

	if FlyoutButtonMixin and UseCustomFlyout then
		FlyoutButtonMixin.OnEnter(self)
	else
		UpdateFlyout(self)
	end
end

function Generic:OnLeave()
	if FlyoutButtonMixin and UseCustomFlyout then
		FlyoutButtonMixin.OnLeave(self)
	else
		UpdateFlyout(self)
	end

	if GameTooltip:IsForbidden() then return end
	GameTooltip:Hide()
end

-- Insecure drag handler to allow clicking on the button with an action on the cursor
-- to place it on the button. Like action buttons work.
function Generic:PreClick()
	if self._state_type == "action" or self._state_type == "pet"
	   or InCombatLockdown() or self:GetAttribute("LABdisableDragNDrop")
	then
		return
	end
	-- check if there is actually something on the cursor
	local kind, value, _subtype = GetCursorInfo()
	if not (kind and value) then return end
	self._old_type = self._state_type
	if self._state_type and self._state_type ~= "empty" then
		self._old_type = self._state_type
		self:SetAttribute("type", "empty")
		--self:SetState(nil, "empty", nil)
	end
	self._receiving_drag = true
end

local function formatHelper(input)
	if type(input) == "string" then
		return format("%q", input)
	else
		return tostring(input)
	end
end

function Generic:PostClick(button, down)
	UpdateButtonState(self)
	UpdateFlyout(self, down)
	if self._receiving_drag and not InCombatLockdown() then
		if self._old_type then
			self:SetAttribute("type", self._old_type)
			self._old_type = nil
		end
		local oldType, oldAction = self._state_type, self._state_action
		local kind, data, subtype, extra = GetCursorInfo()
		self.header:SetFrameRef("updateButton", self)
		self.header:Execute(format([[
			local frame = self:GetFrameRef("updateButton")
			control:RunFor(frame, frame:GetAttribute("OnReceiveDrag"), %s, %s, %s, %s)
			control:RunFor(frame, frame:GetAttribute("UpdateState"), %s)
		]], formatHelper(kind), formatHelper(data), formatHelper(subtype), formatHelper(extra), formatHelper(self:GetAttribute("state"))))
		PickupAny("clear", oldType, oldAction)
	end
	self._receiving_drag = nil

	if self._state_type == "action" and lib.ACTION_HIGHLIGHT_MARKS[self._state_action] then
		ClearNewActionHighlight(self._state_action, false, false)
	end

	if down and IsMouseButtonDown() then
		self:RegisterEvent("GLOBAL_MOUSE_UP")
	end
end

-----------------------------------------------------------
--- configuration

local function merge(target, source, default)
	for k,v in pairs(default) do
		if type(v) ~= "table" then
			if source and source[k] ~= nil then
				target[k] = source[k]
			else
				target[k] = v
			end
		else
			if type(target[k]) ~= "table" then target[k] = {} else wipe(target[k]) end
			merge(target[k], type(source) == "table" and source[k], v)
		end
	end
	return target
end

local function UpdateTextElement(element, config, defaultFont)
	element:SetFont(config.font.font or defaultFont, config.font.size, config.font.flags or "")
	element:SetJustifyH(config.justifyH)
	element:ClearAllPoints()
	element:SetPoint(config.position.anchor, element:GetParent(), config.position.relAnchor or config.position.anchor, config.position.offsetX or 0, config.position.offsetY or 0)

	element:SetVertexColor(unpack(config.color))
end

local function UpdateTextElements(button)
	UpdateTextElement(button.HotKey, button.config.text.hotkey, NumberFontNormalSmallGray:GetFont())
	UpdateTextElement(button.Count, button.config.text.count, NumberFontNormal:GetFont())
	UpdateTextElement(button.Name, button.config.text.macro, GameFontHighlightSmallOutline:GetFont())
end

function Generic:UpdateConfig(config)
	if config and type(config) ~= "table" then
		error("LibActionButton-1.0: UpdateConfig requires a valid configuration!", 2)
	end
	local oldconfig = self.config
	self.config = {}
	-- merge the two configs
	merge(self.config, config, DefaultConfig)

	if self.config.outOfRangeColoring == "button" or (oldconfig and oldconfig.outOfRangeColoring == "button") then
		UpdateUsable(self)
	end
	if self.config.outOfRangeColoring == "hotkey" then
		self.outOfRange = nil
	end

	if self.config.hideElements.macro then
		self.Name:Hide()
	else
		self.Name:Show()
	end

	self:SetAttribute("flyoutDirection", self.config.flyoutDirection)

	UpdateCooldownNumberHidden(self)
	UpdateTextElements(self)
	UpdateHotkeys(self)
	UpdateGrid(self)
	Update(self)
	if not WoWRetail then
		self:RegisterForClicks(self.config.clickOnDown and "AnyDown" or "AnyUp")
	end
end

-----------------------------------------------------------
--- event handler

function ForAllButtons(method, onlyWithAction)
	assert(type(method) == "function")
	for button in next, (onlyWithAction and ActiveButtons or ButtonRegistry) do
		method(button)
	end
end

function InitializeEventHandler()
	lib.eventFrame:SetScript("OnEvent", OnEvent)
	lib.eventFrame:RegisterEvent("CVAR_UPDATE")
	lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	lib.eventFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
	lib.eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
	--lib.eventFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	--lib.eventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	lib.eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	lib.eventFrame:RegisterEvent("UPDATE_BINDINGS")
	lib.eventFrame:RegisterEvent("GAME_PAD_ACTIVE_CHANGED")
	lib.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	lib.eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
	if not WoWClassic and not WoWBCC then
		lib.eventFrame:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	end

	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	lib.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	lib.eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
	lib.eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")

	lib.eventFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
	lib.eventFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
	lib.eventFrame:RegisterEvent("START_AUTOREPEAT_SPELL")
	lib.eventFrame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
	lib.eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	lib.eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
	lib.eventFrame:RegisterEvent("PET_STABLE_UPDATE")
	lib.eventFrame:RegisterEvent("PET_STABLE_SHOW")
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_ICON")
	if not WoWClassic and not WoWBCC then
		if not WoWWrath then
			lib.eventFrame.showGlow = true -- NDui
			lib.eventFrame:RegisterEvent("ARCHAEOLOGY_CLOSED")
			lib.eventFrame:RegisterEvent("UPDATE_SUMMONPETS_ACTION")
			lib.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
			lib.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
		end
		lib.eventFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
		lib.eventFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
		lib.eventFrame:RegisterEvent("COMPANION_UPDATE")
	end

	-- With those two, do we still need the ACTIONBAR equivalents of them?
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_USABLE")
	lib.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	lib.eventFrame:RegisterEvent("LOSS_OF_CONTROL_ADDED")
	lib.eventFrame:RegisterEvent("LOSS_OF_CONTROL_UPDATE")

	if UseCustomFlyout then
		lib.eventFrame:RegisterEvent("PLAYER_LOGIN")
		lib.eventFrame:RegisterEvent("SPELLS_CHANGED")
		lib.eventFrame:RegisterEvent("SPELL_FLYOUT_UPDATE")
	end

	lib.eventFrame:Show()
	lib.eventFrame:SetScript("OnUpdate", OnUpdate)

	if UseCustomFlyout and IsLoggedIn() then
		DiscoverFlyoutSpells()
	end
end

local _lastFormUpdate = GetTime()
function OnEvent(frame, event, arg1, ...)
	if event == "PLAYER_LOGIN" then
		if UseCustomFlyout then
			DiscoverFlyoutSpells()
		end
	elseif event == "CVAR_UPDATE" then
		if arg1 == "countdownForCooldowns" then
			ForAllButtons(UpdateCooldownNumberHidden)
		end
	elseif event == "SPELLS_CHANGED" or event == "SPELL_FLYOUT_UPDATE" then
		if UseCustomFlyout then
			UpdateFlyoutSpells()
		end
	elseif (event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "LEARNED_SPELL_IN_TAB" then
		local tooltipOwner = GameTooltip_GetOwnerForbidden()
		if tooltipOwner and ButtonRegistry[tooltipOwner] then
			tooltipOwner:SetTooltip()
		end
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		for button in next, ButtonRegistry do
			if button._state_type == "action" and (arg1 == 0 or arg1 == tonumber(button._state_action)) then
				ClearNewActionHighlight(button._state_action, true, false)
				Update(button)
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_VEHICLE_ACTIONBAR" then
		ForAllButtons(Update)
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		-- XXX: throttle these updates since Blizzard broke the event and its now extremely spammy in some clients
		local _time = GetTime()
		if (_time - _lastFormUpdate) < 1 then
			return
		end
		_lastFormUpdate = _time

		-- the attack icon can change when shapeshift form changes, so need to do a quick update here
		-- for performance reasons don't run full updates here, though
		for button in next, ActiveButtons do
			local texture = button:GetTexture()
			if texture then
				button.icon:SetTexture(texture)
			end
		end
	elseif event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" then
		-- TODO: Are these even needed?
	elseif event == "ACTIONBAR_SHOWGRID" then
		ShowGrid()
	elseif event == "ACTIONBAR_HIDEGRID" then
		HideGrid()
	elseif event == "UPDATE_BINDINGS" or event == "GAME_PAD_ACTIVE_CHANGED" then
		ForAllButtons(UpdateHotkeys)
	elseif event == "PLAYER_TARGET_CHANGED" then
		UpdateRangeTimer()
	elseif (event == "ACTIONBAR_UPDATE_STATE") or
		((event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and (arg1 == "player")) or
		((event == "COMPANION_UPDATE") and (arg1 == "MOUNT")) then
		ForAllButtons(UpdateButtonState, true)
	elseif event == "ACTIONBAR_UPDATE_USABLE" then
		for button in next, ActionButtons do
			UpdateUsable(button)
		end
	elseif event == "SPELL_UPDATE_USABLE" then
		for button in next, NonActionButtons do
			UpdateUsable(button)
		end
	elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
		for button in next, ActiveButtons do
			UpdateUsable(button)
		end
	elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
		for button in next, ActionButtons do
			UpdateCooldown(button)
			if GameTooltip_GetOwnerForbidden() == button then
				UpdateTooltip(button)
			end
		end
	elseif event == "SPELL_UPDATE_COOLDOWN" then
		for button in next, NonActionButtons do
			UpdateCooldown(button)
			if GameTooltip_GetOwnerForbidden() == button then
				UpdateTooltip(button)
			end
		end
	elseif event == "LOSS_OF_CONTROL_ADDED" then
		for button in next, ActiveButtons do
			UpdateCooldown(button)
			if GameTooltip_GetOwnerForbidden() == button then
				UpdateTooltip(button)
			end
		end
	elseif event == "LOSS_OF_CONTROL_UPDATE" then
		for button in next, ActiveButtons do
			UpdateCooldown(button)
		end
	elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE"  or event == "ARCHAEOLOGY_CLOSED" then
		ForAllButtons(UpdateButtonState, true)
	elseif event == "PLAYER_ENTER_COMBAT" then
		for button in next, ActiveButtons do
			if button:IsAttack() then
				StartFlash(button)
			end
		end
	elseif event == "PLAYER_LEAVE_COMBAT" then
		for button in next, ActiveButtons do
			if button:IsAttack() then
				StopFlash(button)
			end
		end

		if UseCustomFlyout and FlyoutUpdateQueued then
			UpdateFlyoutSpells()
			FlyoutUpdateQueued = nil
		end
	elseif event == "START_AUTOREPEAT_SPELL" then
		for button in next, ActiveButtons do
			if button:IsAutoRepeat() then
				StartFlash(button)
			end
		end
	elseif event == "STOP_AUTOREPEAT_SPELL" then
		for button in next, ActiveButtons do
			if button.flashing == 1 and not button:IsAttack() then
				StopFlash(button)
			end
		end
	elseif event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW" then
		ForAllButtons(Update)

		if event == "PET_STABLE_UPDATE" and UseCustomFlyout then
			UpdateFlyoutSpells()
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		for button in next, ActiveButtons do
			local spellId = button:GetSpellId()
			if spellId and spellId == arg1 then
				ShowOverlayGlow(button)
			else
				if button._state_type == "action" then
					local actionType, id = GetActionInfo(button._state_action)
					if actionType == "flyout" and FlyoutHasSpell(id, arg1) then
						ShowOverlayGlow(button)
					end
				end
			end
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		for button in next, ActiveButtons do
			local spellId = button:GetSpellId()
			if spellId and spellId == arg1 then
				HideOverlayGlow(button)
			else
				if button._state_type == "action" then
					local actionType, id = GetActionInfo(button._state_action)
					if actionType == "flyout" and FlyoutHasSpell(id, arg1) then
						HideOverlayGlow(button)
					end
				end
			end
		end
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		for button in next, ActiveButtons do
			if button._state_type == "item" then
				Update(button)
			end
		end
	elseif event == "SPELL_UPDATE_CHARGES" then
		ForAllButtons(UpdateCount, true)
	elseif event == "UPDATE_SUMMONPETS_ACTION" then
		for button in next, ActiveButtons do
			if button._state_type == "action" then
				local actionType, _id = GetActionInfo(button._state_action)
				if actionType == "summonpet" then
					local texture = GetActionTexture(button._state_action)
					if texture then
						button.icon:SetTexture(texture)
					end
				end
			end
		end
	elseif event == "SPELL_UPDATE_ICON" then
		ForAllButtons(Update, true)
	end
end

local flashTime = 0
local rangeTimer = -1
function OnUpdate(_, elapsed)
	flashTime = flashTime - elapsed
	rangeTimer = rangeTimer - elapsed
	-- Run the loop only when there is something to update
	if rangeTimer <= 0 or flashTime <= 0 then
		for button in next, ActiveButtons do
			-- Flashing
			if button.flashing == 1 and flashTime <= 0 then
				if button.Flash:IsShown() then
					button.Flash:Hide()
				else
					button.Flash:Show()
				end
			end

			-- Range
			if rangeTimer <= 0 then
				local inRange = button:IsInRange()
				local oldRange = button.outOfRange
				button.outOfRange = (inRange == false)
				if oldRange ~= button.outOfRange then
					if button.config.outOfRangeColoring == "button" then
						UpdateUsable(button)
					elseif button.config.outOfRangeColoring == "hotkey" then
						local hotkey = button.HotKey
						if hotkey:GetText() == RANGE_INDICATOR then
							if inRange == false then
								hotkey:Show()
							else
								hotkey:Hide()
							end
						end
						if inRange == false then
							hotkey:SetVertexColor(unpack(button.config.colors.range))
						else
							hotkey:SetVertexColor(unpack(button.config.text.hotkey.color))
						end
					end
				end
			end
		end

		-- Update values
		if flashTime <= 0 then
			flashTime = flashTime + ATTACK_BUTTON_FLASH_TIME
		end
		if rangeTimer <= 0 then
			rangeTimer = TOOLTIP_UPDATE_TIME
		end
	end
end

local gridCounter = 0
function ShowGrid()
	gridCounter = gridCounter + 1
	if gridCounter >= 1 then
		for button in next, ButtonRegistry do
			if button:IsShown() then
				button:SetAlpha(1.0)
			end
		end
	end
end

function HideGrid()
	if gridCounter > 0 then
		gridCounter = gridCounter - 1
	end
	if gridCounter == 0 then
		for button in next, ButtonRegistry do
			if button:IsShown() and not button:HasAction() and not button.config.showGrid then
				button:SetAlpha(0.0)
			end
		end
	end
end

function UpdateGrid(self)
	if self.config.showGrid then
		self:SetAlpha(1.0)
	elseif gridCounter == 0 and self:IsShown() and not self:HasAction() then
		self:SetAlpha(0.0)
	end
end

-----------------------------------------------------------
--- KeyBound integration

function Generic:GetBindingAction()
	return self.config.keyBoundTarget or ("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton)
end

function Generic:GetHotkey()
	local name = ("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton)
	local key = GetBindingKey(self.config.keyBoundTarget or name)
	if not key and self.config.keyBoundTarget then
		key = GetBindingKey(name)
	end
	if key then
		return KeyBound and KeyBound:ToShortKey(key) or key
	end
end

local function getKeys(binding, keys)
	keys = keys or ""
	for i = 1, select("#", GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ", "
		end
		keys = keys .. GetBindingText(hotKey)
	end
	return keys
end

function Generic:GetBindings()
	local keys

	if self.config.keyBoundTarget then
		keys = getKeys(self.config.keyBoundTarget)
	end

	keys = getKeys(("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton), keys)

	return keys
end

function Generic:SetKey(key)
	if self.config.keyBoundTarget then
		SetBinding(key, self.config.keyBoundTarget)
	else
		SetBindingClick(key, self:GetName(), self.config.keyBoundClickButton)
	end
	lib.callbacks:Fire("OnKeybindingChanged", self, key)
end

local function clearBindings(binding)
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

function Generic:ClearBindings()
	if self.config.keyBoundTarget then
		clearBindings(self.config.keyBoundTarget)
	end
	clearBindings(("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton))
	lib.callbacks:Fire("OnKeybindingChanged", self, nil)
end

-----------------------------------------------------------
--- button management

function Generic:UpdateAction(force)
	local action_type, action = self:GetAction()
	if force or action_type ~= self._state_type or action ~= self._state_action then
		-- type changed, update the metatable
		if force or self._state_type ~= action_type then
			local meta = type_meta_map[action_type] or type_meta_map.empty
			setmetatable(self, meta)
			self._state_type = action_type
		end
		self._state_action = action
		Update(self)
	end
end
-- NDui: add quality border
local GetProfessionQuality = C_ActionBar and C_ActionBar.GetProfessionQuality

local function ClearProfessionQuality(self)
	if self.ProfessionQuality then
		self.ProfessionQuality:Hide()
	end
end

local function UpdateProfessionQuality(self)
	if self._state_type == "custom" then return end

	local action = self._state_action
	if action and IsItemAction(action) then
		local quality = GetProfessionQuality(action)
		if quality then
			if not self.ProfessionQuality then
				self.ProfessionQuality = CreateFrame("Frame", nil, self)
				self.ProfessionQuality:SetInside()
				local tex = self.ProfessionQuality:CreateTexture(nil, "ARTWORK")
				tex:SetPoint("TOPLEFT")
				self.ProfessionQuality.Texture = tex
			end
			self.ProfessionQuality:Show()
			self.ProfessionQuality.Texture:SetAtlas(format("Professions-Icon-Quality-Tier%d-Inv", quality), true)
			return
		end
	end
	ClearProfessionQuality(self)
end

function Update(self)
	if self:HasAction() then
		ActiveButtons[self] = true
		if self._state_type == "action" then
			ActionButtons[self] = true
			NonActionButtons[self] = nil
		else
			ActionButtons[self] = nil
			NonActionButtons[self] = true
		end
		self:SetAlpha(1.0)
		UpdateButtonState(self)
		UpdateUsable(self)
		UpdateCooldown(self)
		UpdateFlash(self)
		if GetProfessionQuality then
			UpdateProfessionQuality(self)
		end
	else
		ActiveButtons[self] = nil
		ActionButtons[self] = nil
		NonActionButtons[self] = nil
		if gridCounter == 0 and not self.config.showGrid then
			self:SetAlpha(0.0)
		end
		self.cooldown:Hide()
		self:SetChecked(false)
		if GetProfessionQuality then
			ClearProfessionQuality(self)
		end

		if self.chargeCooldown then
			EndChargeCooldown(self.chargeCooldown)
		end

		if self.LevelLinkLockIcon then
			self.LevelLinkLockIcon:SetShown(false)
		end
	end

	-- Add a green border if button is an equipped item
	if self:IsEquipped() and not self.config.hideElements.equipped then
		self.Border:SetVertexColor(0, 1.0, 0, 0.35)
		self.Border:Show()
	else
		self.Border:Hide()
	end

	-- Update Action Text
	if not self:IsConsumableOrStackable() then
		self.Name:SetText(self:GetActionText())
	else
		self.Name:SetText("")
	end

	-- Update icon and hotkey
	local texture = self:GetTexture()

	-- Zone ability button handling
	self.zoneAbilityDisabled = false
	self.icon:SetDesaturated(false)

	if texture then
		self.icon:SetTexture(texture)
		self.icon:Show()
		self.rangeTimer = - 1
		if WoWRetail then
			if not self.MasqueSkinned then
				self.SlotBackground:Hide()
				if self.config.hideElements.border then
					self.NormalTexture:SetTexture()
					self.icon:RemoveMaskTexture(self.IconMask)
					self.HighlightTexture:SetSize(52, 51)
					self.HighlightTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -2.5, 2.5)
					self.CheckedTexture:SetSize(52, 51)
					self.CheckedTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -2.5, 2.5)
					self.cooldown:ClearAllPoints()
					self.cooldown:SetAllPoints()
				else
					self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame-AddRow")
					self.icon:AddMaskTexture(self.IconMask)
					self.HighlightTexture:SetSize(46, 45)
					self.HighlightTexture:SetPoint("TOPLEFT")
					self.CheckedTexture:SetSize(46, 45)
					self.CheckedTexture:SetPoint("TOPLEFT")
					self.cooldown:ClearAllPoints()
					self.cooldown:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -2)
					self.cooldown:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
				end
			end
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
			if not self.LBFSkinned and not self.MasqueSkinned then
				self.NormalTexture:SetTexCoord(0, 0, 0, 0)
			end
		end
	else
		self.icon:Hide()
		self.cooldown:Hide()
		self.rangeTimer = nil
		if self.HotKey:GetText() == RANGE_INDICATOR then
			self.HotKey:Hide()
		else
			self.HotKey:SetVertexColor(unpack(self.config.text.hotkey.color))
		end
		if WoWRetail then
			if not self.MasqueSkinned then
				self.SlotBackground:Show()
				if self.config.hideElements.borderIfEmpty then
					self.NormalTexture:SetTexture()
				else
					self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame-AddRow")
				end
			end
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
			if not self.LBFSkinned and not self.MasqueSkinned then
				self.NormalTexture:SetTexCoord(-0.15, 1.15, -0.15, 1.17)
			end
		end
	end

	self:UpdateLocal()

	UpdateCount(self)

	UpdateFlyout(self)

	UpdateOverlayGlow(self)

	UpdateNewAction(self)

	UpdateSpellHighlight(self)

	if GameTooltip_GetOwnerForbidden() == self then
		UpdateTooltip(self)
	end

	-- this could've been a spec change, need to call OnStateChanged for action buttons, if present
	if not InCombatLockdown() and self._state_type == "action" then
		local onStateChanged = self:GetAttribute("OnStateChanged")
		if onStateChanged then
			self.header:SetFrameRef("updateButton", self)
			self.header:Execute(([[
				local frame = self:GetFrameRef("updateButton")
				control:RunFor(frame, frame:GetAttribute("OnStateChanged"), %s, %s, %s)
			]]):format(formatHelper(self:GetAttribute("state")), formatHelper(self._state_type), formatHelper(self._state_action)))
		end
	end
	lib.callbacks:Fire("OnButtonUpdate", self)
end

function Generic:UpdateLocal()
-- dummy function the other button types can override for special updating
end

function UpdateButtonState(self)
	if self:IsCurrentlyActive() or self:IsAutoRepeat() then
		self:SetChecked(true)
	else
		self:SetChecked(false)
	end
	lib.callbacks:Fire("OnButtonState", self)
end

function UpdateUsable(self)
	-- TODO: make the colors configurable
	-- TODO: allow disabling of the whole recoloring
	if self.config.outOfRangeColoring == "button" and self.outOfRange then
		self.icon:SetVertexColor(unpack(self.config.colors.range))
	else
		local isUsable, notEnoughMana = self:IsUsable()
		if isUsable then
			self.icon:SetVertexColor(1.0, 1.0, 1.0)
			--self.NormalTexture:SetVertexColor(1.0, 1.0, 1.0)
		elseif notEnoughMana then
			self.icon:SetVertexColor(unpack(self.config.colors.mana))
			--self.NormalTexture:SetVertexColor(0.5, 0.5, 1.0)
		else
			self.icon:SetVertexColor(0.4, 0.4, 0.4)
			--self.NormalTexture:SetVertexColor(1.0, 1.0, 1.0)
		end
	end

	if WoWRetail and self._state_type == "action" then
		local isLevelLinkLocked = C_LevelLink.IsActionLocked(self._state_action)
		if not self.icon:IsDesaturated() then
			self.icon:SetDesaturated(isLevelLinkLocked)
		end

		if self.LevelLinkLockIcon then
			self.LevelLinkLockIcon:SetShown(isLevelLinkLocked)
		end
	end

	lib.callbacks:Fire("OnButtonUsable", self)
end

function UpdateCount(self)
	if not self:HasAction() then
		self.Count:SetText("")
		return
	end
	if self:IsConsumableOrStackable() then
		local count = self:GetCount()
		if count > (self.maxDisplayCount or 9999) then
			self.Count:SetText("*")
		else
			self.Count:SetText(count)
		end
	else
		local charges, maxCharges, _chargeStart, _chargeDuration = self:GetCharges()
		if charges and maxCharges and maxCharges > 1 then
			self.Count:SetText(charges)
		else
			self.Count:SetText("")
		end
	end
end

function EndChargeCooldown(self)
	self:Hide()
	self:SetParent(UIParent)
	self.parent.chargeCooldown = nil
	self.parent = nil
	tinsert(lib.ChargeCooldowns, self)
end

local function StartChargeCooldown(parent, chargeStart, chargeDuration, chargeModRate)
	if not parent.chargeCooldown then
		local cooldown = tremove(lib.ChargeCooldowns)
		if not cooldown then
			lib.NumChargeCooldowns = lib.NumChargeCooldowns + 1
			cooldown = CreateFrame("Cooldown", "LAB10ChargeCooldown"..lib.NumChargeCooldowns, parent, "CooldownFrameTemplate");
			cooldown:SetScript("OnCooldownDone", EndChargeCooldown)
			cooldown:SetHideCountdownNumbers(true)
			cooldown:SetDrawSwipe(false)
		end
		cooldown:SetParent(parent)
		cooldown:SetAllPoints(parent)
		cooldown:SetFrameStrata("TOOLTIP")
		cooldown:Show()
		parent.chargeCooldown = cooldown
		cooldown.parent = parent
	end
	-- set cooldown
	parent.chargeCooldown:SetDrawBling(parent.chargeCooldown:GetEffectiveAlpha() > 0.5)
	CooldownFrame_Set(parent.chargeCooldown, chargeStart, chargeDuration, true, true, chargeModRate)

	-- update charge cooldown skin when masque is used
	if Masque and Masque.UpdateCharge then
		Masque:UpdateCharge(parent)
	end

	if not chargeStart or chargeStart == 0 then
		EndChargeCooldown(parent.chargeCooldown)
	end
end

local function OnCooldownDone(self)
	self:SetScript("OnCooldownDone", nil)
	UpdateCooldown(self:GetParent())
end

function UpdateCooldownNumberHidden(self)
	local shouldBeHidden
	if self.config.cooldownCount == nil then
		shouldBeHidden = self.cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL or GetCVarBool("countdownForCooldowns") ~= true
	else
		shouldBeHidden = not self.config.cooldownCount
	end
	self.cooldown:SetHideCountdownNumbers(shouldBeHidden)
end

function UpdateCooldown(self)
	local locStart, locDuration
	local start, duration, enable, modRate
	local charges, maxCharges, chargeStart, chargeDuration, chargeModRate
	local auraData

	local passiveCooldownSpellID = self:GetPassiveCooldownSpellID()
	if passiveCooldownSpellID and passiveCooldownSpellID ~= 0 then
		auraData = C_UnitAuras.GetPlayerAuraBySpellID(passiveCooldownSpellID)
	end

	if auraData then
		local currentTime = GetTime()
		local timeUntilExpire = auraData.expirationTime - currentTime
		local howMuchTimeHasPassed = auraData.duration - timeUntilExpire

		locStart =  currentTime - howMuchTimeHasPassed
		locDuration = auraData.expirationTime - currentTime
		start = currentTime - howMuchTimeHasPassed
		duration =  auraData.duration
		modRate = auraData.timeMod
		charges = auraData.charges
		maxCharges = auraData.maxCharges
		chargeStart = currentTime * 0.001
		chargeDuration = duration * 0.001
		chargeModRate = modRate
		enable = 1
	else
		locStart, locDuration = self:GetLossOfControlCooldown()
		start, duration, enable, modRate = self:GetCooldown()
		charges, maxCharges, chargeStart, chargeDuration, chargeModRate = self:GetCharges()
	end

	self.cooldown:SetDrawBling(self.cooldown:GetEffectiveAlpha() > 0.5)

	local hasLocCooldown = locStart and locDuration and locStart > 0 and locDuration > 0
	local hasCooldown = enable and start and duration and start > 0 and duration > 0
	if hasLocCooldown and ((not hasCooldown) or ((locStart + locDuration) > (start + duration))) then
		if self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_LOSS_OF_CONTROL then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge-LoC")
			self.cooldown:SetSwipeColor(0.17, 0, 0)
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_LOSS_OF_CONTROL
			UpdateCooldownNumberHidden(self)
		end
		CooldownFrame_Set(self.cooldown, locStart, locDuration, true, true, modRate)
		if self.chargeCooldown then
			EndChargeCooldown(self.chargeCooldown)
		end
	else
		if self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_NORMAL then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
			self.cooldown:SetSwipeColor(0, 0, 0)
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL
			UpdateCooldownNumberHidden(self)
		end
		if hasLocCooldown then
			self.cooldown:SetScript("OnCooldownDone", OnCooldownDone)
		end

		if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
			StartChargeCooldown(self, chargeStart, chargeDuration, chargeModRate)
		elseif self.chargeCooldown then
			EndChargeCooldown(self.chargeCooldown)
		end
		CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate)
	end
end

function StartFlash(self)
	self.flashing = 1
	flashTime = 0
	UpdateButtonState(self)
end

function StopFlash(self)
	self.flashing = 0
	self.Flash:Hide()
	UpdateButtonState(self)
end

function UpdateFlash(self)
	if (self:IsAttack() and self:IsCurrentlyActive()) or self:IsAutoRepeat() then
		StartFlash(self)
	else
		StopFlash(self)
	end
end

function UpdateTooltip(self)
	if GameTooltip:IsForbidden() then return end
	if (GetCVar("UberTooltips") == "1") then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	if self:SetTooltip() then
		self.UpdateTooltip = UpdateTooltip
	else
		self.UpdateTooltip = nil
	end
end

function UpdateHotkeys(self)
	local key = self:GetHotkey()
	if not key or key == "" or self.config.hideElements.hotkey then
		self.HotKey:SetText(RANGE_INDICATOR)
		self.HotKey:Hide()
	else
		self.HotKey:SetText(key)
		self.HotKey:Show()
	end
end
-- NDui: custom glow
function ShowOverlayGlow(self)
	if LCG and lib.eventFrame.showGlow then
		LCG.ShowOverlayGlow(self)
	end
end

function HideOverlayGlow(self)
	if LCG then
		LCG.HideOverlayGlow(self)
	end
end

function UpdateOverlayGlow(self)
	local spellId = lib.eventFrame.showGlow and self:GetSpellId()
	if spellId and IsSpellOverlayed(spellId) then
		ShowOverlayGlow(self)
	else
		HideOverlayGlow(self)
	end
end

function ClearNewActionHighlight(action, preventIdenticalActionsFromClearing, value)
	lib.ACTION_HIGHLIGHT_MARKS[action] = value

	for button in next, ButtonRegistry do
		if button._state_type == "action" and action == tonumber(button._state_action) then
			UpdateNewAction(button)
		end
	end

	if preventIdenticalActionsFromClearing then
		return
	end

	-- iterate through actions and unmark all that are the same type
	local unmarkedType, unmarkedID = GetActionInfo(action)
	for actionKey, markValue in pairs(lib.ACTION_HIGHLIGHT_MARKS) do
		if markValue then
			local actionType, actionID = GetActionInfo(actionKey)
			if actionType == unmarkedType and actionID == unmarkedID then
				ClearNewActionHighlight(actionKey, true, value)
			end
		end
	end
end

hooksecurefunc("MarkNewActionHighlight", function(action)
	lib.ACTION_HIGHLIGHT_MARKS[action] = true
	for button in next, ButtonRegistry do
		if button._state_type == "action" and action == tonumber(button._state_action) then
			UpdateNewAction(button)
		end
	end
end)

hooksecurefunc("ClearNewActionHighlight", function(action, preventIdenticalActionsFromClearing)
	ClearNewActionHighlight(action, preventIdenticalActionsFromClearing, nil)
end)

function UpdateNewAction(self)
	-- special handling for "New Action" markers
	if self.NewActionTexture then
		if self._state_type == "action" and lib.ACTION_HIGHLIGHT_MARKS[self._state_action] then
			self.NewActionTexture:Show()
		else
			self.NewActionTexture:Hide()
		end
	end
end

hooksecurefunc("UpdateOnBarHighlightMarksBySpell", function(spellID)
	lib.ON_BAR_HIGHLIGHT_MARK_TYPE = "spell"
	lib.ON_BAR_HIGHLIGHT_MARK_ID = tonumber(spellID)
end)

hooksecurefunc("UpdateOnBarHighlightMarksByFlyout", function(flyoutID)
	lib.ON_BAR_HIGHLIGHT_MARK_TYPE = "flyout"
	lib.ON_BAR_HIGHLIGHT_MARK_ID = tonumber(flyoutID)
end)

hooksecurefunc("ClearOnBarHighlightMarks", function()
	lib.ON_BAR_HIGHLIGHT_MARK_TYPE = nil
end)

if ActionBarController_UpdateAllSpellHighlights then
	hooksecurefunc("ActionBarController_UpdateAllSpellHighlights", function()
		for button in next, ButtonRegistry do
			UpdateSpellHighlight(button)
		end
	end)
end

function UpdateSpellHighlight(self)
	local shown = false

	local highlightType, id = lib.ON_BAR_HIGHLIGHT_MARK_TYPE, lib.ON_BAR_HIGHLIGHT_MARK_ID
	if highlightType == "spell" and self:GetSpellId() == id then
		shown = true
	elseif highlightType == "flyout" and self._state_type == "action" then
		local actionType, actionId = GetActionInfo(self._state_action)
		if actionType == "flyout" and actionId == id then
			shown = true
		end
	end

	if shown then
		self.SpellHighlightTexture:Show()
		self.SpellHighlightAnim:Play()
	else
		self.SpellHighlightTexture:Hide()
		self.SpellHighlightAnim:Stop()
	end
end

-- Hook UpdateFlyout so we can use the blizzy templates
if ActionButton_UpdateFlyout then
	hooksecurefunc("ActionButton_UpdateFlyout", function(self, ...)
		if ButtonRegistry[self] then
			UpdateFlyout(self)
		end
	end)

	function UpdateFlyout(self)
		-- disabled FlyoutBorder/BorderShadow, those are not handled by LBF and look terrible
		if self.FlyoutBorder then
			self.FlyoutBorder:Hide()
		end
		self.FlyoutBorderShadow:Hide()
		if self._state_type == "action" then
			-- based on ActionButton_UpdateFlyout in ActionButton.lua
			local actionType = GetActionInfo(self._state_action)
			if actionType == "flyout" then

				local isFlyoutShown = SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self
				local arrowDistance = isFlyoutShown and 1 or 4

				-- Update arrow
				self.FlyoutArrow:Show()
				self.FlyoutArrow:ClearAllPoints()
				local direction = self:GetAttribute("flyoutDirection")
				if direction == "LEFT" then
					self.FlyoutArrow:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 90 or 270)
				elseif direction == "RIGHT" then
					self.FlyoutArrow:SetPoint("RIGHT", self, "RIGHT", arrowDistance, 0)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 270 or 90)
				elseif direction == "DOWN" then
					self.FlyoutArrow:SetPoint("BOTTOM", self, "BOTTOM", 0, -arrowDistance)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 0 or 180)
				else
					self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 180 or 0)
				end

				-- return here, otherwise flyout is hidden
				return
			end
		end
		self.FlyoutArrow:Hide()
	end
elseif FlyoutButtonMixin and UseCustomFlyout then
	function Generic:GetPopupDirection()
		return self:GetAttribute("flyoutDirection") or "UP"
	end

	function Generic:IsPopupOpen()
		return (lib.flyoutHandler and lib.flyoutHandler:IsShown() and lib.flyoutHandler:GetParent() == self)
	end

	function UpdateFlyout(self, isButtonDownOverride)
		self.BorderShadow:Hide()
		if self._state_type == "action" then
			-- based on ActionButton_UpdateFlyout in ActionButton.lua
			local actionType = GetActionInfo(self._state_action)
			if actionType == "flyout" then
				self.Arrow:Show()
				self:UpdateArrowTexture()
				self:UpdateArrowRotation()
				self:UpdateArrowPosition()
				-- return here, otherwise flyout is hidden
				return
			end
		end

		self.Arrow:Hide()
	end
else
	function UpdateFlyout(self, isButtonDownOverride)
		self.FlyoutBorderShadow:Hide()
		if self._state_type == "action" then
			-- based on ActionButton_UpdateFlyout in ActionButton.lua
			local actionType = GetActionInfo(self._state_action)
			if actionType == "flyout" then
				local isMouseOverButton = self:IsMouseOver()

				local isButtonDown
				if (isButtonDownOverride ~= nil) then
					isButtonDown = isButtonDownOverride
				else
					isButtonDown = self:GetButtonState() == "PUSHED"
				end

				local flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowNormal

				if (isButtonDown) then
					flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowPushed

					self.FlyoutArrowContainer.FlyoutArrowNormal:Hide()
					self.FlyoutArrowContainer.FlyoutArrowHighlight:Hide()
				elseif (isMouseOverButton) then
					flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowHighlight

					self.FlyoutArrowContainer.FlyoutArrowNormal:Hide()
					self.FlyoutArrowContainer.FlyoutArrowPushed:Hide()
				else
					self.FlyoutArrowContainer.FlyoutArrowHighlight:Hide()
					self.FlyoutArrowContainer.FlyoutArrowPushed:Hide()
				end

				local isFlyoutShown = (SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self) or (lib.flyoutHandler and lib.flyoutHandler:IsShown() and lib.flyoutHandler:GetParent() == self)
				local arrowDistance = isFlyoutShown and 1 or 4

				-- Update arrow
				self.FlyoutArrowContainer:Show()
				flyoutArrowTexture:Show()
				flyoutArrowTexture:ClearAllPoints()

				local direction = self:GetAttribute("flyoutDirection")
				if direction == "LEFT" then
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 90 or 270)
					flyoutArrowTexture:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
				elseif direction == "RIGHT" then
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 270 or 90)
					flyoutArrowTexture:SetPoint("RIGHT", self, "RIGHT", arrowDistance, 0)
				elseif direction == "DOWN" then
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 0 or 180)
					flyoutArrowTexture:SetPoint("BOTTOM", self, "BOTTOM", 0, -arrowDistance)
				else
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 180 or 0)
					flyoutArrowTexture:SetPoint("TOP", self, "TOP", 0, arrowDistance)
				end

				-- return here, otherwise flyout is hidden
				return
			end
		end
		self.FlyoutArrowContainer:Hide()
	end
end
Generic.UpdateFlyout = UpdateFlyout

function UpdateRangeTimer()
	rangeTimer = -1
end

-----------------------------------------------------------
--- WoW API mapping
--- Generic Button
Generic.HasAction               = function(self) return nil end
Generic.GetActionText           = function(self) return "" end
Generic.GetTexture              = function(self) return nil end
Generic.GetCharges              = function(self) return nil end
Generic.GetCount                = function(self) return 0 end
Generic.GetCooldown             = function(self) return nil end
Generic.IsAttack                = function(self) return nil end
Generic.IsEquipped              = function(self) return nil end
Generic.IsCurrentlyActive       = function(self) return nil end
Generic.IsAutoRepeat            = function(self) return nil end
Generic.IsUsable                = function(self) return nil end
Generic.IsConsumableOrStackable = function(self) return nil end
Generic.IsUnitInRange           = function(self, unit) return nil end
Generic.IsInRange               = function(self)
	local unit = self:GetAttribute("unit")
	if unit == "player" then
		unit = nil
	end
	local val = self:IsUnitInRange(unit)
	-- map 1/0 to true false, since the return values are inconsistent between actions and spells
	if val == 1 then val = true elseif val == 0 then val = false end
	return val
end
Generic.SetTooltip              = function(self) return nil end
Generic.GetSpellId              = function(self) return nil end
Generic.GetLossOfControlCooldown = function(self) return 0, 0 end
Generic.GetPassiveCooldownSpellID = function(self) return nil end

-----------------------------------------------------------
--- Action Button
Action.HasAction               = function(self) return HasAction(self._state_action) end
Action.GetActionText           = function(self) return GetActionText(self._state_action) end
Action.GetTexture              = function(self) return GetActionTexture(self._state_action) end
Action.GetCharges              = function(self) return GetActionCharges(self._state_action) end
Action.GetCount                = function(self) return GetActionCount(self._state_action) end
Action.GetCooldown             = function(self) return GetActionCooldown(self._state_action) end
Action.IsAttack                = function(self) return IsAttackAction(self._state_action) end
Action.IsEquipped              = function(self) return IsEquippedAction(self._state_action) end
Action.IsCurrentlyActive       = function(self) return IsCurrentAction(self._state_action) end
Action.IsAutoRepeat            = function(self) return IsAutoRepeatAction(self._state_action) end
Action.IsUsable                = function(self) return IsUsableAction(self._state_action) end
Action.IsConsumableOrStackable = function(self) return IsConsumableAction(self._state_action) or IsStackableAction(self._state_action) or (not IsItemAction(self._state_action) and GetActionCount(self._state_action) > 0) end
Action.IsUnitInRange           = function(self, unit) return IsActionInRange(self._state_action, unit) end
Action.SetTooltip              = function(self) return GameTooltip:SetAction(self._state_action) end
Action.GetSpellId              = function(self)
	local actionType, id, subType = GetActionInfo(self._state_action)
	if actionType == "spell" then
		return id
	elseif actionType == "macro" then
		if subType == "spell" then
			return id
		else
			return (GetMacroSpell(id))
		end
	end
end
Action.GetLossOfControlCooldown = function(self) return GetActionLossOfControlCooldown(self._state_action) end
if C_UnitAuras and C_UnitAuras.GetCooldownAuraBySpellID and C_ActionBar and C_ActionBar.GetItemActionOnEquipSpellID then
	Action.GetPassiveCooldownSpellID = function(self)
		local _actionType, actionID = GetActionInfo(self._state_action)
		local onEquipPassiveSpellID
		if actionID then
			onEquipPassiveSpellID = C_ActionBar.GetItemActionOnEquipSpellID(self._state_action)
		end
		if onEquipPassiveSpellID then
			return C_UnitAuras.GetCooldownAuraBySpellID(onEquipPassiveSpellID)
		else
			local spellID = self:GetSpellId()
			if spellID then
				return C_UnitAuras.GetCooldownAuraBySpellID(spellID)
			end
		end
	end
end

-- Classic overrides for item count breakage
if WoWClassic then
	-- if the library is present, simply use it to override action counts
	local LibClassicSpellActionCount = LibStub("LibClassicSpellActionCount-1.0", true)
	if LibClassicSpellActionCount then
		Action.GetCount = function(self) return LibClassicSpellActionCount:GetActionCount(self._state_action) end
	else
		-- if we don't have the library, only show count for items, like the default UI
		Action.IsConsumableOrStackable = function(self) return IsItemAction(self._state_action) and (IsConsumableAction(self._state_action) or IsStackableAction(self._state_action)) end
	end
end

if not WoWRetail then
	-- disable loss of control cooldown on classic
	Action.GetLossOfControlCooldown = function(self) return 0,0 end
end

local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
local GetSpellCastCount = C_Spell and C_Spell.GetSpellCastCount or GetSpellCount
local IsAttackSpell = C_SpellBook and C_SpellBook.IsAutoAttackSpellBookItem or IsAttackSpell
local IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or IsCurrentSpell
local IsAutoRepeatSpell = C_Spell and C_Spell.IsAutoRepeatSpell or IsAutoRepeatSpell
local IsSpellUsable = C_Spell and C_Spell.IsSpellUsable or IsUsableSpell
local IsConsumableSpell = C_Spell and C_Spell.IsConsumableSpell or IsConsumableSpell
local IsSpellInRange = C_Spell and C_Spell.IsSpellInRange or IsSpellInRange
local GetSpellLossOfControlCooldown = C_Spell and C_Spell.GetSpellLossOfControlCooldown or GetSpellLossOfControlCooldown

-- unwrapped functions that return tables now
local GetSpellCharges = (C_Spell and C_Spell.GetSpellCharges) and function(spell) local c = C_Spell.GetSpellCharges(spell) if c then return c.currentCharges, c.maxCharges, c.cooldownStartTime, c.cooldownDuration end end or GetSpellCharges
local GetSpellCooldown = (C_Spell and C_Spell.GetSpellCooldown) and function(spell) local c = C_Spell.GetSpellCooldown(spell) if c then return c.startTime, c.duration, c.isEnabled, c.modRate end end or GetSpellCooldown

local BOOKTYPE_SPELL = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or "spell"
-----------------------------------------------------------
--- Spell Button
Spell.HasAction               = function(self) return true end
Spell.GetActionText           = function(self) return "" end
Spell.GetTexture              = function(self) return GetSpellTexture(self._state_action) end
Spell.GetCharges              = function(self) return GetSpellCharges(self._state_action) end
Spell.GetCount                = function(self) return GetSpellCastCount(self._state_action) end
Spell.GetCooldown             = function(self) return GetSpellCooldown(self._state_action) end
Spell.IsAttack                = function(self) local slot = FindSpellBookSlotBySpellID(self._state_action) return slot and IsAttackSpell(slot, BOOKTYPE_SPELL) or nil end
Spell.IsEquipped              = function(self) return nil end
Spell.IsCurrentlyActive       = function(self) return IsCurrentSpell(self._state_action) end
Spell.IsAutoRepeat            = function(self) local slot = FindSpellBookSlotBySpellID(self._state_action) return slot and IsAutoRepeatSpell(slot, BOOKTYPE_SPELL) or nil end
Spell.IsUsable                = function(self) return IsSpellUsable(self._state_action) end
Spell.IsConsumableOrStackable = function(self) return IsConsumableSpell(self._state_action) end
Spell.IsUnitInRange           = function(self, unit) local slot = FindSpellBookSlotBySpellID(self._state_action) return slot and IsSpellInRange(slot, BOOKTYPE_SPELL, unit) or nil end
Spell.SetTooltip              = function(self) return GameTooltip:SetSpellByID(self._state_action) end
Spell.GetSpellId              = function(self) return self._state_action end
Spell.GetLossOfControlCooldown = function(self) return GetSpellLossOfControlCooldown(self._state_action) end
if C_UnitAuras then
	Spell.GetPassiveCooldownSpellID = function(self)
		if self._state_action then
			return C_UnitAuras.GetCooldownAuraBySpellID(self._state_action)
		end
	end
end

-----------------------------------------------------------
--- Item Button
local function getItemId(input)
	return input:match("^item:(%d+)")
end

Item.HasAction               = function(self) return true end
Item.GetActionText           = function(self) return "" end
Item.GetTexture              = function(self) return C_Item.GetItemIconByID(self._state_action) end
Item.GetCharges              = function(self) return nil end
Item.GetCount                = function(self) return C_Item.GetItemCount(self._state_action, nil, true) end
Item.GetCooldown             = function(self) return C_Container.GetItemCooldown(getItemId(self._state_action)) end
Item.IsAttack                = function(self) return nil end
Item.IsEquipped              = function(self) return C_Item.IsEquippedItem(self._state_action) end
Item.IsCurrentlyActive       = function(self) return C_Item.IsCurrentItem(self._state_action) end
Item.IsAutoRepeat            = function(self) return nil end
Item.IsUsable                = function(self) return C_Item.IsUsableItem(self._state_action) end
Item.IsConsumableOrStackable = function(self) return C_Item.IsConsumableItem(self._state_action) end
--Item.IsUnitInRange           = function(self, unit) return IsItemInRange(self._state_action, unit) end
Item.SetTooltip              = function(self) return GameTooltip:SetHyperlink(self._state_action) end
Item.GetSpellId              = function(self) return nil end
Item.GetPassiveCooldownSpellID = function(self) return nil end

-----------------------------------------------------------
--- Macro Button
-- TODO: map results of GetMacroSpell/GetMacroItem to proper results
Macro.HasAction               = function(self) return true end
Macro.GetActionText           = function(self) return (GetMacroInfo(self._state_action)) end
Macro.GetTexture              = function(self) return (select(2, GetMacroInfo(self._state_action))) end
Macro.GetCharges              = function(self) return nil end
Macro.GetCount                = function(self) return 0 end
Macro.GetCooldown             = function(self) return nil end
Macro.IsAttack                = function(self) return nil end
Macro.IsEquipped              = function(self) return nil end
Macro.IsCurrentlyActive       = function(self) return nil end
Macro.IsAutoRepeat            = function(self) return nil end
Macro.IsUsable                = function(self) return nil end
Macro.IsConsumableOrStackable = function(self) return nil end
Macro.IsUnitInRange           = function(self, unit) return nil end
Macro.SetTooltip              = function(self) return nil end
Macro.GetSpellId              = function(self) return nil end
Macro.GetPassiveCooldownSpellID = function(self) return nil end

-----------------------------------------------------------
--- Custom Button
Custom.HasAction               = function(self) return true end
Custom.GetActionText           = function(self) return "" end
Custom.GetTexture              = function(self) return self._state_action.texture end
Custom.GetCharges              = function(self) return nil end
Custom.GetCount                = function(self) return 0 end
Custom.GetCooldown             = function(self) return nil end
Custom.IsAttack                = function(self) return nil end
Custom.IsEquipped              = function(self) return nil end
Custom.IsCurrentlyActive       = function(self) return nil end
Custom.IsAutoRepeat            = function(self) return nil end
Custom.IsUsable                = function(self) return true end
Custom.IsConsumableOrStackable = function(self) return nil end
Custom.IsUnitInRange           = function(self, unit) return nil end
Custom.SetTooltip              = function(self) return GameTooltip:SetText(self._state_action.tooltip) end
Custom.GetSpellId              = function(self) return nil end
Custom.RunCustom               = function(self, unit, button) return self._state_action.func(self, unit, button) end
Custom.GetPassiveCooldownSpellID = function(self) return nil end

--- WoW Classic overrides
if not WoWRetail and not WoWCata then
	UpdateOverlayGlow = function() end
end

-----------------------------------------------------------
--- Update old Buttons
if oldversion and next(lib.buttonRegistry) then
	InitializeEventHandler()
	for button in next, lib.buttonRegistry do
		-- this refreshes the metatable on the button
		Generic.UpdateAction(button, true)
		SetupSecureSnippets(button)
		if oldversion < 12 then
			WrapOnClick(button)
		end
		if oldversion < 23 then
			if button.overlay then
				button.overlay:Hide()
				ActionButton_HideOverlayGlow(button)
				button.overlay = nil
				UpdateOverlayGlow(button)
			end
		end
	end
end

if oldversion and lib.flyoutHandler then
	UpdateFlyoutHandlerScripts()
end