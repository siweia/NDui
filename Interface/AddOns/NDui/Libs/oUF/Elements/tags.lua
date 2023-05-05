-- Credits: Vika, Cladhaire, Tekkub
--[[
# Element: Tags

Provides a system for text-based display of information by binding a tag string to a font string widget which in turn is
tied to a unit frame.

## Widget

A FontString to hold a tag string. Unlike other elements, this widget must not have a preset name.

## Notes

A `Tag` is a Lua string consisting of a function name surrounded by square brackets. The tag will be replaced by the
output of the function and displayed as text on the font string widget with that the tag has been registered.

A `Tag String` is a Lua string consisting of one or multiple tags with optional literals and parameters around them.
Each tag will be updated individually and the output will follow the tags order. Literals will be displayed in the
output string regardless of whether the surrounding tag functions return a value. I.e. `"[curhp]/[maxhp]"` will resolve
to something like `2453/5000`.

There's also an optional prefix and suffix that are separated from the tag name by `$>` and `<$` respectively,
for example, `"[==$>name<$==]"` will resolve to `==Thrall==`, and `"[perhp<$%]"` will resole to `100%`, however, said
affixes will only be added if the tag function returns a non-empty string, if it returns `nil` or `""` affixes will be
omitted.

Additionally, it's possible to pass optional arguments to a tag function to alter its behaviour. Optional arguments are
defined via `()` at the end of a tag and separated by commas (`,`). For example, `"[name(a,r,g,s)]"`, in this case 4
additional arguments, `"a"`, `"r"`, `"g"`, and `"s"` will be passed to the name tag function, what to do with them,
however, is up to a developer to decide.

The full tag syntax looks like this: `"[prefix$>tag<$suffix(a,r,g,s)]"`. The order of optional elements is important,
while they can be independently omitted, they can't be reordered.

A `Tag Function` is used to replace a single tag in a tag string by its output. A tag function receives only two
arguments - the unit and the realUnit of the unit frame used to register the tag (see Options for further details). The
tag function is called when the unit frame is shown or when a specified event has fired. It the tag is registered on an
eventless frame (i.e. one holding the unit "targettarget"), then the tag function is called in a set time interval.

A number of built-in tag functions exist. The layout can also define its own tag functions by adding them to the
`oUF.Tags.Methods` table. The events upon which the function will be called are specified in a white-space separated
list added to the `oUF.Tags.Events` table. Should an event fire without unit information, then it should also be listed
in the `oUF.Tags.SharedEvents` table as follows: `oUF.Tags.SharedEvents.EVENT_NAME = true`.

## Options

.overrideUnit    - if specified on the font string widget, the frame's realUnit will be passed as the second argument to
                   every tag function whose name is contained in the relevant tag string. Otherwise the second argument
                   is always nil (boolean)
.frequentUpdates - defines how often the corresponding tag function(s) should be called. This will override the events
                   for the tag(s), if any. If the value is a number, it is taken as a time interval in seconds. If the
                   value is a boolean, the time interval is set to 0.5 seconds (number or boolean)

## Attributes

.parent - the unit frame on which the tag has been registered

## Examples

### Example 1

    -- define the tag function
    oUF.Tags.Methods['mylayout:threatname'] = function(unit, realUnit)
        local color = _TAGS['threatcolor'](unit)
        local name = _TAGS['name'](unit, realUnit)
        return string.format('%s%s|r', color, name)
    end

    -- add the events
    oUF.Tags.Events['mylayout:threatname'] = 'UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE'

    -- create the text widget
    local info = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    info:SetPoint('LEFT')

    -- register the tag on the text widget with oUF
    self:Tag(info, '[mylayout:threatname]')

### Example 2

    -- define the tag function that accepts optional arguments
    oUF.Tags.Methods['mylayout:name'] = function(unit, realUnit, ...)
        local name = _TAGS['name'](unit, realUnit)
        local length = tonumber(...)
        if(length) then
            return name:sub(1, length) -- please note, this code doesn't support UTF-8 chars
        else
            return name
        end
    end

    -- add the events
    oUF.Tags.Events['mylayout:name'] = 'UNIT_NAME_UPDATE'

    -- create the text widget
    local info = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    info:SetPoint('LEFT')

    -- register the tag on the text widget with oUF
    self:Tag(info, '[mylayout:name(5)]') -- the output will be shortened to 5 characters
    -- self:Tag(info, '[mylayout:name]') -- alternative, the output won't be adjusted
    -- self:Tag(info, '[mylayout:name(10)]') -- alternative, the output will be shortened to 10 characters
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local nierror = Private.nierror
local unitExists = Private.unitExists
local validateEvent = Private.validateEvent

local _PATTERN = '%[..-%]+'

local _ENV = {
	Hex = function(r, g, b)
		if(type(r) == 'table') then
			if(r.r) then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end
		return string.format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
	end,
}
_ENV.ColorGradient = function(...)
	return _ENV._FRAME:ColorGradient(...)
end

local _PROXY = setmetatable(_ENV, {__index = _G})

local tagStrings = {
	['affix'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'minus') then
			return 'Affix'
		end
	end]],

	['arcanecharges'] = [[function()
		if(GetSpecialization() == SPEC_MAGE_ARCANE) then
			local num = UnitPower('player', Enum.PowerType.ArcaneCharges)
			if(num > 0) then
				return num
			end
		end
	end]],

	['arenaspec'] = [[function(u)
		local id = u:match('arena(%d)$')
		if(id) then
			local specID = GetArenaOpponentSpec(tonumber(id))
			if(specID and specID > 0) then
				local _, specName = GetSpecializationInfoByID(specID)
				return specName
			end
		end
	end]],

	['chi'] = [[function()
		if(GetSpecialization() == SPEC_MONK_WINDWALKER) then
			local num = UnitPower('player', Enum.PowerType.Chi)
			if(num > 0) then
				return num
			end
		end
	end]],

	['classification'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'rare') then
			return 'Rare'
		elseif(c == 'rareelite') then
			return 'Rare Elite'
		elseif(c == 'elite') then
			return 'Elite'
		elseif(c == 'worldboss') then
			return 'Boss'
		elseif(c == 'minus') then
			return 'Affix'
		end
	end]],

	['cpoints'] = [[function(u)
		local cp = UnitPower(u, Enum.PowerType.ComboPoints)

		if(cp > 0) then
			return cp
		end
	end]],

	['creature'] = [[function(u)
		return UnitCreatureFamily(u) or UnitCreatureType(u)
	end]],

	['curmana'] = [[function(unit)
		return UnitPower(unit, Enum.PowerType.Mana)
	end]],

	['dead'] = [[function(u)
		if(UnitIsDead(u)) then
			return 'Dead'
		elseif(UnitIsGhost(u)) then
			return 'Ghost'
		end
	end]],

	['deficit:name'] = [[function(u)
		local missinghp = _TAGS['missinghp'](u)
		if(missinghp) then
			return '-' .. missinghp
		else
			return _TAGS['name'](u)
		end
	end]],

	['difficulty'] = [[function(u)
		if UnitCanAttack('player', u) then
			local l = UnitEffectiveLevel(u)
			return Hex(GetCreatureDifficultyColor((l > 0) and l or 999))
		end
	end]],

	['group'] = [[function(unit)
		local name, server = UnitName(unit)
		if(server and server ~= '') then
			name = string.format('%s-%s', name, server)
		end

		for i=1, GetNumGroupMembers() do
			local raidName, _, group = GetRaidRosterInfo(i)
			if( raidName == name ) then
				return group
			end
		end
	end]],

	['holypower'] = [[function()
		if(GetSpecialization() == SPEC_PALADIN_RETRIBUTION) then
			local num = UnitPower('player', Enum.PowerType.HolyPower)
			if(num > 0) then
				return num
			end
		end
	end]],

	['leader'] = [[function(u)
		if(UnitIsGroupLeader(u)) then
			return 'L'
		end
	end]],

	['leaderlong']  = [[function(u)
		if(UnitIsGroupLeader(u)) then
			return 'Leader'
		end
	end]],

	['level'] = [[function(u)
		local l = UnitEffectiveLevel(u)
		if(UnitIsWildBattlePet(u) or UnitIsBattlePetCompanion(u)) then
			l = UnitBattlePetLevel(u)
		end

		if(l > 0) then
			return l
		else
			return '??'
		end
	end]],

	['maxmana'] = [[function(unit)
		return UnitPowerMax(unit, Enum.PowerType.Mana)
	end]],

	['missinghp'] = [[function(u)
		local current = UnitHealthMax(u) - UnitHealth(u)
		if(current > 0) then
			return current
		end
	end]],

	['missingpp'] = [[function(u)
		local current = UnitPowerMax(u) - UnitPower(u)
		if(current > 0) then
			return current
		end
	end]],

	['name'] = [[function(u, r)
		return UnitName(r or u)
	end]],

	['offline'] = [[function(u)
		if(not UnitIsConnected(u)) then
			return 'Offline'
		end
	end]],

	['perhp'] = [[function(u)
		local m = UnitHealthMax(u)
		if(m == 0) then
			return 0
		else
			return math.floor(UnitHealth(u) / m * 100 + .5)
		end
	end]],

	['perpp'] = [[function(u)
		local m = UnitPowerMax(u)
		if(m == 0) then
			return 0
		else
			return math.floor(UnitPower(u) / m * 100 + .5)
		end
	end]],

	['plus'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'elite' or c == 'rareelite') then
			return '+'
		end
	end]],

	['powercolor'] = [[function(u)
		local pType, pToken, altR, altG, altB = UnitPowerType(u)
		local t = _COLORS.power[pToken]

		if(not t) then
			if(altR) then
				if(altR > 1 or altG > 1 or altB > 1) then
					return Hex(altR / 255, altG / 255, altB / 255)
				else
					return Hex(altR, altG, altB)
				end
			else
				return Hex(_COLORS.power[pType] or _COLORS.power.MANA)
			end
		end

		return Hex(t)
	end]],

	['pvp'] = [[function(u)
		if(UnitIsPVP(u)) then
			return 'PvP'
		end
	end]],

	['raidcolor'] = [[function(u)
		local _, class = UnitClass(u)
		if(class) then
			return Hex(_COLORS.class[class])
		else
			local id = u:match('arena(%d)$')
			if(id) then
				local specID = GetArenaOpponentSpec(tonumber(id))
				if(specID and specID > 0) then
					_, _, _, _, _, class = GetSpecializationInfoByID(specID)
					return Hex(_COLORS.class[class])
				end
			end
		end
	end]],

	['rare'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'rare' or c == 'rareelite') then
			return 'Rare'
		end
	end]],

	['resting'] = [[function(u)
		if(u == 'player' and IsResting()) then
			return 'zzz'
		end
	end]],

	['runes'] = [[function()
		local amount = 0

		for i = 1, 6 do
			local _, _, ready = GetRuneCooldown(i)
			if(ready) then
				amount = amount + 1
			end
		end

		return amount
	end]],

	['sex'] = [[function(u)
		local s = UnitSex(u)
		if(s == 2) then
			return 'Male'
		elseif(s == 3) then
			return 'Female'
		end
	end]],

	['shortclassification'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'rare') then
			return 'R'
		elseif(c == 'rareelite') then
			return 'R+'
		elseif(c == 'elite') then
			return '+'
		elseif(c == 'worldboss') then
			return 'B'
		elseif(c == 'minus') then
			return '-'
		end
	end]],

	['smartclass'] = [[function(u)
		if(UnitIsPlayer(u)) then
			return _TAGS['class'](u)
		end

		return _TAGS['creature'](u)
	end]],

	['smartlevel'] = [[function(u)
		local c = UnitClassification(u)
		if(c == 'worldboss') then
			return 'Boss'
		else
			local plus = _TAGS['plus'](u)
			local level = _TAGS['level'](u)
			if(plus) then
				return level .. plus
			else
				return level
			end
		end
	end]],

	['soulshards'] = [[function()
		local num = UnitPower('player', Enum.PowerType.SoulShards)
		if(num > 0) then
			return num
		end
	end]],

	['status'] = [[function(u)
		if(UnitIsDead(u)) then
			return 'Dead'
		elseif(UnitIsGhost(u)) then
			return 'Ghost'
		elseif(not UnitIsConnected(u)) then
			return 'Offline'
		else
			return _TAGS['resting'](u)
		end
	end]],

	['threat'] = [[function(u)
		local s = UnitThreatSituation(u)
		if(s == 1) then
			return '++'
		elseif(s == 2) then
			return '--'
		elseif(s == 3) then
			return 'Aggro'
		end
	end]],

	['threatcolor'] = [[function(u)
		return Hex(GetThreatStatusColor(UnitThreatSituation(u)))
	end]],
}

