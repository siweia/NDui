local _, ns = ...
local oUF = ns.oUF

-- sourced from FrameXML\ArenaUI.lua
local MAX_ARENA_ENEMIES = _G.MAX_ARENA_ENEMIES or 5

-- sourced from FrameXML/TargetFrame.lua
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5

-- sourced from FrameXML/RaidFrame.lua
local MEMBERS_PER_RAID_GROUP = _G.MEMBERS_PER_RAID_GROUP or 5

local hookedFrames = {}
local isArenaHooked = false
local isBossHooked = false
local isPartyHooked = false

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function insecureOnShow(self)
	self:Hide()
end

local function resetParent(self, parent)
	if(parent ~= hiddenParent) then
		self:SetParent(hiddenParent)
	end
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

			if(not hookedFrames[frame]) then
				hooksecurefunc(frame, 'SetParent', resetParent)

				hookedFrames[frame] = true
			end
		end

		local health = frame.healthBar or frame.healthbar or frame.HealthBar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar or frame.ManaBar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt or frame.PowerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end

		local petFrame = frame.petFrame or frame.PetFrame
		if(petFrame) then
			petFrame:UnregisterAllEvents()
		end

		local totFrame = frame.totFrame
		if(totFrame) then
			totFrame:UnregisterAllEvents()
		end

		local classPowerBar = frame.classPowerBar
		if(classPowerBar) then
			classPowerBar:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		handleFrame(PlayerFrame)
	elseif(unit == 'pet') then
		handleFrame(PetFrame)
	elseif(unit == 'target') then
		handleFrame(TargetFrame)
	elseif(unit == 'focus') then
		handleFrame(FocusFrame)
	elseif(unit:match('boss%d?$')) then
		if(not isBossHooked) then
			isBossHooked = true

			-- it's needed because the layout manager can bring frames that are
			-- controlled by containers back from the dead when a user chooses
			-- to revert all changes
			-- for now I'll just reparent it, but more might be needed in the
			-- future, watch it
			handleFrame(BossTargetFrameContainer)

			-- do not reparent frames controlled by containers, the vert/horiz
			-- layout code will go insane because it won't be able to calculate
			-- the size properly, 0 or negative sizes in turn will break the
			-- layout manager, fun...
			for i = 1, MAX_BOSS_FRAMES do
				handleFrame('Boss' .. i .. 'TargetFrame', true)
			end
		end
	elseif(unit:match('party%d?$')) then
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
	elseif(unit:match('arena%d?$')) then
		if(not isArenaHooked) then
			isArenaHooked = true

			-- this disables ArenaEnemyFramesContainer
			SetCVar('showArenaEnemyFrames', '0')
			SetCVar('showArenaEnemyPets', '0')

			-- but still UAE and hide all containers
			handleFrame(ArenaEnemyFramesContainer)
			handleFrame(ArenaEnemyPrepFramesContainer)
			handleFrame(ArenaEnemyMatchFramesContainer)

			for i = 1, MAX_ARENA_ENEMIES do
				handleFrame('ArenaEnemyMatchFrame' .. i, true)
				handleFrame('ArenaEnemyPrepFrame' .. i, true)
			end
		end
	elseif(unit:match('nameplate%d+$')) then
		local frame = C_NamePlate.GetNamePlateForUnit(unit)
		if(frame and frame.UnitFrame) then
			if(not frame.UnitFrame.isHooked) then
				frame.UnitFrame:HookScript('OnShow', insecureOnShow)
				frame.UnitFrame.isHooked = true
			end

			handleFrame(frame.UnitFrame, true)
		end
	end
end