-----------------------------------------
-- SortBags 2.1.5, shirsig
-- https://github.com/shirsig/SortBags
-----------------------------------------
local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

CreateFrame('GameTooltip', 'SortBagsTooltip', nil, 'GameTooltipTemplate')

BAG_CONTAINERS = {0, 1, 2, 3, 4}
BANK_BAG_CONTAINERS = {-1, 5, 6, 7, 8, 9, 10, 11}

function _G.SortBags()
	CONTAINERS = {unpack(BAG_CONTAINERS)}
--	for i = #CONTAINERS, 1, -1 do
--		if GetBagSlotFlag(i - 1, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
--			tremove(CONTAINERS, i)
--		end
--	end
	Start()
end

function _G.SortBankBags()
	CONTAINERS = {unpack(BANK_BAG_CONTAINERS)}
--	for i = #CONTAINERS, 1, -1 do
--		if GetBankBagSlotFlag(i - 1, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
--			tremove(CONTAINERS, i)
--		end
--	end
	Start()
end

function _G.GetSortBagsRightToLeft(enabled)
	return SortBagsRightToLeft
end

function _G.SetSortBagsRightToLeft(enabled)
	_G.SortBagsRightToLeft = enabled and 1 or nil
end

local function set(...)
	local t = {}
	local n = select('#', ...)
	for i = 1, n do
		t[select(i, ...)] = true
	end
	return t
end

local function arrayToSet(array)
	local t = {}
	for i = 1, #array do
		t[array[i]] = true
	end
	return t
end

local function union(...)
	local t = {}
	local n = select('#', ...)
	for i = 1, n do
		for k in pairs(select(i, ...)) do
			t[k] = true
		end
	end
	return t
end

local SPECIAL = set(5462, 13347, 11511, 38233, 9173)

local KEYS = set(9240, 11511, 17191, 13544, 12324, 16309, 12384, 20402)

local TOOLS = set(6218, 6339, 11130, 11145, 16207, 22461, 22462, 22463, 5060, 7005, 12709, 19727, 5956, 2901, 6219, 10498, 9149, 15846, 6256, 6365, 6366, 6367, 12225, 19022, 25978, 19970, 20815, 20824, 25978)

local CLASSES = {
	-- soul
	{
		containers = {22243, 22244, 21340, 21341, 21342, 21872},
		items = set(6265),
	},
	-- arrow
	{
		containers = {2101, 5439, 7278, 11362, 3573, 3605, 7371, 8217, 2662, 19319, 18714, 29143, 29144, 34105, 34100},
		items = set(2512, 2514, 2515, 3029, 3030, 3031, 3464, 9399, 10579, 11285, 12654, 18042, 19316, 24412, 24417, 28053, 28056, 30319, 30611, 31737, 31949, 32760, 33803, 34581),
	},
	-- bullet
	{
		containers = {2102, 5441, 7279, 11363, 3574, 3604, 7372, 8218, 2663, 19320, 29118, 34106, 34099},
		items = set(2516, 2519, 3033, 3465, 4960, 5568, 8067, 8068, 8069, 10512, 10513, 11284, 11630, 13377, 15997, 19317, 23772, 23773, 28060, 28061, 30612, 31735, 32761, 32882, 32883, 34582),
	},
	-- ench
	{
		containers = {22246, 22248, 22249, 30748, 21858},
		items = arrayToSet({6218, 6222, 6339, 6342, 6343, 6344, 6345, 6346, 6347, 6348, 6349, 6375, 6376, 6377, 10938, 10939, 10940, 10978, 10998, 11038, 11039, 11081, 11082, 11083, 11084, 11098, 11101, 11130, 11134, 11135, 11137, 11138, 11139, 11145, 11150, 11151, 11152, 11163, 11164, 11165, 11166, 11167, 11168, 11174, 11175, 11176, 11177, 11178, 11202, 11203, 11204, 11205, 11206, 11207, 11208, 11223, 11224, 11225, 11226, 11813, 14343, 14344, 16202, 16203, 16204, 16207, 16214, 16215, 16216, 16217, 16218, 16219, 16220, 16221, 16222, 16223, 16224, 16242, 16243, 16244, 16245, 16246, 16247, 16248, 16249, 16250, 16251, 16252, 16253, 16254, 16255, 17725, 18259, 18260, 19444, 19445, 19446, 19447, 19448, 19449, 20725, 20726, 20727, 20728, 20729, 20730, 20731, 20732, 20733, 20734, 20735, 20736, 20752, 20753, 20754, 20755, 20756, 20757, 20758, 22392, 22445, 22446, 22447, 22448, 22449, 22450, 22461, 22462, 22463, 22530, 22531, 22532, 22533, 22534, 22535, 22536, 22537, 22538, 22539, 22540, 22541, 22542, 22543, 22544, 22545, 22546, 22547, 22548, 22551, 22552, 22553, 22554, 22555, 22556, 22557, 22558, 22559, 22560, 22561, 22562, 22563, 22564, 22565, 24000, 24003, 25848, 25849, 28270, 28271, 28272, 28273, 28274, 28276, 28277, 28279, 28280, 28281, 28282, 33148, 33149, 33150, 33151, 33152, 33153, 33165, 33307, 34872, 35297, 35298, 35299, 35498, 35500, 35756, 186683, 7081, 12810, 7068, 7972, 12808, 7067, 7075, 7076, 7077, 7078, 7080, 7082, 12803, 21885, 22451, 22456, 22457, 22572, 22576, 22577, 22578, 23571, 23572, 21886, 22575, 21884, 22452, 22573, 22574}),
	},
	-- herb
	{
		containers = {22250, 22251, 22252, 38225},
		items = arrayToSet({765, 785, 1401, 2263, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 5013, 5056, 5168, 8831, 8836, 8838, 8839, 8845, 8846, 11018, 11020, 11022, 11024, 11040, 11514, 11951, 11952, 13463, 13464, 13465, 13466, 13467, 13468, 16205, 16208, 17034, 17035, 17036, 17037, 17038, 17760, 18297, 19727, 22094, 22147, 22710, 22785, 22786, 22787, 22788, 22789, 22790, 22791, 22792, 22793, 22794, 22795, 22797, 23329, 23501, 23788, 24245, 24246, 24401, 31300, 32468, 34465, 8153, 10286, 19726, 21886, 22575}),
	},
	-- mining
	{
		containers = {29540, 30746},
		items = arrayToSet({756, 778, 1819, 1893, 1959, 2770, 2771, 2772, 2775, 2776, 2835, 2836, 2838, 2840, 2841, 2842, 2901, 3575, 3576, 3577, 3858, 3859, 3860, 3861, 6037, 7911, 7912, 10620, 11370, 11371, 12359, 12360, 12365, 12655, 17771, 18562, 20723, 22202, 22203, 23424, 23425, 23426, 23427, 23445, 23446, 23447, 23448, 23449, 23573, 32464, 35128, 5956, 21884, 22452, 22573, 22574, 24186, 24188, 24190, 24234, 24235, 24242, 24243}),
	},
	-- leather
	{
		containers = {34482, 34490},
		items = arrayToSet({783, 2304, 2313, 2318, 2319, 2320, 2321, 2324, 2325, 2406, 2407, 2408, 2409, 2604, 2605, 2934, 3182, 3824, 4096, 4231, 4232, 4233, 4234, 4235, 4236, 4265, 4289, 4291, 4293, 4294, 4295, 4296, 4297, 4298, 4299, 4300, 4301, 4304, 4337, 4340, 4341, 4342, 4461, 5082, 5083, 5116, 5373, 5637, 5784, 5785, 5786, 5787, 5788, 5789, 5972, 5973, 5974, 6260, 6261, 6470, 6471, 6474, 6475, 6476, 6710, 7005, 7070, 7071, 7286, 7287, 7288, 7289, 7290, 7360, 7361, 7362, 7363, 7364, 7392, 7428, 7449, 7450, 7451, 7452, 7453, 7613, 8146, 8150, 8151, 8154, 8165, 8167, 8168, 8169, 8170, 8171, 8172, 8173, 8343, 8368, 8384, 8385, 8386, 8387, 8388, 8389, 8390, 8395, 8397, 8398, 8399, 8400, 8401, 8402, 8403, 8404, 8405, 8406, 8407, 8408, 8409, 10290, 11512, 12607, 12709, 12731, 12753, 13287, 13288, 14341, 14635, 15407, 15408, 15409, 15410, 15412, 15414, 15415, 15416, 15417, 15419, 15420, 15422, 15423, 15564, 15725, 15726, 15727, 15728, 15729, 15730, 15731, 15732, 15733, 15734, 15735, 15737, 15738, 15739, 15740, 15741, 15742, 15743, 15744, 15745, 15746, 15747, 15748, 15749, 15751, 15752, 15753, 15754, 15755, 15756, 15757, 15758, 15759, 15760, 15761, 15762, 15763, 15764, 15765, 15768, 15769, 15770, 15771, 15772, 15773, 15774, 15775, 15776, 15777, 15779, 15781, 17012, 17022, 17023, 17025, 17056, 17722, 17967, 17968, 18239, 18240, 18251, 18252, 18512, 18514, 18515, 18516, 18517, 18518, 18519, 18662, 18731, 18949, 19326, 19327, 19328, 19329, 19330, 19331, 19332, 19333, 19767, 19768, 19769, 19770, 19771, 19772, 19773, 19901, 20253, 20254, 20381, 20382, 20498, 20499, 20500, 20501, 20506, 20507, 20508, 20509, 20510, 20511, 20576, 21548, 21887, 22692, 22694, 22695, 22696, 22697, 22698, 22769, 22770, 22771, 23793, 25649, 25650, 25651, 25652, 25699, 25700, 25707, 25708, 25720, 25721, 25722, 25725, 25726, 25728, 25729, 25730, 25731, 25732, 25733, 25734, 25735, 25736, 25737, 25738, 25739, 25740, 25741, 25742, 25743, 29213, 29214, 29215, 29217, 29218, 29219, 29483, 29485, 29486, 29487, 29488, 29528, 29529, 29530, 29531, 29532, 29533, 29534, 29535, 29536, 29539, 29547, 29548, 29664, 29669, 29672, 29673, 29674, 29675, 29677, 29682, 29684, 29689, 29691, 29693, 29698, 29700, 29701, 29702, 29703, 29704, 29713, 29714, 29717, 29718, 29719, 29720, 29721, 29722, 29723, 29724, 29725, 29726, 29727, 29728, 29729, 29730, 29731, 29732, 29733, 29734, 30183, 30301, 30302, 30303, 30304, 30305, 30306, 30307, 30308, 30444, 31361, 31362, 32428, 32429, 32430, 32431, 32432, 32433, 32434, 32435, 32436, 32470, 32744, 32745, 32746, 32747, 32748, 32749, 32750, 32751, 33124, 33205, 34172, 34173, 34174, 34175, 34200, 34201, 34207, 34218, 34262, 34330, 34491, 34664, 35212, 35213, 35214, 35215, 35216, 35217, 35218, 35219, 35300, 35301, 35302, 35303, 35517, 35519, 35520, 35521, 35523, 35524, 35527, 35528, 35539, 35540, 35541, 35542, 35545, 35546, 35549, 35550, 185848, 185849, 185850, 185851, 185852, 185922, 185923, 185924, 185925, 185926, 187048, 187049, 8153, 7081, 12810, 15846, 19726, 7067, 7075, 7076, 7077, 7078, 7080, 7082, 12803, 21885, 22451, 22456, 22457, 22572, 22576, 22577, 22578, 23571, 23572, 21886, 22575, 21884, 22452, 22573, 22574}),
	},
	-- gems
	{
		containers = {24270, 30747},
		items = arrayToSet({774, 818, 1206, 1210, 1529, 1705, 3864, 5498, 5500, 5513, 5514, 7909, 7910, 7971, 8007, 8008, 11382, 11754, 12361, 12363, 12364, 12799, 12800, 13926, 18335, 19774, 20815, 20824, 21929, 22044, 22459, 22460, 23077, 23079, 23094, 23095, 23096, 23097, 23098, 23099, 23100, 23101, 23103, 23104, 23105, 23106, 23107, 23108, 23109, 23110, 23111, 23112, 23113, 23114, 23115, 23116, 23117, 23118, 23119, 23120, 23121, 23158, 23234, 23364, 23366, 23436, 23437, 23438, 23439, 23440, 23441, 24027, 24028, 24029, 24030, 24031, 24032, 24033, 24035, 24036, 24037, 24039, 24047, 24048, 24050, 24051, 24052, 24053, 24054, 24055, 24056, 24057, 24058, 24059, 24060, 24061, 24062, 24065, 24066, 24067, 24478, 24479, 25867, 25868, 25890, 25893, 25894, 25895, 25896, 25897, 25898, 25899, 25901, 27679, 27774, 27777, 27785, 27786, 27809, 27811, 27812, 27820, 27863, 27864, 28117, 28118, 28119, 28120, 28122, 28123, 28290, 28360, 28361, 28362, 28363, 28458, 28459, 28460, 28461, 28462, 28463, 28464, 28465, 28466, 28467, 28468, 28469, 28470, 28556, 28557, 28595, 30546, 30547, 30548, 30549, 30550, 30551, 30552, 30553, 30554, 30555, 30556, 30558, 30559, 30560, 30563, 30564, 30565, 30566, 30571, 30572, 30573, 30574, 30575, 30581, 30582, 30583, 30584, 30585, 30586, 30587, 30588, 30589, 30590, 30591, 30592, 30593, 30594, 30598, 30600, 30601, 30602, 30603, 30604, 30605, 30606, 30607, 30608, 31079, 31080, 31116, 31117, 31118, 31860, 31861, 31862, 31863, 31864, 31865, 31866, 31867, 31868, 31869, 32193, 32194, 32195, 32196, 32197, 32198, 32199, 32200, 32201, 32202, 32203, 32204, 32205, 32206, 32207, 32208, 32209, 32210, 32211, 32212, 32213, 32214, 32215, 32216, 32217, 32218, 32219, 32220, 32221, 32222, 32223, 32224, 32225, 32226, 32227, 32228, 32229, 32230, 32231, 32249, 32409, 32410, 32634, 32635, 32636, 32637, 32638, 32639, 32640, 32641, 32735, 32775, 32833, 32836, 33131, 33132, 33133, 33134, 33135, 33137, 33138, 33139, 33140, 33141, 33142, 33143, 33144, 33633, 33782, 34220, 34256, 34831, 35315, 35316, 35318, 35487, 35488, 35489, 35501, 35503, 35707, 35758, 35759, 35760, 35761, 37503, 38545, 38546, 38547, 38548, 38549, 38550, 24186, 24188, 24190, 24234, 24235, 24242, 24243}),
	},
	-- engineering
	{
		containers = {23774, 23775, 30745},
		items = arrayToSet({814, 4357, 4358, 4359, 4360, 4361, 4363, 4364, 4365, 4366, 4367, 4368, 4370, 4371, 4373, 4374, 4375, 4376, 4377, 4378, 4380, 4381, 4382, 4384, 4385, 4386, 4387, 4388, 4389, 4390, 4391, 4392, 4393, 4394, 4395, 4396, 4397, 4398, 4399, 4400, 4403, 4404, 4405, 4406, 4407, 4408, 4409, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4852, 5507, 6219, 6672, 6712, 6714, 6715, 6716, 7069, 7148, 7189, 7190, 7191, 7192, 7506, 7560, 7561, 7742, 9060, 9061, 9312, 9313, 9318, 10498, 10499, 10500, 10501, 10502, 10503, 10504, 10505, 10506, 10507, 10514, 10518, 10542, 10543, 10545, 10546, 10548, 10558, 10559, 10560, 10561, 10562, 10576, 10577, 10580, 10585, 10586, 10587, 10588, 10601, 10602, 10603, 10604, 10605, 10606, 10607, 10608, 10609, 10645, 10646, 10647, 10648, 10716, 10720, 10721, 10723, 10724, 10725, 10726, 10727, 10790, 10791, 11590, 11827, 11828, 13308, 13309, 13310, 13311, 14639, 15992, 15993, 15994, 15999, 16000, 16005, 16006, 16008, 16009, 16022, 16023, 16040, 16041, 16042, 16043, 16044, 16045, 16046, 16047, 16048, 16049, 16050, 16051, 16052, 16053, 16054, 16055, 16056, 17716, 17720, 18232, 18235, 18283, 18290, 18291, 18292, 18587, 18588, 18594, 18631, 18634, 18636, 18637, 18638, 18639, 18641, 18645, 18647, 18648, 18649, 18650, 18651, 18652, 18653, 18654, 18655, 18656, 18657, 18658, 18660, 18661, 18984, 18986, 19026, 19027, 19998, 19999, 20000, 20001, 20475, 20816, 20834, 21557, 21558, 21559, 21571, 21574, 21576, 21589, 21590, 21592, 21714, 21716, 21718, 21724, 21725, 21726, 21727, 21728, 21729, 21730, 21731, 21732, 21733, 21734, 21735, 21737, 21738, 22728, 22729, 23736, 23737, 23758, 23761, 23762, 23763, 23764, 23765, 23766, 23768, 23769, 23770, 23771, 23781, 23782, 23783, 23784, 23785, 23786, 23787, 23799, 23800, 23802, 23803, 23804, 23805, 23806, 23807, 23808, 23809, 23810, 23811, 23812, 23813, 23814, 23815, 23816, 23817, 23819, 23820, 23821, 23822, 23823, 23824, 23825, 23826, 23827, 23828, 23829, 23831, 23832, 23835, 23836, 23838, 23839, 23840, 23841, 23874, 23882, 23883, 23884, 23887, 23888, 25886, 25887, 30542, 30544, 31666, 32381, 32413, 32423, 32461, 32472, 32473, 32474, 32475, 32476, 32478, 32479, 32480, 32494, 32495, 33092, 33093, 33804, 34060, 34061, 34113, 34114, 34353, 34354, 34355, 34356, 34357, 34467, 34503, 34504, 34626, 34627, 34847, 35181, 35182, 35183, 35184, 35185, 35186, 35187, 35189, 35190, 35191, 35192, 35193, 35194, 35195, 35196, 35197, 35310, 35311, 35485, 35581, 35582, 37567, 15846, 10286, 19726, 7068, 7972, 12808, 7067, 7075, 7076, 7077, 7078, 7080, 7082, 12803, 21885, 22451, 22456, 22457, 22572, 22576, 22577, 22578, 23571, 23572, 21886, 22575, 5956, 21884, 22452, 22573, 22574, 4401, 11825, 11826, 15996, 21277, 23767, 37710}),
	},
}

do
	local f = CreateFrame'Frame'
	local lastUpdate = 0
	local function updateHandler()
		if GetTime() - lastUpdate > 1 then
			for _, container in pairs(BAG_CONTAINERS) do
				for position = 1, GetContainerNumSlots(container) do
					SetScanTooltip(container, position)
				end
			end
			for _, container in pairs(BANK_BAG_CONTAINERS) do
				for position = 1, GetContainerNumSlots(container) do
					SetScanTooltip(container, position)
				end
			end
			f:SetScript('OnUpdate', nil)
		end
	end
	f:SetScript('OnEvent', function()
		lastUpdate = GetTime()
		f:SetScript('OnUpdate', updateHandler)
	end)
	f:RegisterEvent'BAG_UPDATE'
	f:RegisterEvent'BANKFRAME_OPENED'
end

local model, itemStacks, itemClasses, itemSortKeys

do
	local f = CreateFrame'Frame'

	local process = coroutine.create(function() end);

	local suspended

	function Start()
		process = coroutine.create(function()
			while not Initialize() do
				coroutine.yield()
			end
			while true do
				suspended = false
				if InCombatLockdown() then
					return
				end
				local complete = Sort()
				if complete then
					return
				end
				Stack()
				if not suspended then
					coroutine.yield()
				end
			end
		end)
		f:Show()
	end

	f:SetScript('OnUpdate', function(_, arg1)
		if coroutine.status(process) == 'suspended' then
			suspended = true
			coroutine.resume(process)
		end
		if coroutine.status(process) == 'dead' then
			f:Hide()
		end
	end)
end

function LT(a, b)
	local i = 1
	while true do
		if a[i] and b[i] and a[i] ~= b[i] then
			return a[i] < b[i]
		elseif not a[i] and b[i] then
			return true
		elseif not b[i] then
			return false
		end
		i = i + 1
	end
end

function Move(src, dst)
	local texture, _, srcLocked = GetContainerItemInfo(src.container, src.position)
	local _, _, dstLocked = GetContainerItemInfo(dst.container, dst.position)

	if texture and not srcLocked and not dstLocked then
		ClearCursor()
		PickupContainerItem(src.container, src.position)
		PickupContainerItem(dst.container, dst.position)

		if src.item == dst.item then
			local count = min(src.count, itemStacks[dst.item] - dst.count)
			src.count = src.count - count
			dst.count = dst.count + count
			if src.count == 0 then
				src.item = nil
			end
		else
			src.item, dst.item = dst.item, src.item
			src.count, dst.count = dst.count, src.count
		end

		coroutine.yield()
		return true
	end
end

do
	local patterns = {}
	for i = 1, 10 do
		local text = gsub(format(ITEM_SPELL_CHARGES, i), '(-?%d+)(.-)|4([^;]-);', function(numberString, gap, numberForms)
			local singular, dual, plural
			_, _, singular, dual, plural = strfind(numberForms, '(.+):(.+):(.+)');
			if not singular then
				_, _, singular, plural = strfind(numberForms, '(.+):(.+)')
			end
			local i = abs(tonumber(numberString))
			local numberForm
			if i == 1 then
				numberForm = singular
			elseif i == 2 then
				numberForm = dual or plural
			else
				numberForm = plural
			end
			return numberString .. gap .. numberForm
		end)
		patterns[text] = i
	end

	function itemCharges(text)
		return patterns[text]
	end
end

function TooltipInfo(container, position)
	SetScanTooltip(container, position)

	local charges, usable, soulbound, quest, conjured, mount
	for i = 1, SortBagsTooltip:NumLines() do
		local text = getglobal('SortBagsTooltipTextLeft' .. i):GetText()

		local extractedCharges = itemCharges(text)
		if extractedCharges then
			charges = extractedCharges
		elseif strfind(text, '^' .. ITEM_SPELL_TRIGGER_ONUSE) then
			usable = true
		elseif text == ITEM_SOULBOUND then
			soulbound = true
		elseif text == ITEM_BIND_QUEST then -- TODO retail can maybe use GetItemInfo bind info instead
			quest = true
		elseif text == ITEM_CONJURED then
			conjured = true
		elseif text == MOUNT then
			mount = true
		end
	end

	return charges or 1, usable, soulbound, quest, conjured, mount
end

function SetScanTooltip(container, position)
	SortBagsTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	SortBagsTooltip:ClearLines()

	if container == BANK_CONTAINER then
		SortBagsTooltip:SetInventoryItem('player', BankButtonIDToInvSlotID(position))
	else
		SortBagsTooltip:SetBagItem(container, position)
	end
end

function Sort()
	local complete, moved
	repeat
		complete, moved = true, false
		for _, dst in ipairs(model) do
			if dst.targetItem and (dst.item ~= dst.targetItem or dst.count < dst.targetCount) then
				complete = false

				local sources, rank = {}, {}

				for _, src in ipairs(model) do
					if src.item == dst.targetItem
						and src ~= dst
						and not (dst.item and src.class and src.class ~= itemClasses[dst.item])
						and not (src.targetItem and src.item == src.targetItem and src.count <= src.targetCount)
					then
						rank[src] = abs(src.count - dst.targetCount + (dst.item == dst.targetItem and dst.count or 0))
						tinsert(sources, src)
					end
				end

				sort(sources, function(a, b) return rank[a] < rank[b] end)

				for _, src in ipairs(sources) do
					if Move(src, dst) then
						moved = true
						break
					end
				end
			end
		end
	until complete or not moved
	return complete
end

function Stack()
	for _, src in ipairs(model) do
		if src.item and src.count < itemStacks[src.item] and src.item ~= src.targetItem then
			for _, dst in ipairs(model) do
				if dst ~= src and dst.item and dst.item == src.item and dst.count < itemStacks[dst.item] and dst.item ~= dst.targetItem then
					if Move(src, dst) then
						return
					end
				end
			end
		end
	end
end

do
	local counts

	local function insert(t, v)
		if SortBagsRightToLeft then
			tinsert(t, v)
		else
			tinsert(t, 1, v)
		end
	end

	local function assign(slot, item)
		if counts[item] > 0 then
			local count
			if SortBagsRightToLeft and mod(counts[item], itemStacks[item]) ~= 0 then
				count = mod(counts[item], itemStacks[item])
			else
				count = min(counts[item], itemStacks[item])
			end
			slot.targetItem = item
			slot.targetCount = count
			counts[item] = counts[item] - count
			return true
		end
	end

	function Initialize()
		model, counts, itemStacks, itemClasses, itemSortKeys = {}, {}, {}, {}, {}

		for _, container in ipairs(CONTAINERS) do
			local class = ContainerClass(container)
			for position = 1, GetContainerNumSlots(container) do
				local slot = {container=container, position=position, class=class}
				local item = Item(container, position)
				if item then
					local _, count, locked = GetContainerItemInfo(container, position)
					if locked then
						return false
					end
					slot.item = item
					slot.count = count
					counts[item] = (counts[item] or 0) + count
				end
				insert(model, slot)
			end
		end

		local free = {}
		for item, count in pairs(counts) do
			local stacks = ceil(count / itemStacks[item])
			free[item] = stacks
			if itemClasses[item] then
				free[itemClasses[item]] = (free[itemClasses[item]] or 0) + stacks
			end
		end
		for _, slot in ipairs(model) do
			if slot.class and free[slot.class] then
				free[slot.class] = free[slot.class] - 1
			end
		end

		local items = {}
		for item in pairs(counts) do
			tinsert(items, item)
		end
		sort(items, function(a, b) return LT(itemSortKeys[a], itemSortKeys[b]) end)

		for _, slot in ipairs(model) do
			if slot.class then
				for _, item in ipairs(items) do
					if itemClasses[item] == slot.class and assign(slot, item) then
						break
					end
				end
			else
				for _, item in ipairs(items) do
					if (not itemClasses[item] or free[itemClasses[item]] > 0) and assign(slot, item) then
						if itemClasses[item] then
							free[itemClasses[item]] = free[itemClasses[item]] - 1
						end
						break
					end
				end
			end
		end
		return true
	end
end

function ContainerClass(container)
	if container ~= 0 and container ~= BANK_CONTAINER then
		local name = GetBagName(container)
		if name then
			for class, info in pairs(CLASSES) do
				for _, itemID in pairs(info.containers) do
					if name == GetItemInfo(itemID) then
						return class
					end
				end
			end
		end
	end
end

function Item(container, position)
	local link = GetContainerItemLink(container, position)
	if link then
		local _, _, itemID, enchantID, suffixID, uniqueID = strfind(link, 'item:(%d+):(%d*):%d*:%d*:%d*:%d*:(%-?%d*):(%-?%d*)')
		itemID = tonumber(itemID)
		local itemName, _, quality, _, _, _, _, stack, slot, _, sellPrice, classId, subClassId = GetItemInfo('item:' .. itemID)
		local charges, usable, soulbound, quest, conjured, mount = TooltipInfo(container, position)
		local sortKey = {}

		-- hearthstone
		if itemID == 6948 or itemID == 184871 then
			tinsert(sortKey, 1)

		-- mounts
		elseif mount then
			tinsert(sortKey, 2)

		-- special items
		elseif SPECIAL[itemID] then
			tinsert(sortKey, 3)

		-- key items
		elseif KEYS[itemID] then
			tinsert(sortKey, 4)

		-- tools
		elseif TOOLS[itemID] then
			tinsert(sortKey, 5)

		-- soul shards
		elseif itemID == 6265 then
			tinsert(sortKey, 13)

		-- conjured items
		elseif conjured then
			tinsert(sortKey, 14)

		-- soulbound items
		elseif soulbound then
			tinsert(sortKey, 6)

		-- reagents
		elseif classId == 9 then
			tinsert(sortKey, 7)

		-- quest items
		elseif quest then
			tinsert(sortKey, 9)

		-- consumables
		elseif usable and classId ~= 1 and classId ~= 2 and classId ~= 8 or classId == 4 then
			tinsert(sortKey, 8)

		-- higher quality
		elseif quality > 1 then
			tinsert(sortKey, 10)

		-- common quality
		elseif quality == 1 then
			tinsert(sortKey, 11)
			tinsert(sortKey, -sellPrice)

		-- junk
		elseif quality == 0 then
			tinsert(sortKey, 12)
			tinsert(sortKey, sellPrice)
		end

		tinsert(sortKey, classId)
		tinsert(sortKey, slot)
		tinsert(sortKey, subClassId)
		tinsert(sortKey, -quality)
		tinsert(sortKey, itemName)
		tinsert(sortKey, itemID)
		tinsert(sortKey, (SortBagsRightToLeft and 1 or -1) * charges)
		tinsert(sortKey, suffixID)
		tinsert(sortKey, enchantID)
		tinsert(sortKey, uniqueID)

		local key = format('%s:%s:%s:%s:%s:%s', itemID, enchantID, suffixID, uniqueID, charges, (soulbound and 1 or 0))

		itemStacks[key] = stack
		itemSortKeys[key] = sortKey

		for class, info in pairs(CLASSES) do
			if info.items[itemID] then
				itemClasses[key] = class
				break
			end
		end

		return key
	end
end