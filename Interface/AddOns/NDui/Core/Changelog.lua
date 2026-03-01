local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新oUF模块；",
	"移除部分失效的功能；",
	"私有光环添加部分选项；",
	"界面美化更新，修正部分污染的情况；",
	"添加内置伤害统计贴附功能；",
	"添加内置冷却监控居中排列功能；",
	"团队框体的过滤选项更新；",
	"恢复团队框体边角指示器功能；",
	"恢复技能缺失提示功能；",
	"添加不同模式的聊天窗口的缩写；",
	"启用友方姓名板名字模式时会开启职业颜色；",
	"修正部分因秘密值导致的报错；",
	"更新鼠标提示模块；",
	"姓名板的法术过滤更新；",
	"修正邮箱助手的公会计算；",
	"姓名板名字模式下公会名字过程会被缩略；",
	"修正头像框体的背景颜色；",
	"调整酒仙酒池在个人资源条下的锚点；",
	"移除目标快速标记功能；",
	"地图迷雾数据更新；",
	"修正充能施法条的显示；",
	"部分反馈的问题调整；",
	"控制台及本地文本更新。",
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
		B.CreateFS(f, 14, n..". "..t, false, "TOPLEFT", 15, -(50 + offset))
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