local L, icons, Workflow, Settings = PC.L, PC.icons, PC.Workflow, PC.Settings

local mainFrame = CreateFrame("Frame", "PartyMarkers_MainFrame", UIParent)
PC._mainFrame = mainFrame

local StateNone, StateWorkflow, StateSettings = 0, 1, 2
local state = StateNone
local workflowWasVisible = false

local workflow = Workflow:Create()
local settings = Settings:Create()


-----------------------------------------------------------------------------------------------------------------------


local function ApplySettings()
	workflow:SetData(settings.list:GetData())
end

local function CreateUi()
	if not PartyMarkersStorage then PartyMarkersStorage = {}; end
	if not PartyMarkersStorage["point"] then PartyMarkersStorage["point"] = "CENTER"; end
	if not PartyMarkersStorage["x"] then PartyMarkersStorage["x"] = 0; end
	if not PartyMarkersStorage["y"] then PartyMarkersStorage["y"] = 0; end
	if not PartyMarkersStorage["width"] then PartyMarkersStorage["width"] = 150; end
	if not PartyMarkersStorage["height"] then PartyMarkersStorage["height"] = 200; end
	if not PartyMarkersStorage["profiles"] then PartyMarkersStorage["profiles"] = {}; end
	if not PartyMarkersStorage["profileIndex"] then PartyMarkersStorage["profileIndex"] = 0; end
	if not PartyMarkersStorage["data"] then PartyMarkersStorage["data"] = {}; end

	-- mainFrame:SetFrameStrata("MEDIUM")
	-- mainFrame:SetFrameLevel(50)
	mainFrame:Show()
	mainFrame:SetSize(PartyMarkersStorage["width"], PartyMarkersStorage["height"])
	mainFrame:SetPoint(PartyMarkersStorage["point"], PartyMarkersStorage["x"], PartyMarkersStorage["y"])
	
	mainFrame:SetMovable(true)
	mainFrame:SetResizable(true)

	local header = CreateFrame("Frame", nil, mainFrame)
	header:Show()
	header:SetPoint("TOPLEFT")
	header:SetPoint("RIGHT")
	header:SetHeight(17)

	header:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() then mainFrame:StartMoving();
			else
				if state == StateNone then
					workflow:Show()
					state = StateWorkflow
				elseif state == StateWorkflow then
					workflow:Hide()
					state = StateNone
				elseif state == StateSettings then
					settings:Hide()
					ApplySettings()
					workflow:Show()
					state = StateWorkflow
				end
			end
		end
	end)
	header:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			mainFrame:StopMovingOrSizing();

			local point,_,_, x, y = mainFrame:GetPoint()
			PartyMarkersStorage["point"] = point
			PartyMarkersStorage["x"] = x
			PartyMarkersStorage["y"] = y
		end
	end)
	
	local texture = header:CreateTexture()
	texture:SetAllPoints()
	texture:SetTexture(0.05, 0.05, 0.05, 1)

	local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	title:SetPoint("TOPLEFT", 5, -1)
	title:SetText("PartyMarkers")

	local settingsButton = CreateFrame("Button", "PartyMarkers_SettingsButton", header)
	settingsButton:SetScript("OnClick", function() 
		if state == StateNone then
			workflowWasVisible = false
			settings:Show()
			state = StateSettings
		elseif state == StateWorkflow then
			workflowWasVisible = true
			workflow:Hide()
			settings:Show()
			state = StateSettings
		elseif state == StateSettings then
			ApplySettings()
			settings:Hide()
			if workflowWasVisible then
				workflow:Show()
				state = StateWorkflow
			else
				state = StateNone
			end
		end
	end)
	settingsButton:SetSize(13, 13)
	settingsButton:SetPoint("TOPRIGHT", -2, -1)
	settingsButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
	settingsButton:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton")

	--

	workflow:CreateFrame(mainFrame)
	settings.OnClose = function()
		ApplySettings()
		if workflowWasVisible then
			workflow:Show()
			state = StateWorkflow
		else
			state = StateNone
		end
	end
	settings.OnAlphaChanged = function(alpha) workflow.frame:SetAlpha(alpha); end
end

local function OnUpdate(self, elapsed)
	settings:Resizing()
	workflow:Resizing()
end

mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:RegisterEvent("PLAYER_LOGOUT")
mainFrame:RegisterEvent("PARTY_CONVERTED_TO_RAID")
mainFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
local function OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		CreateUi()
		mainFrame:SetScript("OnUpdate", OnUpdate)
	elseif event == "PARTY_CONVERTED_TO_RAID" or event == "GROUP_ROSTER_UPDATE" and settings.list then
		settings.list:UpdatePlayers()
	elseif event == "PLAYER_LOGOUT" and settings.frame then
		settings:SaveVariables()
	end
end
mainFrame:SetScript("OnEvent", OnEvent)