local tagFuncs = setmetatable(
	{
		curhp = UnitHealth,
		curpp = UnitPower,
		maxhp = UnitHealthMax,
		maxpp = UnitPowerMax,
		class = UnitClass,
		faction = UnitFactionGroup,
		race = UnitRace,
	},
	{
		__index = function(self, key)
			local tagString = tagStrings[key]
			if(tagString) then
				self[key] = tagString
				tagStrings[key] = nil
			end

			return rawget(self, key)
		end,
		__newindex = function(self, key, val)
			if(type(val) == 'string') then
				local func, err = loadstring('return ' .. val)
				if(func) then
					val = func()
				else
					error(err, 3)
				end
			end

			assert(type(val) == 'function', 'Tag function must be a function or a string that evaluates to a function.')

			-- We don't want to clash with any custom envs
			if(getfenv(val) == _G) then
				-- pcall is needed for cases when Blizz functions are passed as strings, for
				-- intance, 'UnitPowerMax', an attempt to set a custom env will result in an error
				pcall(setfenv, val, _PROXY)
			end

			rawset(self, key, val)
		end,
	}
)

_ENV._TAGS = tagFuncs

local vars = setmetatable({}, {
	__newindex = function(self, key, val)
		if(type(val) == 'string') then
			local func = loadstring('return ' .. val)
			if(func) then
				val = func() or val
			end
		end

		rawset(self, key, val)
	end,
})

