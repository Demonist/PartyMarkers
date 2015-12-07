local L = PC.L

PC.Settings = {}
PC.Settings.__index = PC.Settings

PC._settings = nil
function PC.Settings:Create()
	if PC.settings then return PC._settings; end

	local ret = {}
	ret.frame = nil

	ret.OnClose = function() end
	ret.OnAlphaChanged = function(alpha) end

	PC._settings = setmetatable(ret, PC.Settings)
	return PC._settings
end

function PC.Settings:Show()
	if not self.frame then self:CreateFrame(); end
	self.frame:Show()
end

function PC.Settings:Hide()
	self:HidePopups()
	if self.frame then self.frame:Hide(); end
end

function PC.Settings:HidePopups()
	if self.list then self.list:HidePopups(); end
	if self.profileMenuFrame then self.profileMenuFrame:Hide(); end
end

function PC.Settings:SaveVariables()
	if self.slider then PartyMarkersStorage["alpha"] = self.slider:GetValue(); end
end

function PC.Settings:Resizing()
	if self.resizing then
		if self.frame:GetWidth() < 170 then self.frame:SetWidth(170); end
		if self.frame:GetHeight() < 100 then self.frame:SetHeight(100); end
		self.scrollContainer:SetWidth( self.scroll:GetWidth() )
	end
end

function PC.Settings:LoadProfile(profileName)
	local data = PartyMarkersStorage["data2"][profileName]
	if data then
		PartyMarkersStorage["currentProfile"] = profileName
		self.profile:SetText(profileName)
		self.list:SetData(data)
	end
end

function PC.Settings:UpdateProfileMenu()
	local newList = {}
	for name, profile in pairs(PartyMarkersStorage["data2"]) do
		table.insert(newList, {text = name, notCheckable = true, keepShownOnClick = false, func = function() PC._settings:LoadProfile(name); end})
	end
	table.sort(newList, function(left, right) return string.lower(left.text) < string.lower(right.text) end)
	self.profileMenu[1].menuList = newList
end

function PC.Settings:ProfileMenu_Save()
	local text = self.profile:GetText()
	PartyMarkersStorage["data2"][text] = self.list:GetData()
	self:UpdateProfileMenu()
end

function PC.Settings:ProfileMenu_Remove()
	local text = self.profile:GetText()
	if PartyMarkersStorage["data2"][text] then
		if text == L["commonProfile"] then
			self.list:SetData({})
			PartyMarkersStorage["data2"][L["commonProfile"]] = {}
		else
			PartyMarkersStorage["data2"][text] = nil
			self:LoadProfile(L["commonProfile"])
		end
		self:UpdateProfileMenu()
	end
end

