local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")
local PA = B:GetModule("PrivateAuras")

function UF:CreatePrivateAuras(frame)
	frame.PrivateAuras = CreateFrame("Frame", frame:GetName().."PrivateAuras", frame)
	hooksecurefunc(frame, "UpdateAllElements", UF.UpdatePrivateAuras)
end

function UF.UpdatePrivateAuras(frame)
	if frame.PrivateAuras then
		PA:RemoveAuras(frame.PrivateAuras)

		local db = C.db["UFs"]
		if db then
			PA:SetupPrivateAuras(db, frame.PrivateAuras, frame.unit)
			frame.PrivateAuras:ClearAllPoints()
			frame.PrivateAuras:SetPoint("TOP", frame, "TOP", 0, 0)
			frame.PrivateAuras:SetSize(db.PrivateSize, db.PrivateSize)
		end
	end
end