_ENV._VARS = vars

local tagEvents = {
	['affix']               = 'UNIT_CLASSIFICATION_CHANGED',
	['arcanecharges']       = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE',
	['arenaspec']           = 'ARENA_PREP_OPPONENT_SPECIALIZATIONS',
	['chi']                 = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE',
	['classification']      = 'UNIT_CLASSIFICATION_CHANGED',
	['cpoints']             = 'UNIT_POWER_FREQUENT PLAYER_TARGET_CHANGED',
	['curhp']               = 'UNIT_HEALTH UNIT_MAXHEALTH',
	['curmana']             = 'UNIT_POWER_UPDATE UNIT_MAXPOWER',
	['curpp']               = 'UNIT_POWER_UPDATE UNIT_MAXPOWER',
	['dead']                = 'UNIT_HEALTH',
	['deficit:name']        = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE',
	['difficulty']          = 'UNIT_FACTION',
	['faction']             = 'NEUTRAL_FACTION_SELECT_RESULT',
	['group']               = 'GROUP_ROSTER_UPDATE',
	['holypower']           = 'UNIT_POWER_UPDATE PLAYER_TALENT_UPDATE',
	['leader']              = 'PARTY_LEADER_CHANGED',
	['leaderlong']          = 'PARTY_LEADER_CHANGED',
	['level']               = 'UNIT_LEVEL PLAYER_LEVEL_UP',
	['maxhp']               = 'UNIT_MAXHEALTH',
	['maxmana']             = 'UNIT_POWER_UPDATE UNIT_MAXPOWER',
	['maxpp']               = 'UNIT_MAXPOWER',
	['missinghp']           = 'UNIT_HEALTH UNIT_MAXHEALTH',
	['missingpp']           = 'UNIT_MAXPOWER UNIT_POWER_UPDATE',
	['name']                = 'UNIT_NAME_UPDATE',
	['offline']             = 'UNIT_HEALTH UNIT_CONNECTION',
	['perhp']               = 'UNIT_HEALTH UNIT_MAXHEALTH',
	['perpp']               = 'UNIT_MAXPOWER UNIT_POWER_UPDATE',
	['plus']                = 'UNIT_CLASSIFICATION_CHANGED',
	['powercolor']          = 'UNIT_DISPLAYPOWER',
	['pvp']                 = 'UNIT_FACTION',
	['rare']                = 'UNIT_CLASSIFICATION_CHANGED',
	['resting']             = 'PLAYER_UPDATE_RESTING',
	['runes']               = 'RUNE_POWER_UPDATE',
	['shortclassification'] = 'UNIT_CLASSIFICATION_CHANGED',
	['smartlevel']          = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED',
	['soulshards']          = 'UNIT_POWER_UPDATE',
	['status']              = 'UNIT_HEALTH PLAYER_UPDATE_RESTING UNIT_CONNECTION',
	['threat']              = 'UNIT_THREAT_SITUATION_UPDATE',
	['threatcolor']         = 'UNIT_THREAT_SITUATION_UPDATE',
}

