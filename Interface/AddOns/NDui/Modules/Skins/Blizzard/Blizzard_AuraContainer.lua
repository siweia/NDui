local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AuraContainer"] = function()
	local borderColor
	if C.db["Skins"]["GreyBD"] then
		borderColor = CreateColor(1, 1, 1, .2)
	else
		borderColor = CreateColor(0, 0, 0, 1)
	end

	-- The aura tooltip is forbidden; style it only through Blizzard's secure inbound interface.
	AuraContainerInbound.SetTooltipBackdrop({
		backdropInfo = {
			bgFile = DB.bdTex,
			edgeFile = DB.bdTex,
			edgeSize = C.mult,
		},
		borderColor = borderColor,
		centerColor = CreateColor(0, 0, 0, .7),
		anchorOffsets = {
			left = C.mult,
			right = -C.mult,
			top = -C.mult,
			bottom = C.mult,
		},
	})
end
