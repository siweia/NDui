-- Configure 配置页面
local _, ns = ...
local _, C = unpack(ns)

-- BUFF/DEBUFF相关
C.Auras = {
	IconSize		= 32,												-- BUFF及相关职业助手图标大小
	IconsPerRow		= 14,												-- BUFF每行个数
	Spacing			= 5,												-- BUFF图标间距
	BuffPos			= {"TOPRIGHT", Minimap, "TOPLEFT", -15, -5},		-- BUFF默认位置

	BHPos			= {"CENTER", UIParent, "CENTER", 0, -200},			-- 血DK助手默认位置
	StaggerPos		= {"CENTER", UIParent, "CENTER", 0, -220},			-- 坦僧工具默认位置
	TotemsPos		= {"CENTER", UIParent, "CENTER", 0, -190},			-- 图腾助手默认位置
	HunterToolPos	= {"CENTER", UIParent, "CENTER", 0, -190},			-- 生存猎助手默认位置
	FamiliarPos		= {"BOTTOMLEFT", UIParent, 480, 270},				-- 奥法魔宠默认位置
	StatuePos		= {"TOPRIGHT", UIParent, "BOTTOM", -460, 300},		-- 武僧雕像默认位置

	-- 技能监控各组初始位置
	PlayerAuraPos	= {"BOTTOMRIGHT", UIParent, "BOTTOM", -200, 309},	-- 玩家光环分组
	TargetAuraPos 	= {"BOTTOMLEFT", UIParent, "BOTTOM", 200, 309},		-- 目标光环分组
	SpecialPos		= {"BOTTOMRIGHT", UIParent, "BOTTOM", -200, 336},	-- 玩家重要光环分组
	FocusPos		= {"BOTTOMLEFT", UIParent, "LEFT", 5, -130},		-- 焦点光环分组
	CDPos			= {"BOTTOMRIGHT", UIParent, "BOTTOM", -425, 500},	-- 冷却计时分组
	EnchantPos		= {"BOTTOMRIGHT", UIParent, "BOTTOM", -200, 377},	-- 附魔及饰品分组
	RaidBuffPos		= {"CENTER", UIParent, "CENTER", -220, 200},		-- 团队增益分组
	RaidDebuffPos	= {"CENTER", UIParent, "CENTER", 220, 200},			-- 团队减益分组
	WarningPos		= {"BOTTOMLEFT", UIParent, "BOTTOM", 200, 370},		-- 目标重要光环分组
	InternalPos		= {"BOTTOMRIGHT", UIParent, "BOTTOM", -425, 125},	-- 法术内置冷却分组
}

-- 头像相关
C.UFs = {
	Playercb		= {"BOTTOM", UIParent, "BOTTOM", 16, 175},			-- 玩家施法条默认位置
	PlayercbSize	= {300, 20},										-- 玩家施法条尺寸
	Targetcb		= {"BOTTOM", UIParent, "BOTTOM", 16, 335},			-- 目标施法条默认位置
	TargetcbSize	= {280, 20},										-- 目标施法条尺寸
	Focuscb			= {"CENTER", UIParent, "CENTER", 10, 200},			-- 焦点施法条默认位置
	FocuscbSize		= {320, 20},										-- 焦点施法条尺寸

	PlayerPos		= {"TOPRIGHT", UIParent, "BOTTOM", -200, 300},		-- 玩家框体默认位置
	TargetPos		= {"TOPLEFT", UIParent, "BOTTOM", 200, 300},		-- 目标框体默认位置
	ToTPos			= {"BOTTOM", UIParent, "BOTTOM", 136, 241},			-- 目标的目标框体默认位置
	PetPos			= {"BOTTOM", UIParent, "BOTTOM", -136, 241},		-- 宠物框体默认位置
	FocusPos		= {"LEFT", UIParent, "LEFT", 5, -150},				-- 焦点框体默认位置
	FoTPos			= {"LEFT", UIParent, "LEFT", 210, -150},			-- 焦点目标框体默认位置
	PlayerPlate		= {"BOTTOM", UIParent, "BOTTOM", 0, 310},			-- 玩家姓名板默认位置

	BarPoint		= {"TOPLEFT", 12, 4},								-- 资源条位置（以自身头像为基准）
	BarSize			= {150, 5},											-- 资源条的尺寸（宽，长）
	BarMargin		= 3,												-- 资源条间隔
}

-- 小地图
C.Minimap = {
	Pos				= {"TOPRIGHT", UIParent, "TOPRIGHT", -7, -7},		-- 小地图默认位置
}

-- 美化及皮肤
C.Skins = {
	MicroMenuPos 	= {"BOTTOM", UIParent, "BOTTOM", 0, 2.5},			-- 微型菜单默认坐标
	RMPos  			= {"TOP", UIParent, "TOP", 0, 0},					-- 团队工具默认坐标
}

-- 鼠标提示框
C.Tooltips = {
	TipPos 	= {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -55, 230},		-- 鼠标提示框默认位置
}

-- 信息条
C.Infobar = {
	Guild	 		= true,												-- 公会信息
	GuildPos 		= {"TOPLEFT", UIParent, 15, -6},					-- 公会信息位置
	Friends 		= true,												-- 好友模块
	FriendsPos 		= {"TOPLEFT", UIParent, 105, -6},					-- 好友模块位置
	System			= true,												-- 帧数/延迟
	SystemPos		= {"TOPLEFT", UIParent, 190, -6},					-- 帧数/延迟位置
	Memory			= true,												-- 内存占用
	MemoryPos		= {"TOPLEFT", UIParent, 285, -6},					-- 内存占用位置
	MaxAddOns		= 12,												-- 插件信息显示数量
	Location		= true,												-- 区域信息
	LocationPos		= {"TOPLEFT", UIParent, 380, -6},					-- 区域信息位置

	Spec			= true,												-- 天赋专精
	SpecPos			= {"BOTTOMRIGHT", UIParent, -310, 6},				-- 天赋专精位置
	Durability		= true,												-- 耐久度
	DurabilityPos	= {"BOTTOM", UIParent, "BOTTOMRIGHT", -230, 6},		-- 耐久度位置
	Gold			= true,												-- 金币信息
	GoldPos			= {"BOTTOM", UIParent, "BOTTOMRIGHT", -125, 6}, 	-- 金币信息位置
	Time			= true,												-- 时间信息
	TimePos			= {"BOTTOMRIGHT", UIParent, -15, 6},				-- 时间信息位置

	Fonts			= {STANDARD_TEXT_FONT, 13, "OUTLINE"},				-- 字体
}