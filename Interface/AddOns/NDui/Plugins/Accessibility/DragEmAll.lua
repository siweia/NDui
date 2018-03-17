local B, C, L, DB = unpack(select(2, ...))
--------------------------
-- DragEmAll, by emelio
-- NDui MOD
--------------------------
local _G = _G
local addon = NDui:EventFrame{"PLAYER_LOGIN", "ADDON_LOADED"}
local frames = {
	-- ["FrameName"] = true (the parent frame should be moved) or false (the frame itself should be moved)
	-- for child frames (i.e. frames that don't have a name, but only a parentKey="XX" use
	-- "ParentFrameName.XX" as frame name. more than one level is supported, e.g. "Foo.Bar.Baz")

	-- Blizz Frames
	["AddonList"] = false,
	["AudioOptionsFrame"] = false,
	["DressUpFrame"] = false,
	["FriendsFrame"] = false,
	["GameMenuFrame"] = false,
	["GossipFrame"] = false,
	["GuildInviteFrame"] = false,
	["GuildRegistrarFrame"] = false,
	["HelpFrame"] = false,
	["InterfaceOptionsFrame"] = false,
	["ItemTextFrame"] = false,
	["LootFrame"] = false,
	["MailFrame"] = false,
	["MerchantFrame"] = false,
	["OpenMailFrame"] = false,
	["PaperDollFrame"] = true,
	["PetitionFrame"] = false,
	["PetStableFrame"] = false,
	["PVEFrame"] = false,
	["QuestFrame"] = false,
	["QuestLogPopupDetailFrame"] = false,
	["RaidParentFrame"] = false,
	["ReputationFrame"] = true,
	["ScrollOfResurrectionSelectionFrame"] = false,
	["SendMailFrame"] = true,
	["SpellBookFrame"] = false,
	["SplashFrame"] = false,
	["StackSplitFrame"] = false,
	["StaticPopup1"] = false,
	["TabardFrame"] = false,
	["TaxiFrame"] = false,
	["TokenFrame"] = true,
	["TradeFrame"] = false,
	["TutorialFrame"] = false,
	["VideoOptionsFrame"] = false,
	["WorldStateScoreFrame"] = false,

	-- Other AddOns
	["BaudErrorFrame"] = false,
}

-- Frame Existing Check
local function IsFrameExists()
	for k in pairs(frames) do
		local name = _G[k]
		if not name then print("Frame not found:", k) end
	end
end

