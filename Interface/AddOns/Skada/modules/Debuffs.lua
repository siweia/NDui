Skada:AddLoadableModule("Debuffs", nil, function(Skada, L)
	if Skada.db.profile.modulesBlocked.Debuffs then return end

	local debuffoverview = Skada:NewModule(L["Debuffs"])
	local buffoverview = Skada:NewModule(L["Buffs"])
	local buffplayers = Skada:NewModule("Buff players")
	local debuffplayers = Skada:NewModule("Debuff players")
        
	local mod = Skada:NewModule(L["Debuff uptimes"])
	local auramod = Skada:NewModule(L["Debuff spell list"])

	local buffs = Skada:NewModule(L["Buff uptimes"])
	local buffspells = Skada:NewModule(L["Buff spell list"])
        
    local pairs, ipairs = pairs, ipairs
    local time = time
        
	local function log_auraapply(set, aura)
		if set then

			-- Get the player.
			local player = Skada:get_player(set, aura.playerid, aura.playername)
			if player then
				--Skada:Print("applied "..aura.spellname.. " to "..player.name.. " - "..aura.auratype)
				-- Add aura to player if it does not exist.
				-- If it does exist, increment our counter of active instances by 1
				if not player.auras[aura.spellname] then
					player.auras[aura.spellname] = {["id"] = aura.spellid, ["name"] = aura.spellname, ["active"] = 1, ["uptime"] = 0, ["auratype"] = aura.auratype, ["started"] = time(), school = aura.spellschool}
				else
					player.auras[aura.spellname].active = player.auras[aura.spellname].active + 1
                    player.auras[aura.spellname].started = player.auras[aura.spellname].started or time()
				end
			end

		end
	end

	local function log_auraremove(set, aura)
		if set then

			-- Get the player.
			local player = Skada:get_player(set, aura.playerid, aura.playername)
			if player then
				--Skada:Print("removed "..aura.spellname.. " to "..player.name.. " - "..aura.auraType)
				-- If aura does not exist, we know nothing about it and ignore it.
				-- If it does exist and we know of 1 or more active instances, subtract 1 from our counter.
				if player.auras[aura.spellname] then
					local a = player.auras[aura.spellname]
					if a.active > 0 then
						a.active = a.active - 1
                        
                        if a.active == 0 and a.started then
                            -- Calculate aura uptime
                            a.uptime = a.uptime + math.floor((time() - a.started) + 0.5)
                            
                            -- Clear aura start value
                            a.started = nil
                        end
					end
				end
			end

		end
	end

	local aura = {}

	local function AuraApplied(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellId, spellName, spellSchool, auraType = ...
		aura.playerid = srcGUID
		aura.playername = srcName
		aura.spellid = spellId
		aura.spellname = spellName
		aura.auratype = auraType
        aura.spellschool = spellSchool

		Skada:FixPets(aura)
		log_auraapply(Skada.current, aura)
		log_auraapply(Skada.total, aura)
	end

	local function AuraRemoved(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		local spellId, spellName, spellSchool, auraType = ...
		aura.playerid = srcGUID
		aura.playername = srcName
		aura.spellid = spellId
		aura.spellname = spellName
		aura.auratype = auraType
        aura.spellschool = spellSchool

		Skada:FixPets(aura)
		log_auraremove(Skada.current, aura)
		log_auraremove(Skada.total, aura)
	end

	-- handle weapon-procced self-buffs that show with a null source
	-- 5/17 02:58:15.156 SPELL_AURA_APPLIED,0x0000000000000000,nil,0x4228,0x0,0x0180000005F37DDE,"Grimbit",0x511,0x0,104993,"Jade Spirit",0x2,BUFF
	local function NullAura(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		if srcName == nil and #srcGUID == 0 and dstName and #dstGUID > 0 then
			--print(eventtype, ...)
			srcName = dstName
			srcGUID = dstGUID
			srcFlags = dstFlags

			if eventtype == 'SPELL_AURA_APPLIED' then
				AuraApplied(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
			else
				AuraRemoved(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
			end
		end
	end

	local function len(t)
		local l = 0
		for i,j in pairs(t) do
			l = l + 1
		end
		return l
	end

	local function spellupdate(auratype, win, set)
		local nr = 1
		local max = 0
        local spells = {}

		for i, player in ipairs(set.players) do
			-- Find number of debuffs.
			local auracount = 0
			local aurauptime = 0
			for spellname, spell in pairs(player.auras) do
				if spell.auratype == auratype then
                        
                    local spellnr = spells[spell.id]
                    local was_new = false
                    if not spellnr then
                        was_new = true
                        spells[spell.id] = nr
                        nr = nr + 1
                        spellnr = spells[spell.id]
                    end
                        
                    local d = win.dataset[spellnr] or {}
                    win.dataset[spellnr] = d

                    d.id = spell.id
                    if was_new then
                        d.value = 1
                    else
                        d.value = (d.value or 0) + 1
                    end
                    d.valuetext = ("%i"):format(d.value)
                    d.label = spellname
                    d.spellid = spell.id
                        
                    local _, _, icon = GetSpellInfo(spell.id)
                    d.icon = icon
                        
                    if spell.school then
                        d.spellschool = spell.school
                    end
                        
                    if d.value > max then
                        max = d.value
                    end

				end
                        
			end
		end

		win.metadata.maxvalue = max
	end        
    
    local auraspellid = nil
        
	local function spellplayersupdate(auratype, win, set)
		local nr = 1
		local max = 0

		for i, player in ipairs(set.players) do
			for spellname, spell in pairs(player.auras) do
				if spell.auratype == auratype and spell.id == auraspellid then
					local aurauptime = spell.uptime
                        
                    -- Account for active auras
                    if spell.active > 0 and spell.started then
                        aurauptime = aurauptime + math.floor((time() - spell.started) + 0.5)
                    end
                        
                    -- Calculate player max possible uptime.
                    local maxtime = Skada:PlayerActiveTime(set, player)

                    local d = win.dataset[nr] or {}
                    win.dataset[nr] = d

                    d.id = player.id
                    d.value = aurauptime
                    d.valuetext = ("%02.1f%%"):format(aurauptime / maxtime * 100)
                    d.label = player.name
                    d.class = player.class
                    d.role = player.role

                    if aurauptime > max then
                        max = aurauptime
                    end

                    nr = nr + 1
                end
			end
		end

		win.metadata.maxvalue = max
	end        
        
        
	local function updatefunc(auratype, win, set)
		local nr = 1
		local max = 0

		for i, player in ipairs(set.players) do
			-- Find number of debuffs.
			local auracount = 0
			local aurauptime = 0
			for spellname, spell in pairs(player.auras) do
				if spell.auratype == auratype then
					auracount = auracount + 1
					aurauptime = aurauptime + spell.uptime
                        
                    -- Account for active auras
                    if spell.active > 0 and spell.started then
                        aurauptime = aurauptime + math.floor((time() - spell.started) + 0.5)
                    end
				end
			end

			if auracount > 0 then
				-- Calculate player max possible uptime.
				local maxtime = Skada:PlayerActiveTime(set, player)

				-- Now divide by the number of spells to get the average uptime.
				local uptime = min(maxtime, aurauptime / auracount)

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d
                    
				d.id = player.id
				d.value = uptime
				d.valuetext = ("%02.1f%% / %u"):format(uptime / maxtime * 100, auracount)
				d.label = player.name
				d.class = player.class
				d.role = player.role

				if uptime > max then
					max = uptime
				end

				nr = nr + 1
			end
		end

		win.metadata.maxvalue = max
	end

	-- Detail view of a player.
	local function detailupdatefunc(auratype, win, set, playerid)
		-- View spells for this player.
		local nr = 1
		local max = 0
		local player = Skada:find_player(set, playerid)

		if player then
			-- Calculate player max possible uptime.
			local maxtime = Skada:PlayerActiveTime(set, player)

            if maxtime and maxtime > 0 then
                win.metadata.maxvalue = maxtime
                for spellname, spell in pairs(player.auras) do
                    if spell.auratype == auratype then
                        local uptime = min(maxtime, spell.uptime)
                            
                        -- Account for active auras
                        if spell.active > 0 and spell.started then
                            uptime = uptime + math.floor((time() - spell.started) + 0.5)
                        end

                        local d = win.dataset[nr] or {}
                        win.dataset[nr] = d

                        d.id = spell.name
                        d.value = uptime
                        d.label = spell.name
                        local _, _, icon = GetSpellInfo(spell.id)
                        d.icon = icon
                        d.spellid = spell.id
                        d.valuetext = ("%02.1f%%"):format(uptime / maxtime * 100)

                        nr = nr + 1
                    end
                end
            end
		end

	end

	function mod:Update(win, set)
		updatefunc("DEBUFF", win, set)
	end

	function auramod:Enter(win, id, label)
		auramod.playerid = id
		auramod.title = label..L["'s Debuffs"]
	end

	function auramod:Update(win, set)
		detailupdatefunc("DEBUFF", win, set, self.playerid)
	end

	function buffs:Update(win, set)
		updatefunc("BUFF", win, set)
	end

	function buffspells:Enter(win, id, label)
		buffspells.playerid = id
		buffspells.title = label..L["'s Buffs"]
	end

	-- Detail view of a player.
	function buffspells:Update(win, set)
		detailupdatefunc("BUFF", win, set, self.playerid)
	end
        
	-- Detail view of a player.
	function buffspells:Update(win, set)
		detailupdatefunc("BUFF", win, set, self.playerid)
	end

	function buffoverview:Update(win, set)
		spellupdate("BUFF", win, set)
	end
        
	function debuffoverview:Update(win, set)
		spellupdate("DEBUFF", win, set)
	end
        
	function debuffplayers:Update(win, set)
		spellplayersupdate("DEBUFF", win, set)
	end
        
	function buffplayers:Update(win, set)
		spellplayersupdate("BUFF", win, set)
	end
        
	function debuffplayers:Enter(win, id, label)
		auraspellid = id
		debuffplayers.title = label
	end
        
	function buffplayers:Enter(win, id, label)
		auraspellid = id
		buffplayers.title = label
	end
        
	function mod:OnEnable()
		mod.metadata 		= {showspots = 1, click1 = auramod, click2 = buffspells, icon = "Interface\\Icons\\Ability_creature_disease_02"}
		auramod.metadata 	= {}
		buffs.metadata 		= {showspots = 1, click1 = buffspells, click2 = auramod, icon = "Interface\\Icons\\Spell_misc_drink"}
		buffspells.metadata = {}
		buffoverview.metadata 		= {click1 = buffplayers, icon = "Interface\\Icons\\Spell_misc_drink"}
		debuffoverview.metadata 	= {click1 = debuffplayers, icon = "Interface\\Icons\\Ability_creature_disease_02"}
		debuffplayers.metadata = {showspots = 1}
		buffplayers.metadata = {showspots = 1}

		Skada:RegisterForCL(AuraApplied, 'SPELL_AURA_APPLIED', {src_is_interesting = true})
		Skada:RegisterForCL(AuraRemoved, 'SPELL_AURA_REMOVED', {src_is_interesting = true})

		-- ticket 307: some weapon-procced self buffs (eg Jade Spirit) have a null src
		Skada:RegisterForCL(NullAura, 'SPELL_AURA_APPLIED', {dst_is_interesting_nopets = true, src_is_not_interesting = true})
		Skada:RegisterForCL(NullAura, 'SPELL_AURA_REMOVED', {dst_is_interesting_nopets = true, src_is_not_interesting = true})

		Skada:AddMode(self)
		Skada:AddMode(buffs)
		Skada:AddMode(buffoverview)
		Skada:AddMode(debuffoverview)
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
		Skada:RemoveMode(buffs)
	end

    function mod:SetComplete(set)
        -- Finalize any remaining auras
		for i, player in ipairs(set.players) do
			for spellname, spell in pairs(player.auras) do
				if spell.active > 0 and spell.started then
                    spell.uptime = spell.uptime + math.floor((time() - spell.started) + 0.5)
                    spell.active = 0
                    spell.started = nil
				end
			end
		end
    end
        
	function mod:AddToTooltip(set, tooltip)
	end

	-- Called by Skada when a new player is added to a set.
	function mod:AddPlayerAttributes(player)
		if not player.auras then
			player.auras = {}
		end
	end

	-- Called by Skada when a new set is created.
	function mod:AddSetAttributes(set)
        set.auras = {}
        
        -- Account for old Total segments
		for i, player in ipairs(set.players) do
            if player.auras ~= nil then
                for spellname, spell in pairs(player.auras) do
                    if spell.active > 0 then
                        spell.active = 0
                        spell.started = nil
                    end
                end
            end
		end
	end
end)

