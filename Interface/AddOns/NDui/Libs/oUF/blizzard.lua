local _, ns = ...
local oUF = ns.oUF

-- sourced from Blizzard_ArenaUI/Blizzard_ArenaUI.lua
local MAX_ARENA_ENEMIES = _G.MAX_ARENA_ENEMIES or 5

-- sourced from FrameXML/TargetFrame.lua
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5

-- sourced from FrameXML/PartyMemberFrame.lua
local MAX_PARTY_MEMBERS = _G.MAX_PARTY_MEMBERS or 4

-- sourced from Blizzard_FrameXMLBase/Shared/Constants.lua
local MEMBERS_PER_RAID_GROUP = _G.MEMBERS_PER_RAID_GROUP or 5

local isNewPatch = NDui[4].isNewPatch
local hookedNameplates = {}
local isPartyHooked = false
local isPartyHooked = false

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function insecureOnShow(self)
	self:Hide()
end

local function handleFrame(baseName, doNotReparent)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		if(not doNotReparent) then
			frame:SetParent(hiddenParent)
		end

		local health = frame.healthBar or frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		handleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
		PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')

		-- User placed frames don't animate
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
	elseif(unit == 'pet') then
		handleFrame(PetFrame)
	elseif(unit == 'target') then
		handleFrame(TargetFrame)
		handleFrame(ComboFrame)
	elseif(unit == 'focus') then
		handleFrame(FocusFrame)
		handleFrame(TargetofFocusFrame)
	elseif(unit == 'targettarget') then
		handleFrame(TargetFrameToT)
	elseif(unit:match('boss%d?$')) then
		local id = unit:match('boss(%d)')
		if(id) then
			handleFrame('Boss' .. id .. 'TargetFrame')
		else
			for i = 1, MAX_BOSS_FRAMES do
				handleFrame(string.format('Boss%dTargetFrame', i))
			end
		end
	elseif(unit:match('party%d?$')) then
		if not isNewPatch then
		local id = unit:match('party(%d)')
		if(id) then
			handleFrame('PartyMemberFrame' .. id)
		else
			for i = 1, MAX_PARTY_MEMBERS do
				handleFrame(string.format('PartyMemberFrame%d', i))
			end
		end
		else
			if(not isPartyHooked) then
				isPartyHooked = true

				handleFrame(PartyFrame)

				for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
					handleFrame(frame, true)
				end

				for i = 1, MEMBERS_PER_RAID_GROUP do
					handleFrame('CompactPartyFrameMember' .. i)
				end
			end
		end
	elseif(unit:match('arena%d?$')) then
		local id = unit:match('arena(%d)')
		if(id) then
			handleFrame('ArenaEnemyFrame' .. id)
		else
			for i = 1, MAX_ARENA_ENEMIES do
				handleFrame(string.format('ArenaEnemyFrame%d', i))
			end
		end

		-- Blizzard_ArenaUI should not be loaded
		_G.Arena_LoadUI = function() end
		SetCVar('showArenaEnemyFrames', '0', 'SHOW_ARENA_ENEMY_FRAMES_TEXT')
	end
end

function oUF:DisableNamePlate(frame)
	if(not(frame and frame.UnitFrame)) then return end
	if(frame.UnitFrame:IsForbidden()) then return end

	if(not frame.UnitFrame.isHooked) then
		frame.UnitFrame:HookScript('OnShow', insecureOnShow)
		frame.UnitFrame.isHooked = true
	end

	handleFrame(frame.UnitFrame, true)
end

function oUF:DisableBlizzardNamePlate(frame)
	if not isNewPatch then return end
	if(not(frame and frame.UnitFrame)) then return end
	if(frame.UnitFrame:IsForbidden()) then return end

	if(not hookedNameplates[frame]) then
		-- BUG: the hit rect (for clicking) is tied to the original UnitFrame object on the
		--      nameplate, so we can't hide it. instead we force it to be invisible, and adjust
		--      the hit rect insets around it so it matches the nameplate object itself, but we
		--      do that in SpawnNamePlates instead
		-- TODO: remove this hack once we can adjust hitrects ourselves, coming in a later build
		local locked = false
		hooksecurefunc(frame.UnitFrame, 'SetAlpha', function(UnitFrame)
			if(locked or UnitFrame:IsForbidden()) then return end
			locked = true
			UnitFrame:SetAlpha(0)
			locked = false
		end)

		hookedNameplates[frame] = true
	end

	handleFrame(frame.UnitFrame, true, true)
end