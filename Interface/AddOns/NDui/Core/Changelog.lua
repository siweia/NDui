local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"界面美化更新；",
	"Postal美化更新；",
	"防止MerInspect的面板乱跑；",
	"添加部分帮助提示；",
	"当你指向装备栏时，鼠标提示信息会依据你展开的可选装备移动；",
	"增益指示器添加一个自动过滤的方案；",
	"修正副本减益不显示的问题；",
	"韩文文本更新；",
	"修正DK寒冬号角和战士攻强的缺失提示；",
	"Details美化更新，箭头增加至头3个窗口；",
	"装备卖价显示调整；",
	"可移动面板列表调整，启用RXPGuides时禁用角色面板移动；",
	"专业快捷标签添加铭文专业；",
	"修正姓名板副坦仇恨染色失效的问题；",
	"修正上载具后连击点的报错；",
	"开启成就截图时同时播放成就提示音；",
	"LibHealComm及边角指示器更新；",
	"右键菜单交互色块添加密语；",
	"Shift+左键点击任务列表可发送选中的任务名称；",
	"聊天栏超链接快捷提示添加雕文、货币及成就；",
	"修正合并Buff图标的尺寸RL后失效的问题；",
	"满级技能治疗预估失效的问题，等暴雪自己在线更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	local majorVersion = gsub(DB.Version, "%.%d+$", ".0")

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, majorVersion.." "..L["Changelog"], true, "TOP", 0, -10)
	B.CreateWatermark(f)

	local ll = B.SetGradient(f, "H", .7, .7, .7, 0, .5, 100, C.mult)
	ll:SetPoint("TOP", -50, -35)
	local lr = B.SetGradient(f, "H", .7, .7, .7, .5, 0, 100, C.mult)
	lr:SetPoint("TOP", 50, -35)

	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 14, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 24
	end
	f:SetSize(480, 60 + offset)
	local close = B.CreateButton(f, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

local function compareToShow(event)
	if NDui_Tutorial then return end

	local old1, old2 = strsplit(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = strsplit(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end

	B:UnregisterEvent(event, compareToShow)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

SlashCmdList["NDUICHANGELOG"] = changelog
SLASH_NDUICHANGELOG1 = "/ncl"