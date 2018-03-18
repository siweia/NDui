local B, C, L, DB = unpack(select(2, ...))
if DB.Client ~= "zhCN" then return end

local hx = {
	"Aurora部分模块调整；",
	"更新部分法术；",
	"图腾和雕像现在是右键点击摧毁；",
	"姓名板调整；",
	"控制台及本地文本调整；",
	"头像的相关法术图标整理；",
	"小地图旁的debuff现在支持类型边框的显示；",
	"更正竞技场框体的阵营图标；",
	"鼠标提示信息调整；",
	"大量代码整理；",
	"添加鸟德和奥法的buff缺失提醒；",
	"你可以在附加控制台关闭特定分组的技能监视；",
	"技能监视现在也通过/mm移动；",
	"团队框体点击施法现在支持宏。",
}

local function changelog()
	local f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetScale(1.2)
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.CreateBD(f)
	B.CreateTex(f)
	B.CreateFS(f, 30, "NDui", true, "TOPLEFT", 10, 25)
	B.CreateFS(f, 14, DB.Version, true, "TOPLEFT", 90, 12)
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
	local close = B.CreateButton(f, 20, 20, "X")
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

NDui:EventFrame{"PLAYER_ENTERING_WORLD"}:SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()
	if HelloWorld then return end
	if not NDuiADB["Changelog"] then NDuiADB["Changelog"] = {} end

	local old1, old2 = string.split(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = string.split(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end
end)

SlashCmdList["NDUICHANGELOG"] = function()
	if not NDuiChangeLog then changelog() else NDuiChangeLog:Show() end
end
SLASH_NDUICHANGELOG1 = '/ncl'