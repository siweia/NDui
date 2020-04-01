local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local _G = getfenv(0)

function S:PostalSkin()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end
	if not IsAddOnLoaded("Postal") then return end
	if not PostalOpenAllButton then return end -- update your postal

	B.Reskin(PostalSelectOpenButton)
	B.Reskin(PostalSelectReturnButton)
	B.Reskin(PostalOpenAllButton)
	B.ReskinArrow(Postal_ModuleMenuButton, "down")
	B.ReskinArrow(Postal_OpenAllMenuButton, "down")
	B.ReskinArrow(Postal_BlackBookButton, "down")
	for i = 1, 7 do
		B.ReskinCheck(_G["PostalInboxCB"..i])
	end

	Postal_ModuleMenuButton:ClearAllPoints()
	Postal_ModuleMenuButton:SetPoint("RIGHT", MailFrame.CloseButton, "LEFT", -2, 0)
	Postal_OpenAllMenuButton:SetPoint("LEFT", PostalOpenAllButton, "RIGHT", 2, 0)
	Postal_BlackBookButton:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 2, 0)
end