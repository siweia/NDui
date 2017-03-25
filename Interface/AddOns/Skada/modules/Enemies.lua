Skada:AddLoadableModule("Enemies", nil, function(Skada, L)
	if Skada.db.profile.modulesBlocked.Enemies then return end

	local done = Skada:NewModule(L["Enemy damage done"])
	local taken = Skada:NewModule(L["Enemy damage taken"])
	local hdone = Skada:NewModule(L["Enemy healing done"])
	local htaken = Skada:NewModule(L["Enemy healing taken"])
	local hdonespells = Skada:NewModule(L["Enemy healing done"]..": "..L["Healing spell list"])
	local htakenspells = Skada:NewModule(L["Enemy healing taken"]..": "..L["Healing spell list"])

	local doneplayers = Skada:NewModule(L["Damage done per player"])
	local takenplayers = Skada:NewModule(L["Damage taken per player"])

	local function find_player(mob, name)
		local player = mob.players[name]
		if player then return player end
		local _, playerClass = UnitClass(name)
        local playerRole = UnitGroupRolesAssigned(name)
		player = {done = 0, taken = 0, class = playerClass, role = playerRole}
		mob.players[name] = player
		return player
	end

	local function find_mob(set, name)
		local mob = set.mobs[name]
		if mob then return mob end
		mob = {taken = 0, done = 0, players = {}, htaken = 0, hdone = 0, hdonespell = {}, htakenspell = {}}
		set.mobs[name] = mob
		return mob
	end

	local function log_damage_taken(set, dmg)
		set.mobtaken = set.mobtaken + dmg.amount

		local mob = find_mob(set,dmg.dstName)

		mob.taken = mob.taken + dmg.amount

		local player = find_player(mob, dmg.srcName)
		player.taken = player.taken + dmg.amount
	end

	local function log_damage_done(set, dmg)
		set.mobdone = set.mobdone + dmg.amount

		local mob = find_mob(set,dmg.srcName)

		mob.done = mob.done + dmg.amount

		local player = find_player(mob, dmg.dstName)
		player.done = player.done + dmg.amount
	end

	local function log_healspell(mob, entry, spellname, healing, overheal, crit)
			local spell = mob[entry][spellname] or { hits = 0, crits = 0, healing = 0, overhealing = 0, min = nil, max = 0}
		mob[entry][spellname] = spell
		spell.hits = spell.hits + 1
		if crit then
		  spell.crits = spell.crits + 1
		end
		spell.healing = spell.healing + healing
		spell.overhealing = spell.overhealing + overheal
			if not spell.min or healing < spell.min then
			   spell.min = healing
			end
			if not spell.max or healing > spell.max then
			   spell.max = healing
			end
	end

	local function log_healing(set, dmg, ...)
		local spellid, spellname,_,amount,overheal,absorb,crit = ...
		local healing = math.max(0,amount - overheal) -- omit absorbs, which players inflict to mitigate healing
		set.mobhdone = set.mobhdone + healing

		if dmg.srcName then -- some enemy HoT's omit the true src (eg Cauterizing Bolt) 
			local smob = find_mob(set,dmg.srcName)
			smob.hdone = smob.hdone + healing
			log_healspell(smob, "hdonespell", spellname, healing, overheal, crit)
		end

		local dmob = find_mob(set,dmg.dstName)
		dmob.htaken = dmob.htaken + healing
		log_healspell(dmob, "htakenspell", spellname, healing, overheal, crit)
	end

	local dmg = {}

	local function Healing(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		if dstName then -- we allow missing src (for some enemy HoTs)
			dmg.dstName = dstName
			dmg.srcName = srcName
			log_healing(Skada.current, dmg, ...)
			log_healing(Skada.total, dmg, ...)
		end
	end

	local function SpellDamageTaken(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, amount)
		if srcName and dstName then
			srcGUID, srcName = Skada:FixMyPets(srcGUID, srcName)

			dmg.dstName = dstName
			dmg.srcName = srcName
			dmg.amount = amount

			log_damage_taken(Skada.current, dmg)
			log_damage_taken(Skada.total, dmg)
		end
	end

	local function SpellDamageDone(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, amount)
		if srcName and dstName then
			dmg.dstName = dstName
			dmg.srcName = srcName
			dmg.amount = amount

			log_damage_done(Skada.current, dmg)
			log_damage_done(Skada.total, dmg)
		end
	end

	local function SwingDamageTaken(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, amount)
		if srcName and dstName then
			srcGUID, srcName = Skada:FixMyPets(srcGUID, srcName)

			dmg.dstName = dstName
			dmg.srcName = srcName
			dmg.amount = amount

			log_damage_taken(Skada.current, dmg)
			log_damage_taken(Skada.total, dmg)
		end
	end

	local function SwingDamageDone(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, amount)
		if srcName and dstName then
			dmg.dstName = dstName
			dmg.srcName = srcName
			dmg.amount = amount

			log_damage_done(Skada.current, dmg)
			log_damage_done(Skada.total, dmg)
		end
	end

	-- Factored code for Enemy stat page - list mobs.
	local function MobUpdate(stat)
	return function (self, win, set)
		local nr = 1
		local max = 0

		for name, mob in pairs(set.mobs) do
			if (mob[stat] or 0) > 0 then
				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.value = mob[stat]
				d.id = name
				d.valuetext = Skada:FormatNumber(mob[stat])
				d.label = name

				if mob[stat] > max then
					max = mob[stat]
				end

				nr = nr + 1
			end
		end

		win.metadata.maxvalue = max
		  end
	end

	taken.Update =  MobUpdate("taken")
	done.Update =   MobUpdate("done")
	htaken.Update = MobUpdate("htaken")
	hdone.Update =  MobUpdate("hdone")


	function doneplayers:Enter(win, id, label)
		doneplayers.title = L["Damage from"].." "..label
		doneplayers.mob = label
	end

	function doneplayers:Update(win, set)
		local mob = self.mob and set.mobs[self.mob]
		if mob then
			local nr = 1
			local max = 0
			for name, player in pairs(mob.players) do
				if player.done > 0 then

					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = name
					d.label = name
					d.value = player.done
					d.valuetext = Skada:FormatNumber(player.done)..(" (%02.1f%%)"):format(player.done / mob.done * 100)
					d.class = player.class
                    d.role = player.role

					if player.done > max then
						max = player.done
					end

					nr = nr + 1
				end
			end

			win.metadata.maxvalue = max

		end
	end

	function takenplayers:Enter(win, id, label)
		takenplayers.title = L["Damage on"].." "..label
		takenplayers.mob = label
	end

	function takenplayers:Update(win, set)
		local mob = self.mob and set.mobs[self.mob]
		if mob then
			local nr = 1
			local max = 0

			for name, player in pairs(mob.players) do
				if player.taken > 0 then

					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = name
					d.label = name
					d.value = player.taken
					d.valuetext = Skada:FormatNumber(player.taken)..(" (%02.1f%%)"):format(player.taken / mob.taken * 100)
					d.class = player.class
                    d.role = player.role

					if player.taken > max then
						max = player.taken
					end

					nr = nr + 1
				end
			end

			win.metadata.maxvalue = max
		end
	end

	local ttmob, ttentry
	function hdonespells:Enter(win, id, label)
			self.title = L["Enemy healing done"]..": "..label
		self.mob = label
			ttmob = label
		ttentry = "hdonespell"
	end

	function htakenspells:Enter(win, id, label)
			self.title = L["Enemy healing taken"]..": "..label
		self.mob = label
			ttmob = label
		ttentry = "htakenspell"
	end

	local function SpellUpdate(entry)
	  return function (self, win, set)
		local mob = self.mob and set.mobs[self.mob]
		if mob then
			local nr = 1
			local max = 0

			for name, info in pairs(mob[entry]) do
				if info.hits > 0 then

					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = name
					d.label = name
					d.value = info.healing
					d.valuetext = Skada:FormatNumber(info.healing)..(" (%02.1f%%)"):format(info.healing / mob.hdone * 100)

					if info.healing > max then
						max = info.healing
					end

					nr = nr + 1
				end
			end

			win.metadata.maxvalue = max
		end
	  end
	end
	hdonespells.Update = SpellUpdate("hdonespell")
	htakenspells.Update = SpellUpdate("htakenspell")

	local function spell_tooltip(win, id, label, tooltip)
			local mob = find_mob(win:get_selected_set(), ttmob)
			if mob and ttentry then
					local spell = mob[ttentry][label]
					if spell and (spell.hits or 0) > 0 then
							tooltip:AddLine(ttmob.." - "..label)
							tooltip:AddDoubleLine(L["Hit"]..":", spell.hits, 255,255,255,255,255,255)
							if spell.max and spell.min then
									tooltip:AddDoubleLine(L["Minimum hit:"], Skada:FormatNumber(spell.min), 255,255,255,255,255,255)
									tooltip:AddDoubleLine(L["Maximum hit:"], Skada:FormatNumber(spell.max), 255,255,255,255,255,255)
							end
							tooltip:AddDoubleLine(L["Average hit:"], Skada:FormatNumber(spell.healing / spell.hits), 255,255,255,255,255,255)
							tooltip:AddDoubleLine(L["Critical"]..":", ("%02.1f%%"):format(spell.crits / spell.hits * 100), 255,255,255,255,255,255)
							tooltip:AddDoubleLine(L["Overhealing"]..":", ("%02.1f%%"):format(spell.overhealing / (spell.overhealing + spell.healing) * 100), 255,255,255,255,255,255)
					end
			end
	end


	function done:OnEnable()
		takenplayers.metadata 	= {showspots = true}
		doneplayers.metadata 	= {showspots = true}
		done.metadata 			= {click1 = doneplayers, icon = "Interface\\Icons\\Inv_misc_monsterclaw_01"}
		taken.metadata 			= {click1 = takenplayers, icon = "Interface\\Icons\\Inv_shield_08"}

		Skada:RegisterForCL(SpellDamageTaken, 'SPELL_DAMAGE', {src_is_interesting = true, dst_is_not_interesting = true})
		Skada:RegisterForCL(SpellDamageTaken, 'SPELL_PERIODIC_DAMAGE', {src_is_interesting = true, dst_is_not_interesting = true})
		Skada:RegisterForCL(SpellDamageTaken, 'SPELL_BUILDING_DAMAGE', {src_is_interesting = true, dst_is_not_interesting = true})
		Skada:RegisterForCL(SpellDamageTaken, 'RANGE_DAMAGE', {src_is_interesting = true, dst_is_not_interesting = true})
		Skada:RegisterForCL(SwingDamageTaken, 'SWING_DAMAGE', {src_is_interesting = true, dst_is_not_interesting = true})

		Skada:RegisterForCL(SpellDamageDone, 'SPELL_DAMAGE', {dst_is_interesting_nopets = true, src_is_not_interesting = true})
		Skada:RegisterForCL(SpellDamageDone, 'SPELL_PERIODIC_DAMAGE', {dst_is_interesting_nopets = true, src_is_not_interesting = true})
		Skada:RegisterForCL(SpellDamageDone, 'SPELL_BUILDING_DAMAGE', {dst_is_interesting_nopets = true, src_is_not_interesting = true})
		Skada:RegisterForCL(SpellDamageDone, 'RANGE_DAMAGE', {dst_is_interesting_nopets = true, src_is_not_interesting = true})
		Skada:RegisterForCL(SwingDamageDone, 'SWING_DAMAGE', {dst_is_interesting_nopets = true, src_is_not_interesting = true})

		Skada:AddMode(self, L["Damage"])
	end

	function done:OnDisable()
		Skada:RemoveMode(self)
	end

	function taken:OnEnable()
		Skada:AddMode(self, L["Damage"])
	end

	function taken:OnDisable()
		Skada:RemoveMode(self)
	end

	function hdone:OnEnable()
		hdonespells.metadata 	= {showspots = true, tooltip = spell_tooltip}
		htakenspells.metadata 	= {showspots = true, tooltip = spell_tooltip}
		hdone.metadata		= {click1 = hdonespells, icon = "Interface\\Icons\\Inv_misc_bandage_12"}
		htaken.metadata		= {click1 = htakenspells, icon = "Interface\\Icons\\Spell_misc_emotionhappy"}

		Skada:RegisterForCL(Healing, 'SPELL_HEAL', {dst_is_not_interesting = true})
		Skada:RegisterForCL(Healing, 'SPELL_PERIODIC_HEAL', {dst_is_not_interesting = true})
		Skada:RegisterForCL(Healing, 'SPELL_BUILDING_HEAL', {dst_is_not_interesting = true})

		Skada:AddMode(self, L["Healing"])
	end

	function hdone:OnDisable()
		Skada:RemoveMode(self)
	end

	function htaken:OnEnable()
		Skada:AddMode(self, L["Healing"])
	end

	function htaken:OnDisable()
		Skada:RemoveMode(self)
	end

	function done:GetSetSummary(set)
		return Skada:FormatNumber(set.mobdone)
	end

	function taken:GetSetSummary(set)
		return Skada:FormatNumber(set.mobtaken)
	end

	function hdone:GetSetSummary(set)
		return Skada:FormatNumber(set.mobhdone)
	end

	function htaken:GetSetSummary(set)
		return Skada:FormatNumber(set.mobhdone)
	end

	-- Called by Skada when a new set is created.
	function done:AddSetAttributes(set)
		if not set.mobs then
			set.mobs = {}
			set.mobdone = 0
			set.mobtaken = 0
		end
		if not set.mobhdone then
			set.mobhdone = 0
		end
	end
end)

