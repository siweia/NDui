-- Various silly tweaks needed to keep up with Blizzard's shenanigans. Not added to core because they may not be needed/relevant forever.
Skada:AddLoadableModule("Tweaks", "Various tweaks to get around deficiences and problems in the game's combat logs. Carries a small performance penalty.", function(Skada, L)
    if Skada.db.profile.modulesBlocked.Tweaks then return end

    local band = bit.band

    -- Cache variables
    local stormlashes = {}
    local lastpet = {}
    local assignedhatis = {}

    local PET_FLAG = COMBATLOG_OBJECT_TYPE_PET
    local MINE_FLAG = COMBATLOG_OBJECT_AFFILIATION_MINE

    local orig = Skada.cleuHandler
    local function cleuHandler(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
        -- Only perform these modifications if we are already in combat
        if Skada.current then
            local firstArg = ...

            -- Hati (7.0, BM Hunter artifact)
            if band(srcFlags, PET_FLAG) ~= 0 then
                lastpet.timestamp = timestamp
                lastpet.srcGUID = srcGUID
            elseif srcName == 'Hati' and not assignedhatis[srcGUID] then
                if lastpet.timestamp == timestamp then
                    local owner = Skada:GetPetOwner(lastpet.srcGUID)
                    if owner then
                        Skada:AssignPet(owner.id, owner.name, srcGUID)
                        assignedhatis[srcGUID] = true
                    end
                end
            end

            -- Akaari's Soul (7.0, Sub Rogue artifact)
            if firstArg == 220893 and band(srcFlags, MINE_FLAG) ~= 0 then
                srcGUID = UnitGUID("player")
                srcName = UnitName("player")
                srcFlags = 0x517 -- COMBATLOG_FILTER_ME + party + raid
            end

            -- Stormlash (7.0, Enh Shaman)
            if firstArg == 195256 and eventtype == 'SPELL_DAMAGE' then
                --Skada:Print('Ooh, caught a Stormlash!')
                local source = stormlashes[srcGUID]
                if source ~= nil then
                    srcGUID = source.id
                    srcName = source.name
                end
            end

            if firstArg == 195222 then
                if eventtype == 'SPELL_AURA_APPLIED' and srcGUID ~= dstGUID then
                    --Skada:Print('New Stormlash source: '..srcGUID..' - '..srcName)
                    stormlashes[dstGUID] = {
                        id = srcGUID,
                        name = srcName
                    }
                end

                if eventtype == 'SPELL_AURA_REMOVED' then
                    --Skada:Print('Removed Stormlash source')
                    stormlashes[dstGUID] = nil
                end
            end

        end

        orig(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
    end

    Skada.cleuFrame:SetScript("OnEvent", function()
        cleuHandler(CombatLogGetCurrentEventInfo())
    end)
end)