local unitlessEvents = {
	ARENA_PREP_OPPONENT_SPECIALIZATIONS = true,
	GROUP_ROSTER_UPDATE = true,
	NEUTRAL_FACTION_SELECT_RESULT = true,
	PARTY_LEADER_CHANGED = true,
	PLAYER_LEVEL_UP = true,
	PLAYER_TALENT_UPDATE = true,
	PLAYER_TARGET_CHANGED = true,
	PLAYER_UPDATE_RESTING = true,
	RUNE_POWER_UPDATE = true,
}

local eventFontStrings = {}
local stringsToUpdate = {}

local eventFrame = CreateFrame('Frame')
eventFrame:SetScript('OnEvent', function(self, event, unit)
	local strings = eventFontStrings[event]
	if(strings) then
		for fs in next, strings do
			if(not stringsToUpdate[fs] and fs:IsVisible() and (unitlessEvents[event] or fs.parent.unit == unit or (fs.extraUnits and fs.extraUnits[unit]))) then
				stringsToUpdate[fs] = true
			end
		end
	end
end)

local eventTimer = 0
local eventTimerThreshold = 0.1

eventFrame:SetScript('OnUpdate', function(self, elapsed)
	eventTimer = eventTimer + elapsed
	if(eventTimer >= eventTimerThreshold) then
		for fs in next, stringsToUpdate do
			if(fs:IsVisible()) then
				fs:UpdateTag()
			end
		end

		table.wipe(stringsToUpdate)

		eventTimer = 0
	end
end)

