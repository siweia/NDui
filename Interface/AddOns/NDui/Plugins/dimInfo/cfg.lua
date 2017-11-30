-------------------------
-- dimInfo, by Loshine
-- NDui MOD
-------------------------
local _, ns = ...
local cfg = CreateFrame("Frame")
if not diminfo then diminfo = {} end

-- Top infobar
cfg.Friends = true
cfg.FriendsPoint = {"TOPLEFT", UIParent, 100, -4}

cfg.System = true
cfg.SystemPoint = {"TOPLEFT", UIParent, 190, -4}

cfg.Memory = true
cfg.MemoryPoint = {"TOPLEFT", UIParent, 310, -4}
cfg.MaxAddOns = 20

cfg.Positions = true
cfg.PositionsPoint = {"TOPLEFT", UIParent, 390, -4}

-- Bottomright infobar
cfg.Spec = true
cfg.SpecPoint = {"BOTTOMRIGHT", UIParent, -310, 5}

cfg.Durability = true
cfg.DurabilityPoint = {"BOTTOM", UIParent, "BOTTOMRIGHT", -230, 5}

cfg.Gold = true
cfg.GoldPoint = {"BOTTOM", UIParent, "BOTTOMRIGHT", -125, 5}

cfg.Time = true
cfg.TimePoint = {"BOTTOMRIGHT", UIParent, -15, 5}

-- Fonts and Colors
cfg.Fonts = {STANDARD_TEXT_FONT, 13, "OUTLINE"}

ns.cfg = cfg

-- init
local init = CreateFrame("Frame")

local classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] 
init.Colored = ("|cff%.2x%.2x%.2x"):format(classc.r * 255, classc.g * 255, classc.b * 255)
init.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:-1:512:512:12:66:230:307|t "
init.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:-1:512:512:12:66:333:411|t "
init.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:-1:512:512:12:66:127:204|t "

init.gradient = function(perc)
	perc = perc > 1 and 1 or perc < 0 and 0 or perc -- Stay between 0-1
	local seg, relperc = math.modf(perc*2)
	local r1,g1,b1,r2,g2,b2 = select(seg*3+1,1,0,0,1,1,0,0,1,0,0,0,0) -- R -> Y -> G
	local r,g,b = r1+(r2-r1)*relperc,g1+(g2-g1)*relperc,b1+(b2-b1)*relperc
	return format("|cff%02x%02x%02x",r*255,g*255,b*255),r,g,b
end

ns.init = init