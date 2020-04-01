local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local pairs = pairs

local function ReskinWA()
	local function Skin_WeakAuras(f, fType)
		if fType == "icon" then
			if not f.styled then
				f.icon:SetTexCoord(unpack(DB.TexCoord))
				f.icon.SetTexCoord = B.Dummy
				f.bg = B.SetBD(f)
				f.bg.__icon = f.icon
				f.bg:HookScript("OnUpdate", function(self)
					self:SetAlpha(self.__icon:GetAlpha())
					if self.Shadow then
						self.Shadow:SetAlpha(self.__icon:GetAlpha())
					end
				end)

				f.styled = true
			end
		elseif fType == "aurabar" then
			if not f.styled then
				f.bg = B.SetBD(f.bar)
				f.bg:SetFrameLevel(0)
				f.icon:SetTexCoord(unpack(DB.TexCoord))
				f.icon.SetTexCoord = B.Dummy
				f.iconFrame:SetAllPoints(f.icon)
				B.SetBD(f.iconFrame)

				f.styled = true
			end
		end
	end

	local regionTypes = WeakAuras.regionTypes
	local Create_Icon, Modify_Icon = regionTypes.icon.create, regionTypes.icon.modify
	local Create_AuraBar, Modify_AuraBar = regionTypes.aurabar.create, regionTypes.aurabar.modify

	regionTypes.icon.create = function(parent, data)
		local region = Create_Icon(parent, data)
		Skin_WeakAuras(region, "icon")
		return region
	end

	regionTypes.aurabar.create = function(parent)
		local region = Create_AuraBar(parent)
		Skin_WeakAuras(region, "aurabar")
		return region
	end

	regionTypes.icon.modify = function(parent, region, data)
		Modify_Icon(parent, region, data)
		Skin_WeakAuras(region, "icon")
	end

	regionTypes.aurabar.modify = function(parent, region, data)
		Modify_AuraBar(parent, region, data)
		Skin_WeakAuras(region, "aurabar")
	end

	for weakAura in pairs(WeakAuras.regions) do
		local regions = WeakAuras.regions[weakAura]
		if regions.regionType == "icon" or regions.regionType == "aurabar" then
			Skin_WeakAuras(regions.region, regions.regionType)
		end
	end
end

S:LoadWithAddOn("WeakAuras", "WeakAuras", ReskinWA)