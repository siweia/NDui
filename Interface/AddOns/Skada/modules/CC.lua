
Skada:AddLoadableModule("CC", nil, function(Skada, L)
	if Skada.db.profile.modulesBlocked.CC then return end

	local mod = Skada:NewModule(L["CC breakers"])

	local CLIENT_VERSION = tonumber((select(4, GetBuildInfo())))

	local WoW5 = CLIENT_VERSION > 50000
	local IsInRaid = IsInRaid or function() return GetNumRaidMembers() > 0 end

	-- CC spell IDs shamelessly stolen from Recount - thanks!
	local CCId={
		[118]=true, -- Polymorph
		[28272]=true, -- Polymorph Pig
		[28271]=true, -- Polymorph Turtle
		[61305]=true, -- Polymorph Black Cat
		[61721]=true, -- Polymorph Rabbit
		[61780]=true, -- Polymorph Turkey
		[9484]=true, -- Shackle Undead
		[3355]=true, -- Freezing Trap
		[19386]=true, -- Wyvern Sting
		[339]=true, -- Entangling Roots
		[2637]=true, -- Hibernate
		[6770]=true, -- Sap
		[6358]=true, -- Seduction (succubus)
		[20066]=true, -- Repentance
		[51514]=true, -- Hex
		[76780]=true, -- Bind Elemental
	}

	local function log_ccbreak(set, srcGUID, srcName)
		-- Fetch the player.
		local player = Skada:get_player(set, srcGUID, srcName)
		if player then
			-- Add to player count.
			player.ccbreaks = player.ccbreaks + 1

			-- Add to set count.
			set.ccbreaks = set.ccbreaks + 1
		end
	end

	local function SpellAuraBroken(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellId, spellName, spellSchool, auraType, extraSpellId, extraSpellName, extraSchool

		if eventtype == "SPELL_AURA_BROKEN" then
			spellId, spellName, spellSchool, auraType = ...
		else
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSchool, auraType = ...
		end

		if CCId[spellId] then

			-- Fix up pets.
			local petid = srcGUID
			local petname = srcName
			srcGUID, srcName = Skada:FixMyPets(srcGUID, srcName)

			-- Log CC break.
			log_ccbreak(Skada.current, srcGUID, srcName)
			log_ccbreak(Skada.total, srcGUID, srcName)

			-- Optional announce
			local inInstance, instanceType = IsInInstance()
			if Skada.db.profile.modules.ccannounce and IsInRaid() and UnitInRaid(srcName) and not (instanceType == "pvp") then

				-- Ignore main tanks?
				if Skada.db.profile.modules.ccignoremaintanks then

					-- Loop through our raid and return if src is a main tank.
					for i = 1, MAX_RAID_MEMBERS do
						local name, _, _, _, _, class, _, _, _, role, _ = GetRaidRosterInfo(i)
						if name == srcName and role == "maintank" then
							return
						end
					end

				end

				-- Prettify pets.
				if petid ~= srcGUID then
					srcName = petname.." ("..srcName..")"
				end

				-- Go ahead and announce it.
				if extraSpellName then
					local spellLink = GetSpellLink(extraSpellId)
					SendChatMessage(string.format(L["%s on %s removed by %s's %s"], spellName, dstName, srcName, spellLink), "RAID")
				else
					SendChatMessage(string.format(L["%s on %s removed by %s"], spellName, dstName, srcName), "RAID")
				end

			end

		end
	end

	function mod:OnEnable()
		mod.metadata = {showspots = true, icon = "Interface\\Icons\\Spell_magic_polymorphrabbit"}

		Skada:RegisterForCL(SpellAuraBroken, 'SPELL_AURA_BROKEN', {src_is_interesting = true})
		Skada:RegisterForCL(SpellAuraBroken, 'SPELL_AURA_BROKEN_SPELL', {src_is_interesting = true})

		Skada:AddMode(self)
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	function mod:AddToTooltip(set, tooltip)
		GameTooltip:AddDoubleLine(L["CC breaks"], set.ccbreaks, 1,1,1)
	end

	function mod:GetSetSummary(set)
		return set.ccbreaks
	end

	-- Called by Skada when a new player is added to a set.
	function mod:AddPlayerAttributes(player)
		if not player.ccbreaks then
			player.ccbreaks = 0
		end
	end

	-- Called by Skada when a new set is created.
	function mod:AddSetAttributes(set)
		if not set.ccbreaks then
			set.ccbreaks = 0
		end
	end

	function mod:Update(win, set)
		local max = 0
		local nr = 1
		for i, player in ipairs(set.players) do
			if player.ccbreaks > 0 then

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.value = player.ccbreaks
				d.label = player.name
				d.valuetext = tostring(player.ccbreaks)
				d.id = player.id
				d.class = player.class
				d.role = player.role
				if player.ccbreaks > max then
					max = player.ccbreaks
				end

				nr = nr + 1
			end
		end

		win.metadata.maxvalue = max
	end

	local opts = {
		ccoptions = {
			type="group",
			name=L["CC"],
			args={

				announce = {
					type = "toggle",
					name = L["Announce CC breaking to party"],
					get = function() return Skada.db.profile.modules.ccannounce end,
					set = function() Skada.db.profile.modules.ccannounce = not Skada.db.profile.modules.ccannounce end,
					order=1,
				},

				ignoremaintanks = {
					type = "toggle",
					name = L["Ignore Main Tanks"],
					get = function() return Skada.db.profile.modules.ccignoremaintanks end,
					set = function() Skada.db.profile.modules.ccignoremaintanks = not Skada.db.profile.modules.ccignoremaintanks end,
					order=2,
				},

			},
		}
	}

	function mod:OnInitialize()
		-- Add our options.
		table.insert(Skada.options.plugins, opts)
	end
end)

