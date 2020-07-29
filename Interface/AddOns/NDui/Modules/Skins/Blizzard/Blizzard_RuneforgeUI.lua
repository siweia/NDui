local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_RuneforgeUI"] = function()
	local frame = RuneforgeFrame

	B.Reskin(frame.CreateFrame.CraftItemButton)
	B.Reskin(frame.CreateFrame.CloseButton)
end