Skada:AddLoadableModule("TotalHealing", nil, function(Skada, L)
	if Skada.db.profile.modulesBlocked.TotalHealing then return end

	local mod = Skada:NewModule(L["Total healing"])
    local thspellsmod = Skada:NewModule(L["Total"].." "..L["Healing spell list"])

    local function getRawHeals(player)
            return (player.healing+player.overhealing)
    end

    local function getRawHPS(set, player)
            local totaltime = Skada:PlayerActiveTime(set, player)
            return getRawHeals(player) / math.max(1,totaltime)
    end
        
        
	-- Called by Skada when a new player is added to a set.
	function mod:AddPlayerAttributes(player)
	end

	-- Called by Skada when a new set is created.
	function mod:AddSetAttributes(set)
	end

	function mod:GetSetSummary(set)
		return Skada:FormatNumber(set.healing + set.overhealing)
	end

	local function sort_by_healing(a, b)
		return a.healing > b.healing
	end

	local green = {r = 0, g = 255, b = 0, a = 1}
	local red = {r = 255, g = 0, b = 0, a = 1}

	function mod:Update(win, set)
		-- Calculate the highest total healing.
		-- How to get rid of this iteration?
		local maxvalue = 0
		for i, player in ipairs(set.players) do
			if player.healing + player.overhealing > maxvalue then
				maxvalue = player.healing + player.overhealing
			end
		end

		local nr = 1

		for i, player in ipairs(set.players) do
			if player.healing > 0 or player.overhealing > 0 then

				local mypercentoverhealed = (player.overhealing) / maxvalue
				local mypercent = (player.healing + player.overhealing) / maxvalue
                local percentformatted=(string.format("%02.1f%%", mypercent))
                local totaltime = Skada:PlayerActiveTime(set, player)
                local hps = (player.healing + player.overhealing) / math.max(1,totaltime)

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = player.id
				d.value = player.healing
				d.label = player.name
--				d.valuetext = Skada:FormatNumber(player.healing).." / "..Skada:FormatNumber(player.overhealing)
				d.valuetext = Skada:FormatValueText(
                                        Skada:FormatNumber(player.healing), self.metadata.columns.Healing,
                                        Skada:FormatNumber(player.healing + player.overhealing), self.metadata.columns.Total,
                                        percentformatted, self.metadata.columns.Percent
					)
                    
                d.color = green
				d.backgroundcolor = red
				d.backgroundwidth = mypercent
				d.class = player.class
                d.role = player.role

				nr = nr + 1
			end
		end

		win.metadata.maxvalue = maxvalue
	end
        
        local function thspell_tooltip(win, id, label, tooltip)
                local player = Skada:find_player(win:get_selected_set(), thspellsmod.playerid)
                if player then
                        local spell = player. healingspells[label]
                        if spell then
                                tooltip:AddLine(player.name.." - "..label)
                                if spell.max and spell.min then
                                        tooltip:AddDoubleLine(L["Minimum hit:"], Skada:FormatNumber(spell.min), 255,255,255,255,255,255)
                                        tooltip:AddDoubleLine(L["Maximum hit:"], Skada:FormatNumber(spell.max), 255,255,255,255,255,255)
                                end
                                tooltip:AddDoubleLine(L["Average hit:"], Skada:FormatNumber(spell.healing / spell.hits), 255,255,255,255,255,255)
				if spell.hits then
					tooltip:AddDoubleLine(L["Critical"]..":", ("%02.1f%%"):format(spell.critical / spell.hits * 100), 255,255,255,255,255,255)
				end
				if spell.hits then
					tooltip:AddDoubleLine(L["Overhealing"]..":", ("%02.1f%%"):format(spell.overhealing / (spell.overhealing + spell.healing) * 100), 255,255,255,255,255,255)
				end
				if spell.hits and spell.absorbed then
					tooltip:AddDoubleLine(L["Absorbed"]..":", ("%02.1f%%"):format(spell.absorbed / (spell.overhealing + spell.healing) * 100), 255,255,255,255,255,255)
				end
			end
		end
	end

	function thspellsmod:Enter(win, id, label)
		thspellsmod.playerid = id
		thspellsmod.title = label..L["'s "].." "..L["Total healing"]
	end

	function thspellsmod:Update(win, set)

		local player = Skada:find_player(set, self.playerid)
		local nr = 1
		local max = 0

		if player then
			for spellname, spell in pairs(player.healingspells) do
				local d = win.dataset[nr] or {}
				win.dataset[nr] = d
				local srh = spell.healing + spell.overhealing
				d.id = spell.name
				d.label = spell.name
				d.value = srh
				d.valuetext = Skada:FormatValueText(
												Skada:FormatNumber(srh), self.metadata.columns.Healing,
												string.format("%02.1f%%", srh / (player.healing+player.overhealing) * 100), self.metadata.columns.Percent
											)
				local _, _, icon = GetSpellInfo(spell.id)
				d.icon = icon
				d.spellid = spell.id

				if spell.healing > max then
					max = srh
				end

				nr = nr + 1
			end
		end

		win.metadata.hasicon = true
		win.metadata.maxvalue = max
	end        

	function mod:OnEnable()
		mod.metadata = {click1 = thspellsmod, showspots = true, columns = {Healing = true, Total = true, Percent = false}, icon = "Interface\\Icons\\Ability_priest_angelicbulwark"}
		thspellsmod.metadata = {tooltip = thspell_tooltip, columns = {Healing = true, Percent = true}}

		Skada:AddMode(self, L["Healing"])
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end
end)