local timerFrames = {}
local timerFontStrings = {}

local function enableTimer(timer)
	local frame = timerFrames[timer]
	if(not frame) then
		local total = timer
		local strings = timerFontStrings[timer]

		frame = CreateFrame('Frame')
		frame:SetScript('OnUpdate', function(self, elapsed)
			if(total >= timer) then
				for fs in next, strings do
					if(fs.parent:IsShown() and unitExists(fs.parent.unit)) then
						fs:UpdateTag()
					end
				end

				total = 0
			end

			total = total + elapsed
		end)

		timerFrames[timer] = frame
	else
		frame:Show()
	end
end

local function disableTimer(timer)
	local frame = timerFrames[timer]
	if(frame) then
		frame:Hide()
	end
end

--[[ Tags: frame:UpdateTags()
Used to update all tags on a frame.

* self - the unit frame from which to update the tags
--]]
local function Update(self)
	if(self.__tags) then
		for fs in next, self.__tags do
			fs:UpdateTag()
		end
	end
end

-- full tag syntax: '[prefix$>tag-name<$suffix(a,r,g,s)]'
-- for a small test case see https://github.com/oUF-wow/oUF/pull/602
local bracketData = {}

local function getBracketData(bracket)
	local data = bracketData[bracket]
	if(not data) then
		local prefixEnd, prefixOffset = bracket:match('()$>'), 1
		if(not prefixEnd) then
			prefixEnd = 1
		else
			prefixEnd = prefixEnd - 1
			prefixOffset = 3
		end

		local suffixEnd = (bracket:match('()%(', prefixOffset + 1) or -1) - 1
		local suffixStart, suffixOffset = bracket:match('<$()', prefixEnd), 1
		if(not suffixStart) then
			suffixStart = suffixEnd + 1
		else
			suffixOffset = 3
		end

		data = {
			bracket:sub(prefixEnd + prefixOffset, suffixStart - suffixOffset),
			prefixEnd,
			suffixStart,
			suffixEnd,
			bracket:match('%((.-)%)', suffixOffset + 1),
		}

		bracketData[bracket] = data
	end

	return data[1], data[2], data[3], data[4], data[5]
