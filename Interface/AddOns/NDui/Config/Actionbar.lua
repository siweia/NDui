local _, ns = ...
local _, C = unpack(ns)

--[[
	说明：
	如果对lua不了解，请关闭此页面。
	由于战斗中显隐会导致污染以及无法排战场的问题，显隐将只支持鼠标悬停。
	nil为禁用，barFader为启用。修改时注意大小写。
]]

-- 动作条细节调整
local barFader = {						-- 动作条显隐设置
	fadeInAlpha = 1,					-- 显示时的透明度
	fadeInDuration = .3,				-- 显示耗时
	fadeOutAlpha = .1,					-- 渐隐后的透明度
	fadeOutDuration = .8,				-- 渐隐耗时
	fadeOutDelay = .5,					-- 延迟渐隐
}

C.bars = {
	userplaced				= true,		-- 使其可通过游戏内命令移动

	-- BAR1 主动作条（下）
	bar1 = {
		size				= 34,		-- 动作条大小
		fader				= nil,		-- 鼠标悬停显隐
    },
    -- BAR2 主动作条（上）
    bar2 = {
		size           		= 34,		-- 动作条大小
		fader				= nil,		-- 鼠标悬停显隐
    },
    -- BAR3 主动作条两侧
    bar3 = {
		size        	    = 32,		-- 动作条大小
		fader				= nil,		-- 鼠标悬停显隐
    },
    -- BAR4 右边动作条1
    bar4 = {
		size           		= 32,		-- 动作条大小
		fader				= barFader,	-- 鼠标悬停显隐
    },
    -- BAR5 右边动作条2
    bar5 = {
		size				= 32,		-- 动作条大小
		fader				= barFader, -- 鼠标悬停显隐
    },
    -- PETBAR 宠物动作条
    petbar = {
		size	            = 26,		-- 动作条大小
		fader				= nil,		-- 鼠标悬停显隐
    },
    -- STANCE + POSSESSBAR 姿态条
    stancebar = {
		size          		= 30,		-- 动作条大小
		fader				= nil,		-- 鼠标悬停显隐
    },
    -- EXTRABAR 额外动作条
    extrabar = {
		size    	        = 56,		-- 动作条大小
		fader				= nil,		-- 鼠标悬停显隐
    },
    -- VEHICLE EXIT 离开载具按钮
    leave_vehicle 			= {
		size          		= 32,		-- 动作条大小
		fader				= nil,		-- 鼠标悬停显隐
    },
}