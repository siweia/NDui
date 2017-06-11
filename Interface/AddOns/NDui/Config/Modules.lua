-- Configure 配置页面
local _, C, _, _ = unpack(select(2, ...))

-- BUFF/DEBUFF相关
C.Auras = {
	IconSize		= 32,											-- BUFF图标大小
	IconsPerRow		= 14,											-- BUFF每行个数
	Spacing			= 6,											-- BUFF图标间距
	BuffPos			= {"TOPRIGHT", Minimap, "TOPLEFT", -10, -5},	-- BUFF位置

	BHPos			= {"CENTER", UIParent, "CENTER", 0, -200},		-- 血DK助手默认位置
	StaggerPos		= {"CENTER", UIParent, "CENTER", 0, -220},		-- 坦僧工具默认位置
	TotemsPos		= {"CENTER", UIParent, "CENTER", 0, -190},		-- 图腾助手默认位置
	MarksmanPos		= {"CENTER", UIParent, "CENTER", 0, -190},		-- 射击猎助手默认位置
	FamiliarPos		= {"BOTTOMLEFT", UIParent, 480, 270},			-- 奥法魔宠默认位置
	StatuePos		= {"BOTTOMLEFT", UIParent, 480, 270},			-- 武僧雕像默认位置
}

-- 头像相关
C.UFs = {
	Playercb		= {"BOTTOM", UIParent, "BOTTOM", 16, 175},		-- 玩家施法条默认位置
	PlayercbSize	= {300, 20},									-- 玩家施法条尺寸
	Targetcb		= {"BOTTOM", UIParent, "BOTTOM", 16, 335},		-- 目标施法条默认位置
	TargetcbSize	= {280, 20},									-- 目标施法条尺寸
	Focuscb			= {"CENTER", UIParent, "CENTER", 10, 200},		-- 焦点施法条默认位置
	FocuscbSize		= {320, 20},									-- 焦点施法条尺寸

	PlayerPos		= {"TOPRIGHT", UIParent, "BOTTOM", -200, 300},	-- 玩家框体默认位置
	TargetPos		= {"TOPLEFT", UIParent, "BOTTOM", 200, 300},	-- 目标框体默认位置
	ToTPos			= {"BOTTOM", UIParent, "BOTTOM", 136, 241},		-- 目标的目标框体默认位置
	PetPos			= {"BOTTOM", UIParent, "BOTTOM", -136, 241},	-- 宠物框体默认位置
	FocusPos		= {"LEFT", UIParent, "LEFT", 5, -150},			-- 焦点框体默认位置
	FoTPos			= {"LEFT", UIParent, "LEFT", 210, -150},		-- 焦点目标框体默认位置

	BarPoint		= {"TOPLEFT", 12, 4},							-- 资源条位置（以自身头像为基准）
	BarSize			= {150, 5},										-- 资源条的尺寸（宽，长）
	BarMargin		= 3,											-- 资源条间隔
}

-- 小地图
C.Minimap = {
	Pos				= {"TOPRIGHT", UIParent, "TOPRIGHT", -7, -7},	-- 小地图位置
}

-- 美化及皮肤
C.Skins = {
	MicroMenuPos 	= {"BOTTOM", UIParent, "BOTTOM", 0, 2.5},		-- 微型菜单坐标
	RMPos  			= {"TOP", UIParent, "TOP", 0, 0},				-- 团队工具默认坐标
}

-- 鼠标提示框
C.Tooltips = {
	TipPos 	= {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -55, 230},	-- 鼠标提示框默认位置
}