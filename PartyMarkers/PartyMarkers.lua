local L, icons, Workflow, Settings = PC.L, PC.icons, PC.Workflow, PC.Settings

local mainFrame = CreateFrame("Frame", "PartyMarkers_MainFrame", UIParent)
PC._mainFrame = mainFrame

local StateNone, StateWorkflow, StateSettings = 0, 1, 2
local state = StateNone
local workflowWasVisible = false

local workflow = Workflow:Create()
local settings = Settings:Create()


local function ApplySettings()
	workflow:SetData(settings.list:GetData())
	workflow:Check()
end

local function CreateUi()
	if not PartyMarkersStorage then PartyMarkersStorage = {}; end
	if not PartyMarkersStorage["point"] then PartyMarkersStorage["point"] = "CENTER"; end
	if not PartyMarkersStorage["x"] then PartyMarkersStorage["x"] = 0; end
	if not PartyMarkersStorage["y"] then PartyMarkersStorage["y"] = 0; end
	if not PartyMarkersStorage["width"] then PartyMarkersStorage["width"] = 150; end
	if not PartyMarkersStorage["height"] then PartyMarkersStorage["height"] = 200; end
	if not PartyMarkersStorage["locked"] then PartyMarkersStorage["locked"] = false; end
	if not PartyMarkersStorage["alpha"] then PartyMarkersStorage["alpha"] = 80; end

	if not PartyMarkersStorage["currentProfile"] then PartyMarkersStorage["currentProfile"] = L["commonProfile"]; end
	if not PartyMarkersStorage["data2"] then
		PartyMarkersStorage["data2"] = {}
		PartyMarkersStorage["data2"][L["commonProfile"]] = {}

		if PartyMarkersStorage["data"] then
			PartyMarkersStorage["data2"][L["commonProfile"]] = PartyMarkersStorage["data"]
			PartyMarkersStorage["data"] = nil
		end
	end

	mainFrame:Show()
	mainFrame:SetSize(PartyMarkersStorage["width"], PartyMarkersStorage["height"])
	mainFrame:SetPoint(PartyMarkersStorage["point"], PartyMarkersStorage["x"], PartyMarkersStorage["y"])
	
	mainFrame:SetMovable(true)
	mainFrame:SetResizable(true)

	mainFrame.header = CreateFrame("Frame", nil, mainFrame)
	mainFrame.header:Show()
	mainFrame.header:SetPoint("TOPLEFT")
	mainFrame.header:SetPoint("RIGHT")
	mainFrame.header:SetHeight(17)

	mainFrame.header:SetScript("OnMouseDown", function(self, button)
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
	mainFrame.header:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			mainFrame:StopMovingOrSizing();

			local point,_,_, x, y = mainFrame:GetPoint()
			PartyMarkersStorage["point"] = point
			PartyMarkersStorage["x"] = x
			PartyMarkersStorage["y"] = y
		end
	end)
	
	local texture = mainFrame.header:CreateTexture()
	texture:SetAllPoints()
	texture:SetTexture(0.05, 0.05, 0.05, 1)

	local title = mainFrame.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	title:SetPoint("TOPLEFT", 5, -1)
	title:SetText("PartyMarkers")

	local settingsButton = CreateFrame("Button", "PartyMarkers_SettingsButton", mainFrame.header)
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
	workflow.frame:SetAlpha(PartyMarkersStorage["alpha"] / 100)
	settings.OnLoad = function() workflow:ClearAutoMark(); end

	if PartyMarkersStorage["locked"] then
		workflow:Show()
		state = StateWorkflow
	end
end

local function OnUpdate(self, elapsed)
	settings:OnUpdate(elapsed)
	workflow:OnUpdate(elapsed)
end

mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:RegisterEvent("PLAYER_LOGOUT")
mainFrame:RegisterEvent("PARTY_CONVERTED_TO_RAID")
mainFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
mainFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
local function OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		CreateUi()
		mainFrame:SetScript("OnUpdate", OnUpdate)
	elseif event == "PARTY_CONVERTED_TO_RAID" or event == "GROUP_ROSTER_UPDATE" and settings.list then
		settings.list:UpdatePlayers()
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		workflow:OnMouseOverChanged()
	elseif event == "PLAYER_LOGOUT" and settings.frame then
		settings:SaveVariables()
	end
end
mainFrame:SetScript("OnEvent", OnEvent)