end

local tagStringFuncs = {}
local bracketFuncs = {}
local invalidBrackets = {}
local buffer = {}

local function getTagFunc(tagstr)
	local func = tagStringFuncs[tagstr]
	if(not func) then
		local format, num = tagstr:gsub('%%', '%%%%'):gsub(_PATTERN, '%%s')
		local funcs = {}

		for bracket in tagstr:gmatch(_PATTERN) do
			local tagFunc = bracketFuncs[bracket] or tagFuncs[bracket:sub(2, -2)]
			if(not tagFunc) then
				local tagName, prefixEnd, suffixStart, suffixEnd, customArgs = getBracketData(bracket)
				local tag = tagFuncs[tagName]
				if(tag) then
					if(prefixEnd ~= 1 or suffixStart - suffixEnd ~= 1) then
						local prefix = prefixEnd ~= 1 and bracket:sub(2, prefixEnd) or ''
						local suffix = suffixStart - suffixEnd ~= 1 and bracket:sub(suffixStart, suffixEnd) or ''

						tagFunc = function(unit, realUnit)
							local str
							if(customArgs) then
								str = tag(unit, realUnit, string.split(',', customArgs))
							else
								str = tag(unit, realUnit)
							end

							if(str and str ~= '') then
								return prefix .. str .. suffix
							end
						end
					else
						tagFunc = function(unit, realUnit)
							local str
							if(customArgs) then
								str = tag(unit, realUnit, string.split(',', customArgs))
							else
								str = tag(unit, realUnit)
							end

							if(str and str ~= '') then
								return str
							end
						end
					end

					bracketFuncs[bracket] = tagFunc
				end
			end

			if(not tagFunc) then
				nierror(string.format('Attempted to use invalid tag %s.', bracket))

				-- don't check for these earlier in the function because a valid tag under the same
				-- name could've been created at some point
				tagFunc = invalidBrackets[bracket]
				if(not tagFunc) then
					tagFunc = function()
						return '|cffffffff' .. bracket .. '|r'
					end

					invalidBrackets[bracket] = tagFunc
				end
			end

			table.insert(funcs, tagFunc)
		end

		func = function(self)
			local parent = self.parent
			local unit = parent.unit
			local realUnit
			if(self.overrideUnit) then
				realUnit = parent.realUnit
			end

			_ENV._COLORS = parent.colors
			_ENV._FRAME = parent

			for i, f in next, funcs do
				buffer[i] = f(unit, realUnit) or ''
			end

			-- we do 1 to num because buffer is shared by all tags and can hold several unneeded vars
			self:SetFormattedText(format, unpack(buffer, 1, num))
		end

		tagStringFuncs[tagstr] = func
	end

	return func
end

local function registerEvent(event, fs)
	if(validateEvent(event)) then
		if(not eventFontStrings[event]) then
			eventFontStrings[event] = {}
		end

		eventFontStrings[event][fs] = true

		eventFrame:RegisterEvent(event)
	end
end

local function registerEvents(fs, ts)
	for tag in ts:gmatch(_PATTERN) do
		local tagevents = tagEvents[getBracketData(tag)]
		if(tagevents) then
			for event in tagevents:gmatch('%S+') do
				registerEvent(event, fs)
			end
		end
	end
end

local function unregisterEvents(fs)
	for event, strings in next, eventFontStrings do
		strings[fs] = nil

		if(not next(strings)) then
			eventFrame:UnregisterEvent(event)
		end
	end
