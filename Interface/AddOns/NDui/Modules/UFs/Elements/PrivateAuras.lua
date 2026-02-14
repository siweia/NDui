local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

function UF:CreatePrivateAuras(self)
	if not C.db["UFs"]["PrivateAuras"] then return end

	local element = CreateFrame("Frame", nil, UIParent)
	element:SetPoint("BOTTOMLEFT", self.Health, 2, 2)
	element:SetSize(100, 30)

	UF:UpdatePrivateAuras(element, false)
	self.PrivateAuras = element
end

function UF:UpdatePrivateAuras(element, force)
	local db = C.db["UFs"]
	element.size = db.PrivateSize
	element.spacing = 3
	element.borderScale = element.size / 16
	element.initialAnchor = "BOTTOMLEFT"
	element.growthX = "RIGHT"
	element.growthY = "UP"
	element.disableCooldown = not db.CDAnimation
	element.disableCooldownText = not db.CDText

	if force and element.ForceUpdate then
		element:ForceUpdate()
	end
end