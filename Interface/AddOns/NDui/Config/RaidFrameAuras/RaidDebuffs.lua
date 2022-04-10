local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

--[[
	RaidFrame debuffs for Vanilla
	"raid" spells only available in Raids
	"other" spells won't work in Raids
	[spellID] = priority
	priority limit in 1-6
]]
local list = {
	-- 世界BOSS
	[21056] = 2,	-- 卡扎克的印记
	[24814] = 2,	-- 渗漏之雾
}

module:AddRaidDebuffs(list)