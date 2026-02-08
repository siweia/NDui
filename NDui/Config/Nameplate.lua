local _, ns = ...
local _, C = unpack(ns)

-- 法术白名单
C.WhiteList = {
	-- Buffs
	[642]	= true,	-- 圣盾术
	[1022]	= true,	-- 保护之手
	[23920]	= true,	-- 法术反射
	[45438]	= true,	-- 寒冰屏障
	-- Debuffs
	[2094]	= true,	-- 致盲
}

-- 法术黑名单
C.BlackList = {
	[15407] = true, -- 精神鞭笞
}

-- 特殊单位的染色列表
C.CustomUnits = {
	--[120651] = true, -- 爆炸物
}

-- 显示能量值的单位
C.PowerUnits = {
	--[155432] = true, -- 魔力使者
}

-- 重要读条高亮
C.MajorSpells = {
	--[27072] = true,	-- 寒冰箭
}