function PC.Settings:CreateFrame()
	if not PartyMarkersStorage["settingsPoint"] then PartyMarkersStorage["settingsPoint"] = "CENTER"; end
	if not PartyMarkersStorage["settingsX"] then PartyMarkersStorage["settingsX"] = 0; end
	if not PartyMarkersStorage["settingsY"] then PartyMarkersStorage["settingsY"] = 0; end
	if not PartyMarkersStorage["settingsWidth"] then PartyMarkersStorage["settingsWidth"] = 200; end
	if not PartyMarkersStorage["settingsHeight"] then PartyMarkersStorage["settingsHeight"] = 300; end

	self.frame = CreateFrame("Frame", nil, UIParent)
	self.frame:Show()
	self.resizing = false
	self.frame:SetSize(PartyMarkersStorage["settingsWidth"], PartyMarkersStorage["settingsHeight"])
	self.frame:SetPoint(PartyMarkersStorage["settingsPoint"], PartyMarkersStorage["settingsX"], PartyMarkersStorage["settingsY"])

	self.frame:SetMovable(true)
	self.frame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then self:StartMoving(); end
		PC._settings:HidePopups()
		PC._settings.list:ClearFocus()
		PC._settings.profile:ClearFocus()
	end)
	self.frame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			self:StopMovingOrSizing();
			local point,_,_, x, y = self:GetPoint()
			PartyMarkersStorage["settingsPoint"] = point
			PartyMarkersStorage["settingsX"] = x
			PartyMarkersStorage["settingsY"] = y
		end
	end)

	self.frame.texture = self.frame:CreateTexture()
	self.frame.texture:SetAllPoints()
	self.frame.texture:SetTexture(0.1, 0.1, 0.1, 1)

	--header:
	local header = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	header:SetPoint("TOPLEFT", 5, -2)
	header:SetText("PartyMarkers - "..L["settings"])

	--
	local closeButton = CreateFrame("Button", nil, self.frame)
	closeButton:Show()
	closeButton:SetWidth(16)
	closeButton:SetHeight(16)
	closeButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT")
	closeButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
	closeButton:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
	closeButton:SetScript("OnClick", function()
		self.frame:Hide()
		PC._settings:HidePopups()
		PC._settings.OnClose()
	end)

	--profile:
	local profileTitle = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	profileTitle:SetPoint("TOPLEFT", 10, -25)
	profileTitle:SetText(L["profile"]..": ")

	self.profile = CreateFrame("EditBox", nil, self.frame, "InputBoxTemplate")
	self.profile:Show()
	self.profile:SetPoint("TOPLEFT", profileTitle, "TOPRIGHT", 5, 0)
	self.profile:SetPoint("RIGHT", -50, 0)
	self.profile:SetHeight(10)
	self.profile:SetAutoFocus(false)
	self.profile:SetScript("OnMouseDown", function(self, button) if button == "LeftButton" then self:SetFocus(); end end)

	local profileButton = CreateFrame("Button", nil, self.frame)
	profileButton:Show()
	profileButton:SetPoint("TOPLEFT", self.profile, "TOPRIGHT", 5, 0)
	profileButton:SetSize(15, 15)
	profileButton:SetNormalTexture("Interface\\Buttons\\Arrow-Down-Up")
	profileButton:SetHighlightTexture("Interface\\Buttons\\Arrow-Down-Up")
	profileButton:SetPushedTexture("Interface\\Buttons\\Arrow-Down-Down")
	profileButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, PC._settings.profileMenuFrame, PC._settings.profileMenuFrame, 0, 0, PC._settings.profileMenu, nil, nil); end)

	self.profileMenuFrame = CreateFrame("Frame", "PartyMarkers_ProfileMenu", self.frame, "UIDropDownMenuTemplate")
	self.profileMenuFrame:Hide()
	self.profileMenuFrame:SetPoint("TOPLEFT", profileButton, "BOTTOMLEFT", 0, 30)
	self.profileMenuFrame.displayMode = "MENU"

	PC._settings.profileMenu = {
		{text = L["load"], notCheckable = true, hasArrow = true, menuList = {}},
		{text = L["save"], notCheckable = true, func = function() PC._settings:ProfileMenu_Save() end},
		{text = L["remove"], notCheckable = true, func = function() PC._settings:ProfileMenu_Remove(); end}
	}
	
	UIDropDownMenu_Initialize(PC._settings.profileMenuFrame, EasyMenu_Initialize, "MENU", nil, PC._settings.profileMenu)
	self:UpdateProfileMenu()

	--bottom:
	local addButton = CreateFrame("Button", nil, self.frame)
	addButton:Show()
	addButton:SetWidth(16)
	addButton:SetHeight(16)
	addButton:SetPoint("BOTTOMLEFT", 2, 2)
	addButton:SetNormalTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
	addButton:SetHighlightTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
	addButton:SetScript("OnClick", function(self, button) if button == "LeftButton" then PC._settings.list:GetRow(); end end)

	--
	local slider = CreateFrame("Slider", nil, self.frame, "OptionsSliderTemplate")
	slider:Show()
	slider:SetPoint("BOTTOMLEFT", 30, 5)
	slider:SetPoint("RIGHT", -30, 0)
	slider:SetHeight(16)
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(40, 100)
	slider:SetValueStep(1)
	slider:SetScript("OnValueChanged", function(self, value)
		PC._settings.frame:SetAlpha(value/100)
		PC._settings.OnAlphaChanged(value/100)
	end)
	slider:SetValue(PartyMarkersStorage["alpha"])
	self.slider = slider

	--
	self.frame:SetResizable(true)
	local resizeButton = CreateFrame("Button", nil, self.frame)
	resizeButton:Show()
	resizeButton:SetWidth(16)
	resizeButton:SetHeight(16)
	resizeButton:SetPoint("BOTTOMRIGHT")
	resizeButton:EnableMouse(true)
	resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
	resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
	resizeButton:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			PC._settings.resizing = true
			PC._settings.frame:StartSizing()
		end 
	end)
	resizeButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			PC._settings.frame:StopMovingOrSizing()
			PC._settings.resizing = false
			PartyMarkersStorage["settingsWidth"] = PC._settings.frame:GetWidth()
			PartyMarkersStorage["settingsHeight"] = PC._settings.frame:GetHeight()
		end
	end)

	--scroll:
	local scroll = CreateFrame("ScrollFrame", "PartyMarkers_ScrollSettings", self.frame, "UIPanelScrollFrameTemplate")
	scroll:Show()
	scroll:SetPoint("TOPLEFT", 5, -50)
	scroll:SetPoint("RIGHT", self.frame, "RIGHT", -25, 0)
	scroll:SetPoint("BOTTOM", resizeButton, "TOP", 0, 1)

	local scrollContainer = CreateFrame("Frame", nil, scroll)
	scrollContainer:SetPoint("TOPLEFT")
	scrollContainer:SetWidth(scroll:GetWidth())
	scrollContainer:SetHeight(scroll:GetHeight())
	scrollContainer:Show()
	scroll:SetScrollChild(scrollContainer)
	self.scroll = scroll
	self.scrollContainer = scrollContainer

	self.list = PC.SettingsList:Create(self.scrollContainer)
	self:LoadProfile(PartyMarkersStorage["currentProfile"])
end
