local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local S = B:GetModule("Skins")

local _G = getfenv(0)

function S:PostalSkin()
	if not F then return end
	if not IsAddOnLoaded("Postal") then return end
	if not PostalOpenAllButton then return end -- update your postal

	F.Reskin(PostalSelectOpenButton)
	F.Reskin(PostalSelectReturnButton)
	F.Reskin(PostalOpenAllButton)
	F.ReskinArrow(Postal_ModuleMenuButton, "down")
	F.ReskinArrow(Postal_OpenAllMenuButton, "down")
	F.ReskinArrow(Postal_BlackBookButton, "down")
	for i = 1, 7 do
		local checkbox = _G["PostalInboxCB"..i]
		F.ReskinCheck(checkbox)
	end

	Postal_ModuleMenuButton:ClearAllPoints()
	Postal_ModuleMenuButton:SetPoint("RIGHT", MailFrame.CloseButton, "LEFT", -2, 0)
	Postal_OpenAllMenuButton:SetPoint("LEFT", PostalOpenAllButton, "RIGHT", 2, 0)
	Postal_BlackBookButton:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 2, 0)
end