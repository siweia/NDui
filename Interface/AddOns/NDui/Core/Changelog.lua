local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修正初始化失败的问题；",
	"背包过滤更新，添加选项以开关各项过滤；",
	"副本难度提示修正；",
	"界面美化更新；",
	"关闭美化暴雪自带插件的选项调整；",
	"团队工具的标记按钮修正；",
	"更新大量技能监控；",
	"信息条时间模块添加小幻象日常；",
	"背包及角色面板添加腐化装备显示；",
	"小队框体添加特殊能量数值显示；",
	"头像各框架调整；",
	"个人资源条调整；",
	"姓名板的法术图标位置微调；",
	"更新姓名板特殊单位染色列表；",
	"姓名板的任务标记调整，降低百分比进度的优先级；",
	"登录时先尝试重新打开Details窗口；",
	"启用bigwigs皮肤时强制启用NDui风格；",
	"边角指示器调整，队伍调整时刷新状态；",
	"修复DH的特质只显示第一层的问题；",
	"修复鼠标提示开启指向时的一处错误；",
	"调整大于小时的buff显示；",
	"德鲁伊在猫和熊形态下也将显示未满的额外能量条；",
	"合剂检查移除低级合剂；",
	"添加按钮以屏蔽WorldQuestTracker等垃圾插件的自动邀请；",
	"控制台及本地文本更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetScale(1.2)
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 30, "NDui", true, "TOPLEFT", 10, 26)
	B.CreateFS(f, 14, DB.Version, true, "TOPLEFT", 90, 14)
	B.CreateFS(f, 16, L["Changelog"], true, "TOP", 0, -10)
	local ll = CreateFrame("Frame", nil, f)
	ll:SetPoint("TOP", -50, -35)
	B.CreateGF(ll, 100, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, f)
	lr:SetPoint("TOP", 50, -35)
	B.CreateGF(lr, 100, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")
	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 12, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 20
	end
	f:SetSize(400, 60 + offset)
	local close = B.CreateButton(f, 16, 16, "X")
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