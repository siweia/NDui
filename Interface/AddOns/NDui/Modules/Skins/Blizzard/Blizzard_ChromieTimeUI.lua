local _, ns = ...
local B, C, L, DB = unpack(ns)

--/run LoadAddOn"Blizzard_ChromieTimeUI" ChromieTimeFrame:Show()
C.themes["Blizzard_ChromieTimeUI"] = function()
	local frame = ChromieTimeFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.Reskin(frame.SelectButton)

	local header = frame.Title
	header:DisableDrawLayer("BACKGROUND")
	header.Text:SetFontObject(SystemFont_Huge1)
	B.CreateBDFrame(header, .25)

	frame.CurrentlySelectedExpansionInfoFrame.Name:SetTextColor(1, .8, 0)
	frame.CurrentlySelectedExpansionInfoFrame.Description:SetTextColor(1, 1, 1)
end