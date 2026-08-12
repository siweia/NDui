local _, ns = ...
local oUF = ns.oUF

oUF.Enum = {}

oUF.Enum.SelectionType = {
	-- https://warcraft.wiki.gg/wiki/API_UnitSelectionType
	-- only keeping the useful ones (i.e. no spectator or housing stuff)
	Hostile = 0,
	Unfriendly = 1,
	Neutral = 2,
	Friendly = 3,
	PlayerSimple = 4,
	PlayerExtended = 5,
	Party = 6,
	PartyPvP = 7,
	Friend = 8,
	Dead = 9,
	-- CommentatorBattleground1 = 10,
	-- CommentatorBattleground2 = 11,
	-- Self = 12,
	PartyPvPInBattleground = 13,
	-- CommentatorArena1 = 14,
	-- CommentatorArena2 = 15,
	RecentAlly = 16,
	-- rest of the types are for housing, irrelevant for us
}