-- Frames provided by load on demand addons, hooked when the addon is loaded.
local lodFrames = {
	-- AddonName = { list of frames, same syntax as above }
	Blizzard_AchievementUI		= { ["AchievementFrame"] = false, ["AchievementFrameHeader"] = true, ["AchievementFrameCategoriesContainer"] = "AchievementFrame", ["AchievementFrame.searchResults"] = false },
	Blizzard_AdventureMap		= { ["AdventureMapQuestChoiceDialog"] = false },
	Blizzard_AlliedRacesUI		= { ["AlliedRacesFrame"] = false },
	Blizzard_ArchaeologyUI		= { ["ArchaeologyFrame"] = false },
	Blizzard_ArtifactUI			= { ["ArtifactFrame"] = false, ["ArtifactRelicForgeFrame"] = false },
	Blizzard_AuctionUI			= { ["AuctionFrame"] = false },
	Blizzard_BarbershopUI		= { ["BarberShopFrame"] = false },
	Blizzard_BindingUI			= { ["KeyBindingFrame"] = false },
	Blizzard_BlackMarketUI		= { ["BlackMarketFrame"] = false },
	Blizzard_Calendar			= { ["CalendarFrame"] = false, ["CalendarCreateEventFrame"] = true },
	Blizzard_ChallengesUI		= { ["ChallengesKeystoneFrame"] = false },
	Blizzard_Collections		= { ["WardrobeFrame"] = false, ["WardrobeOutfitEditFrame"] = false },
	Blizzard_EncounterJournal	= { ["EncounterJournal"] = false },
	Blizzard_FlightMap			= { ["FlightMapFrame"] = false },
	Blizzard_GarrisonUI			= { ["GarrisonLandingPage"] = false, ["GarrisonMissionFrame"] = false, ["GarrisonBuildingFrame"] = false, ["GarrisonRecruiterFrame"] = false, ["GarrisonRecruitSelectFrame"] = false, ["GarrisonCapacitiveDisplayFrame"] = false, ["GarrisonShipyardFrame"] = false,},
	Blizzard_GMSurveyUI			= { ["GMSurveyFrame"] = false },
	Blizzard_GuildBankUI		= { ["GuildBankFrame"] = false, ["GuildBankEmblemFrame"] = true },
	Blizzard_GuildUI			= { ["GuildFrame"] = false, ["GuildRosterFrame"] = true, ["GuildFrame.TitleMouseover"] = true },
	Blizzard_InspectUI			= { ["InspectFrame"] = false, ["InspectPVPFrame"] = true, ["InspectTalentFrame"] = true },
	Blizzard_ItemSocketingUI	= { ["ItemSocketingFrame"] = false },
	Blizzard_ItemUpgradeUI		= { ["ItemUpgradeFrame"] = false },
	Blizzard_LookingForGuildUI	= { ["LookingForGuildFrame"] = false },
	Blizzard_MacroUI			= { ["MacroFrame"] = false },
	Blizzard_ObliterumUI		= { ["ObliterumForgeFrame"] = false },
	Blizzard_OrderHallUI		= { ["OrderHallMissionFrame"] = false, ["OrderHallTalentFrame"] = false, },
	Blizzard_TalentUI			= { ["PlayerTalentFrame"] = false, ["PVPTalentPrestigeLevelDialog"] = false, },
	Blizzard_TimeManager		= { ["TimeManagerFrame"] = false },
	Blizzard_TokenUI			= { ["TokenFrame"] = true },
	Blizzard_TradeSkillUI		= { ["TradeSkillFrame"] = false },
	Blizzard_TrainerUI			= { ["ClassTrainerFrame"] = false },
	Blizzard_VoidStorageUI		= { ["VoidStorageFrame"] = false, ["VoidStorageBorderFrameMouseBlockFrame"] = "VoidStorageFrame" },
	Blizzard_WarboardUI			= { ["WarboardQuestChoiceFrame"] = false },
}

local parentFrame = {}
local hooked = {}

function addon:PLAYER_LOGIN()
	self:HookFrames(frames)
	IsFrameExists()
end

function addon:ADDON_LOADED(name)
	local frameList = lodFrames[name]
	if frameList then
		self:HookFrames(frameList)
	end
end

local function MouseDownHandler(frame, button)
	frame = parentFrame[frame] or frame
	if frame and button == "LeftButton" then
		frame:StartMoving()
		frame:SetUserPlaced(false)
	end
end

local function MouseUpHandler(frame, button)
	frame = parentFrame[frame] or frame
	if frame and button == "LeftButton" then
		frame:StopMovingOrSizing()
	end
end

function addon:HookFrames(list)
	for name, child in pairs(list) do
		self:HookFrame(name, child)
	end
end

function addon:HookFrame(name, moveParent)
	-- find frame
	-- name may contain dots for children, e.g. ReforgingFrame.InvisibleButton
	local frame = _G
	for s in string.gmatch(name, "%w+") do
		if frame then
			frame = frame[s]
		end
	end
	-- check if frame was found
	if frame == _G then
		frame = nil
	end

	local parent
	if frame and not hooked[name] then
		if moveParent then
			if type(moveParent) == "string" then
				parent = _G[moveParent]
			else
				parent = frame:GetParent()
			end
			if not parent then
				print("Parent frame not found: " .. name)
				return
			end
			parentFrame[frame] = parent
		end
		if parent then
			parent:SetMovable(true)
			parent:SetClampedToScreen(false)
		end
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetClampedToScreen(false)
		self:HookScript(frame, "OnMouseDown", MouseDownHandler)
		self:HookScript(frame, "OnMouseUp", MouseUpHandler)
		hooked[name] = true
	end
end

function addon:HookScript(frame, script, handler)
	if not frame.GetScript then return end
	local oldHandler = frame:GetScript(script)
	if oldHandler then
		frame:SetScript(script, function(...)
			handler(...)
			oldHandler(...)
		end)
	else
		frame:SetScript(script, handler)
	end
end

addon:SetScript("OnEvent", function(f, e, ...) f[e](f, ...) end)