Skada:AddLoadableModule("Overhealing", nil, function(Skada, L)
	if Skada.db.profile.modulesBlocked.Overhealing then return end

	local mod = Skada:NewModule(L["Overhealing"])
	local spellsmod = Skada:NewModule(L["Overhealing spells"])
    mod.metadata = {showspots = true, click1 = spellsmod, columns = {Overheal = true, Percent = true}, icon = "Interface\\Icons\\Ability_paladin_infusionoflight"}
    spellsmod.metadata	= {columns = {Healing = true, Percent = true}}

	function mod:OnEnable()
		Skada:AddMode(self, L["Healing"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	-- Called by Skada when a new player is added to a set.
	function mod:AddPlayerAttributes(player)
		if not player.overhealing then
			player.overhealing = 0
		end
	end

	-- Called by Skada when a new set is created.
	function mod:AddSetAttributes(set)
		if not set.overhealing then
			set.overhealing = 0
		end
	end

	function mod:GetSetSummary(set)
		return Skada:FormatNumber(set.overhealing)
	end

	function mod:Update(win, set)
		local nr = 1
		local max = 0

		for i, player in ipairs(set.players) do
			if player.overhealing > 0 then

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = player.id
				d.value = player.overhealing
				d.label = player.name

				d.valuetext = Skada:FormatValueText(
												Skada:FormatNumber(player.overhealing), self.metadata.columns.Overheal,
												string.format("%02.1f%%", player.overhealing / math.max(1, player.healing) * 100), self.metadata.columns.Percent
											)
				d.class = player.class
				d.role = player.role

				if player.overhealing > max then
					max = player.overhealing
				end
				nr = nr + 1
			end
		end

		win.metadata.maxvalue = max
	end
        
	function spellsmod:Enter(win, id, label)
		spellsmod.playerid = id
		spellsmod.title = label..L["'s Healing"]
	end

	-- Spell view of a player.
	function spellsmod:Update(win, set)
		-- View spells for this player.

		local player = Skada:find_player(set, self.playerid)
		local nr = 1
		local max = 0

		if player then
			for spellname, spell in pairs(player.healingspells) do
				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = spell.name -- ticket 362: this needs to be spellname because spellid is not unique with pets that mirror abilities (DK DRW)
				d.label = spell.name
				d.value = spell.overhealing
				d.valuetext = Skada:FormatValueText(
												Skada:FormatNumber(spell.overhealing), self.metadata.columns.Healing,
												string.format("%02.1f%%", spell.overhealing / player.overhealing * 100), self.metadata.columns.Percent
											)
				local _, _, icon = GetSpellInfo(spell.id)
				d.icon = icon
				d.spellid = spell.id

				if spell.overhealing > max then
					max = spell.overhealing
				end

				nr = nr + 1
			end
		end

		win.metadata.hasicon = true
		win.metadata.maxvalue = max
	end        
        
end)