end

local function registerTimer(fs, timer)
	if(not timerFontStrings[timer]) then
		timerFontStrings[timer] = {}
	end

	timerFontStrings[timer][fs] = true

	enableTimer(timer)
end

local function unregisterTimer(fs)
	for timer, strings in next, timerFontStrings do
		strings[fs] = nil

		if(not next(strings)) then
			disableTimer(timer)
		end
	end
end

local taggedFontStrings = {}

--[[ Tags: frame:Tag(fs, ts, ...)
Used to register a tag on a unit frame.

* self   - the unit frame on which to register the tag
* fs     - the font string to display the tag (FontString)
* ts     - the tag string (string)
* ...    - additional optional unitID(s) the tag should update for
--]]
local function Tag(self, fs, ts, ...)
	if(not fs or not ts) then return end

	if(not self.__tags) then
		self.__tags = {}
		table.insert(self.__elements, Update)
	elseif(self.__tags[fs]) then
		-- We don't need to remove it from the __tags table as Untag handles that for us.
		self:Untag(fs)
	end

	fs.parent = self
	fs.UpdateTag = getTagFunc(ts)

	if(self.__eventless or fs.frequentUpdates) then
		local timer = 0.5
		if(type(fs.frequentUpdates) == 'number') then
			timer = fs.frequentUpdates
		end

		registerTimer(fs, timer)
	else
		registerEvents(fs, ts)

		if(...) then
			if(not fs.extraUnits) then
				fs.extraUnits = {}
			end

			for index = 1, select('#', ...) do
				fs.extraUnits[select(index, ...)] = true
			end
		end
	end

	taggedFontStrings[fs] = ts
	self.__tags[fs] = true
end

--[[ Tags: frame:Untag(fs)
Used to unregister a tag from a unit frame.

* self - the unit frame from which to unregister the tag
* fs   - the font string holding the tag (FontString)
--]]
local function Untag(self, fs)
	if(not fs or not self.__tags) then return end

	unregisterEvents(fs)
	unregisterTimer(fs)

	fs.UpdateTag = nil

	taggedFontStrings[fs] = nil
	self.__tags[fs] = nil
end

local function strip(tag)
	-- remove prefix, custom args, and suffix
	return tag:gsub('%[.-$>', '['):gsub('%(.-%)%]', ']'):gsub('<$.-%]', ']')
end

oUF.Tags = {
	Methods = tagFuncs,
	Events = tagEvents,
	SharedEvents = unitlessEvents,
	Vars = vars,
	RefreshMethods = function(self, tag)
		if(not tag) then return end

		-- if a tag's name contains magic chars, there's a chance that string.match will fail to
		-- find the match
		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'

		for bracket in next, bracketFuncs do
			if(strip(bracket):match(tag)) then
				bracketFuncs[bracket] = nil
			end
		end

		for tagstr, func in next, tagStringFuncs do
			if(strip(tagstr):match(tag)) then
				tagStringFuncs[tagstr] = nil

				for fs in next, taggedFontStrings do
					if(fs.UpdateTag == func) then
						fs.UpdateTag = getTagFunc(tagstr)

						if(fs:IsVisible()) then
							fs:UpdateTag()
						end
					end
				end
			end
		end
	end,
	RefreshEvents = function(self, tag)
		if(not tag) then return end

		-- if a tag's name contains magic chars, there's a chance that string.match will fail to
		-- find the match
		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'

		for tagstr in next, tagStringFuncs do
			if(strip(tagstr):match(tag)) then
				for fs, ts in next, taggedFontStrings do
					if(ts == tagstr) then
						unregisterEvents(fs)
						registerEvents(fs, tagstr)
					end
				end
			end
		end
	end,
	SetEventUpdateTimer = function(self, timer)
		if(not timer) then return end
		if(not type(timer) == 'number') then return end

		eventTimerThreshold = math.max(0.05, timer)
	end,
}

oUF:RegisterMetaFunction('Tag', Tag)
oUF:RegisterMetaFunction('Untag', Untag)
oUF:RegisterMetaFunction('UpdateTags', Update)