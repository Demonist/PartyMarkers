local L = PC.L

local mainFrame = CreateFrame("Frame", "PartyMarkers_MainFrame", UIParent)
local settingsFrame = nil
local list = nil
local workflowFrame = CreateFrame("Frame", nil, mainFrame)
workflow = nil

local icons = {}
for i=1,8 do
	table.insert(icons, "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_"..i)
end

local function ClassColor(className)
	if className == "DEATHKNIGHT" then return {0.77, 0.12, 0.23}
	elseif className == "DRUID" then return {1.00, 0.49, 0.0}
	elseif className == "HUNTER" then return {0.67, 0.83, 0.45}
	elseif className == "MAGE" then return {0.41, 0.80, 0.94}
	elseif className == "MONK" then return {0.33, 0.54, 0.52}
	elseif className == "PALADIN" then return {0.96, 0.55, 0.73}
	elseif className == "PRIEST" then return {1.00, 1.00, 1.00}
	elseif className == "ROGUE" then return {1.00, 0.96, 0.41}
	elseif className == "SHAMAN" then return {0.0, 0.44, 0.87}
	elseif className == "WARLOCK" then return {0.58, 0.51, 0.79}
	elseif className == "WARRIOR" then return {0.78, 0.61, 0.43}
	else return {0.5, 0.5, 0.5}
	end
end

local List = {}
function List:Create(parentFrame)
	local list = {}
	list.parentFrame = parentFrame
	list.rows = {}
	list.visibleRows = 0

	self.__index = self
	return setmetatable(list, self)
end

function List:UpdateSize()
	self.parentFrame:SetHeight(self.visibleRows * 20 + (self.visibleRows - 1)*10+5)
end

function List:GetRow()
	if #self.rows > self.visibleRows then
		local row = self.rows[self.visibleRows + 1]
		row:Show()
		row:SetText("")
		self.visibleRows = self.visibleRows + 1
		self:UpdateSize()
		return row
	end

	local row = CreateFrame("Frame", nil, self.parentFrame)
	row:Show()
	row:SetPoint("LEFT", self.parentFrame, "LEFT")
	row:SetPoint("RIGHT", self.parentFrame, "RIGHT")
	row:SetHeight(20)
	if #self.rows == 0 then row:SetPoint("TOP", list.parentFrame, "TOP");
	else row:SetPoint("TOP", self.rows[#self.rows], "BOTTOM", 0, -10); end

	row.SetText = function(self, text) self.edit:SetText(text); end
	row.GetData = function(self) return {text=self.edit:GetText(), iconIndex=self.iconIndex}; end
	row.SetData = function(self, data)
		self:SetIcon(data.iconIndex)
		self.edit:SetText(data.text)
	end
	row.SetIcon = function(self, iconIndex)
		if self.iconIndex ~= iconIndex then
			self.iconIndex = iconIndex
			self.comboBox:SetNormalTexture(icons[iconIndex])
			self.comboBox:SetHighlightTexture(icons[iconIndex])
		end
	end
	
	row.index = #self.rows + 1
	row.iconIndex = math.random(1, 8)

	local remove = CreateFrame("Button", nil, row)
	remove:Show()
	remove:SetSize(row:GetHeight(), row:GetHeight())
	remove:SetPoint("TOPRIGHT")
	remove:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
	remove:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
	remove:SetScript("OnClick", function(self, button) if button == "LeftButton" then list:RemoveRow(self:GetParent().index); end end)

	local up = CreateFrame("Button", nil, row)
	up:Show()
	up:SetSize(10, row:GetHeight()/2)
	up:SetPoint("TOPRIGHT", remove, "TOPLEFT", -7, 0)
	up:SetNormalTexture("Interface\\Buttons\\Arrow-Up-Up")
	up:SetHighlightTexture("Interface\\Buttons\\Arrow-Up-Up")
	up:SetPushedTexture("Interface\\Buttons\\Arrow-Up-Down")
	up:SetScript("OnClick", function(self, button) if button == "LeftButton" then list:Up(self:GetParent().index); end end)

	local down = CreateFrame("Button", nil, row)
	down:Show()
	down:SetSize(10, row:GetHeight()/2)
	down:SetPoint("BOTTOMRIGHT", remove, "BOTTOMLEFT", -7, 0)
	down:SetNormalTexture("Interface\\Buttons\\Arrow-Down-Up")
	down:SetHighlightTexture("Interface\\Buttons\\Arrow-Down-Up")
	down:SetPushedTexture("Interface\\Buttons\\Arrow-Down-Down")
	down:SetScript("OnClick", function(self, button) if button == "LeftButton" then list:Down(self:GetParent().index); end end)

	--
	local comboBox = CreateFrame("Button", nil, row)
	comboBox:Show()
	comboBox:SetSize(row:GetHeight(), row:GetHeight())
	comboBox:SetPoint("TOPRIGHT", up, "TOPLEFT", -10, 0)
	local icon = icons[row.iconIndex]
	comboBox:SetNormalTexture(icon)
	comboBox:SetHighlightTexture(icon)

	if not self.markers then
		self.markers = CreateFrame("Frame", nil, mainFrame)
		self.markers:Hide()
		self.markers.index = 0
		self.markers:SetSize(row:GetHeight() + 8, 8 * row:GetHeight() + 22)
		self.markers:SetPoint("LEFT", comboBox)
		self.markers:SetBackdrop(GameTooltip:GetBackdrop())
		self.markers:SetBackdropColor(0.3, 0.3, 0.3, 1)
		self.markers:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
		self.markers:EnableKeyboard(true)
		for i=1,8 do
			local button = CreateFrame("Button", nil, self.markers)
			button:Show()
			button:SetSize(row:GetHeight() - 4, row:GetHeight() - 4)
			button:SetPoint("TOPLEFT", self.markers, 6, -(i-1)*(button:GetHeight() + 6) - 5)
			button.index = i
			button:SetScript("OnClick", function(self, button) if button == "LeftButton" then list.rows[list.markers.index]:SetIcon(self.index); list.markers:Hide() end end)
			local icon = icons[i]
			button:SetNormalTexture(icon)
			button:SetHighlightTexture(icon)
		end
		self.markers:SetScript("OnKeyDown", function(self, key) if GetBindingFromClick(key)=="TOGGLEGAMEMENU" then self:Hide(); end end)
		self.markers.Popup = function(self, index)
			self:Show()
			self:SetPoint("TOP", list.rows[index].comboBox, "BOTTOM", 0, -10)
			self.index = index
		end
		self.markers.ToogleVisible = function(self, index)
			if self:IsVisible() and index == self.index then self:Hide();
			else self:Popup(index); end
		end
	end

	comboBox:SetScript("OnClick", function(self, button) if button == "LeftButton" then list.markers:ToogleVisible(self:GetParent().index); end end)
	row.comboBox = comboBox

	--
	local edit = CreateFrame("EditBox", nil, row)
	edit:Show()
	edit:SetAutoFocus(false)
	edit:SetPoint("TOPLEFT", 10, 0)
	edit:SetPoint("BOTTOM")
	edit:SetPoint("RIGHT", comboBox, "LEFT", -10, 0)
	edit:SetFontObject(GameFontNormalLeft)
	edit:SetTextColor(1,1,1,1)
	if not self.editBackdrop then self.editBackdrop = {bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
		tile=true, tileSize=32, edgeSize=10,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
		}
	end
	edit:SetBackdrop(self.editBackdrop)
	edit:SetBackdropColor(1, 1, 1, 1)
	edit:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	edit:SetTextInsets(5, 5, 0, 0)
	edit:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			self:SetFocus()
		elseif button == "MiddleButton" then
			local text = UnitName("target")
			if not text then text = ""; end
			list.rows[self:GetParent().index]:SetText(text);
		elseif button == "RightButton" then
			list.playersFrame:Popup(self:GetParent().index)
		end
	end)

	if not self.players then
		self.players = {}
		
		self.playersFrame = CreateFrame("Frame", nil, mainFrame)
		self.playersFrame:Hide()
		self.playersFrame.index = 0
		self.playersFrame.buttons = {}
		self.playersFrame:SetPoint("LEFT", edit, "LEFT")
		self.playersFrame:SetBackdrop(GameTooltip:GetBackdrop())
		self.playersFrame:SetBackdropColor(0.3, 0.3, 0.3, 1)
		self.playersFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
		self.playersFrame:EnableKeyboard(true)
		self.playersFrame:SetScript("OnKeyDown", function(self, key) if GetBindingFromClick(key)=="TOGGLEGAMEMENU" then self:Hide(); end end)
		self.playersFrame.Popup = function(self, index)
			self.index = index
			self:SetPoint("RIGHT", list.rows[index].edit)
			self:SetPoint("TOP", list.rows[index].edit, "BOTTOM", 0, -10)

			if #list.players == 0 then return; end

			while #self.buttons < #list.players do
				local button = CreateFrame("Button", nil, self)
				button:SetPoint("LEFT")
				button:SetPoint("RIGHT")
				button:SetHeight(15)
				if #self.buttons == 0 then button:SetPoint("TOP", self, "TOP", 0, -2);
				else button:SetPoint("TOP", self.buttons[#self.buttons], "BOTTOM", 0, -2);
				end
				
				button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
				button.text:SetPoint("TOPLEFT", 5, -1)
				button.text:SetPoint("BOTTOMRIGHT")
				button.text:SetTextColor(1,1,1,1)
				button.text:SetText("")

				button.texture = button:CreateTexture()
				button.texture:SetAllPoints()
				button.texture:SetTexture(0.2, 0.2, 0.2, 1)
				button:SetHighlightTexture(button.texture)

				button:SetScript("OnClick", function(self, button)
					if button == "LeftButton" then
						list.rows[list.playersFrame.index].edit:SetText(self.text:GetText());
						list.playersFrame:Hide();
					end
				end)
				table.insert(self.buttons, button)
			end
			for i=1,#list.players do
				self.buttons[i].text:SetText(list.players[i].name)
				self.buttons[i].text:SetTextColor(list.players[i].color[1], list.players[i].color[2], list.players[i].color[3], 1)
				self.buttons[i]:Show()
			end
			self:SetHeight(#list.players*15 + (#self.buttons-1)*2 + 4)
			self:Show()
		end
		self:UpdatePlayers()
	end

	row.edit = edit

	table.insert(self.rows, row)
	self.visibleRows = self.visibleRows + 1
	self:UpdateSize()
	return row
end

function List:RemoveRow(index)
	for i=index+1,self.visibleRows do self.rows[i-1]:SetData(self.rows[i]:GetData()); end
	self.rows[self.visibleRows]:Hide()

	self.visibleRows = self.visibleRows - 1
	self:UpdateSize()
end

function List:Up(index)
	if index == 1 then return; end
	local data = self.rows[index-1]:GetData()
	self.rows[index-1]:SetData(self.rows[index]:GetData())
	self.rows[index]:SetData(data)
end

function List:Down(index)
	if index == #self.rows then return; end
	local data = self.rows[index+1]:GetData()
	self.rows[index+1]:SetData(self.rows[index]:GetData())
	self.rows[index]:SetData(data)
end

function List:GetData()
	local data = {}
	for i=1,self.visibleRows do
		table.insert(data, self.rows[i]:GetData())
	end
	return data
end

function List:SetData(data)
	for i=2,self.visibleRows do self.rows[i]:Hide(); end
	self.visibleRows = 0
	for k,v in ipairs(data) do self:GetRow():SetData(v); end
end

function List:ClearFocus()
	for i=1,self.visibleRows do self.rows[i].edit:ClearFocus(); end
end

function List:UpdatePlayers()
	if self.players then
		for i=1,#self.players do self.playersFrame.buttons[i]:Hide(); end
		self.players = {}

		if IsInRaid() then
			for i=1,40 do
				local name = UnitName("raid"..i)
				if name then
					local _, className = UnitClass("raid"..i)
					table.insert(self.players, {name=name, class=className, color=ClassColor(className)});
				end
			end
		elseif IsInGroup() then
			for i=1,4 do
				local name = UnitName("party"..i)
				if name then
					local _, className = UnitClass("party"..i)
					table.insert(self.players, {name=name, class=className, color=ClassColor(className)});
				end
			end
		end

		local name = UnitName("player")
		if name then
			local _, className = UnitClass("player")
			table.insert(self.players, {name=name, class=className, color=ClassColor(className)});
		end

		if #self.players > 1 then
			table.sort(self.players, function(left, right) return string.lower(left.name) < string.lower(right.name); end)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------

local Workflow = {}
function Workflow:Create(frame)
	local ret = {}
	ret.frame = frame
	ret.buttons = {}
	ret.visibleButtons = 0
	self.__index = self
	return setmetatable(ret, self)
end

function Workflow:UpdateSize()
	self.frame:SetHeight(self.visibleButtons*15 + (self.visibleButtons-1)*2 + 2)
end

function Workflow:GetButton()
	if self.visibleButtons < #self.buttons then
		local button = self.buttons[self.visibleButtons + 1]
		button:Show()
		self.visibleButtons = self.visibleButtons + 1
		self:UpdateSize()
		return button
	end

	local button = CreateFrame("Button", nil, self.frame)
	button:Show()
	button.iconIndex = 0
	button:SetPoint("LEFT")
	button:SetPoint("RIGHT")
	button:SetHeight(15)
	if #self.buttons == 0 then button:SetPoint("TOP", 0, -2);
	else button:SetPoint("TOP", self.buttons[#self.buttons], "BOTTOM", 0, -2); end

	button.texture = button:CreateTexture()
	button.texture:SetAllPoints()
	button.texture:SetTexture(0.2, 0.2, 0.2, 1)
	button:SetHighlightTexture(button.texture)

	button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	button.text:SetPoint("TOPLEFT", 5, -1)
	button.text:SetPoint("BOTTOMRIGHT", -20, 0)
	button.text:SetTextColor(1,1,1,1)

	button.icon = button:CreateTexture()
	button.icon:SetPoint("TOPRIGHT")
	button.icon:SetSize(button:GetHeight(), button:GetHeight())

	button.SetData = function(self, data)
		self.text:SetText(data.text)
		self.iconIndex = data.iconIndex
		self.icon:SetTexture(icons[data.iconIndex])
	end
	button:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			local text = self.text:GetText()
			if text then SetRaidTargetIcon(text, self.iconIndex); end
		end
	end)

	table.insert(self.buttons, button)
	self.visibleButtons = self.visibleButtons + 1
	self:UpdateSize()
	return button
end

function Workflow:SetData(data)
	for i=1,self.visibleButtons do self.buttons[i]:Hide(); end
	self.visibleButtons = 0
	for k,v in ipairs(data) do
		self:GetButton():SetData(v)
	end
end

-----------------------------------------------------------------------------------------------------------------------

local function Resizing(self, elapsed)
	if settingsFrame and settingsFrame.resizing then
		if settingsFrame:GetWidth() < 170 then settingsFrame:SetWidth(170) end
		if settingsFrame:GetHeight() < 100 then settingsFrame:SetHeight(100) end
		settingsFrame.scrollContainer:SetWidth(settingsFrame.scroll:GetWidth())
	elseif workflowFrame.resizing then
		if workflowFrame:GetWidth() < 100 then workflowFrame:SetWidth(100) end
		if workflowFrame:GetHeight() < 50 then workflowFrame:SetHeight(50) end
		mainFrame:SetWidth(workflowFrame:GetWidth())
		workflowFrame:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT")
		workflowFrame:SetPoint("RIGHT")
		workflowFrame.scrollContainer:SetWidth(workflowFrame.scroll:GetWidth())
	end
end

local function CreateSettingsUi()
	if not PartyMarkersStorage["settingsPoint"] then PartyMarkersStorage["settingsPoint"] = "CENTER"; end
	if not PartyMarkersStorage["settingsX"] then PartyMarkersStorage["settingsX"] = 0; end
	if not PartyMarkersStorage["settingsY"] then PartyMarkersStorage["settingsY"] = 0; end
	if not PartyMarkersStorage["settingsWidth"] then PartyMarkersStorage["settingsWidth"] = 200; end
	if not PartyMarkersStorage["settingsHeight"] then PartyMarkersStorage["settingsHeight"] = 300; end

	settingsFrame = CreateFrame("Frame", nil, UIParent)
	settingsFrame:Hide()
	settingsFrame.resizing = false
	settingsFrame:SetSize(PartyMarkersStorage["settingsWidth"], PartyMarkersStorage["settingsHeight"])
	settingsFrame:SetPoint(PartyMarkersStorage["settingsPoint"], PartyMarkersStorage["settingsX"], PartyMarkersStorage["settingsY"])

	settingsFrame:SetMovable(true)
	settingsFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then settingsFrame:StartMoving(); end
		if list.markers:IsVisible() then list.markers:Hide(); end
		if list.playersFrame:IsVisible() then list.playersFrame:Hide(); end
	end)
	settingsFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			settingsFrame:StopMovingOrSizing();
			local point,_,_, x, y = settingsFrame:GetPoint()
			PartyMarkersStorage["settingsPoint"] = point
			PartyMarkersStorage["settingsX"] = x
			PartyMarkersStorage["settingsY"] = y
			list:ClearFocus()
		end
	end)

	settingsFrame.texture = settingsFrame:CreateTexture()
	settingsFrame.texture:SetAllPoints()
	settingsFrame.texture:SetTexture(0.1, 0.1, 0.1, 1)

	local header = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	header:SetPoint("TOPLEFT", 5, -2)
	header:SetText("PartyMarkers - "..L["settings"])
	
	--
	settingsFrame:SetResizable(true)
	local resizeButton = CreateFrame("Button", nil, settingsFrame)
	resizeButton:Show()
	resizeButton:SetWidth(16)
	resizeButton:SetHeight(16)
	resizeButton:SetPoint("BOTTOMRIGHT")
	resizeButton:EnableMouse(true)
	resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
	resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
	resizeButton:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			settingsFrame.resizing = true
			settingsFrame:StartSizing()
			mainFrame:SetScript("OnUpdate", Resizing)
		end 
	end)
	resizeButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			settingsFrame:StopMovingOrSizing()
			mainFrame:SetScript("OnUpdate", nil)
			settingsFrame.resizing = false
			PartyMarkersStorage["settingsWidth"] = settingsFrame:GetWidth()
			PartyMarkersStorage["settingsHeight"] = settingsFrame:GetHeight()
		end
	end)

	--
	local addButton = CreateFrame("Button", nil, settingsFrame)
	addButton:Show()
	addButton:SetWidth(16)
	addButton:SetHeight(16)
	addButton:SetPoint("BOTTOMLEFT", 2, 2)
	addButton:SetNormalTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
	addButton:SetHighlightTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
	addButton:SetScript("OnClick", function(self, button) if button == "LeftButton" then list:GetRow(); end end)

	--
	local closeButton = CreateFrame("Button", nil, settingsFrame)
	closeButton:Show()
	closeButton:SetWidth(16)
	closeButton:SetHeight(16)
	closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT")
	closeButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
	closeButton:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
	closeButton:SetScript("OnClick", function()
		settingsFrame:Hide()
		PartyMarkersStorage["data"] = list:GetData()
		workflow:SetData(list:GetData())
		if workflowFrame.wasVisible then workflowFrame:Show() end
	end)

	--
	-- local profileText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	-- profileText:SetPoint("TOPLEFT", 20, -20)
	-- profileText:SetTextColor(0.9, 0.9, 0.9, 1)
	-- if PartyMarkersStorage["profileIndex"] > 0 then
	-- 	profileText:SetText(L["profile"]..": "..PartyMarkersStorage["profiles"][ PartyMarkersStorage["profileIndex"] ].text)
	-- else
	-- 	profileText:SetText(L["profile"]..": "..L["commonProfile"])
	-- end

	--
	local scroll = CreateFrame("ScrollFrame", "PartyMarkers_Scroll", settingsFrame, "UIPanelScrollFrameTemplate")
	scroll:Show()
	scroll:SetPoint("TOPLEFT", 5, -20)
	scroll:SetPoint("RIGHT", settingsFrame, "RIGHT", -25, 0)
	scroll:SetPoint("BOTTOM", resizeButton, "TOP", 0, 1)

	local scrollContainer = CreateFrame("Frame", nil, scroll)
	scrollContainer:Show()
	scrollContainer:SetPoint("TOPLEFT")
	scrollContainer:SetWidth(scroll:GetWidth())
	scrollContainer:SetHeight(scroll:GetHeight())
	scroll:SetScrollChild(scrollContainer)
	settingsFrame.scroll = scroll
	settingsFrame.scrollContainer = scrollContainer

	list = List:Create(settingsFrame.scrollContainer)
	list:GetRow()
	list:SetData(PartyMarkersStorage["data"])
end

local function HeaderClicked()
	if settingsFrame and settingsFrame:IsVisible() then settingsFrame:Hide(); end
	if workflowFrame:IsVisible() then workflowFrame:Hide();
	else workflowFrame:Show(); end
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

	mainFrame:SetFrameStrata("MEDIUM")
	mainFrame:SetFrameLevel(50)
	mainFrame:SetSize(PartyMarkersStorage["width"], 15)
	mainFrame:SetPoint(PartyMarkersStorage["point"], PartyMarkersStorage["x"], PartyMarkersStorage["y"])
	
	mainFrame:SetMovable(true)
	mainFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				mainFrame:StartMoving()
			else
				HeaderClicked()
			end
		end
	end)
	mainFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			mainFrame:StopMovingOrSizing();
			workflowFrame:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT")
			local point,_,_, x, y = mainFrame:GetPoint()
			PartyMarkersStorage["point"] = point
			PartyMarkersStorage["x"] = x
			PartyMarkersStorage["y"] = y
		end
	end)

	mainFrame.texture = mainFrame:CreateTexture()
	mainFrame.texture:SetAllPoints(mainFrame)
	mainFrame.texture:SetTexture(0.05, 0.05, 0.05, 1)

	mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	mainFrame.title:SetPoint("TOPLEFT", 5, -1)
	mainFrame.title:SetText("PartyMarkers")

	mainFrame.settings = CreateFrame("Button", "PartyMarkers_SettingsButton", mainFrame)
	mainFrame.settings:SetScript("OnClick", function() 
		if not settingsFrame then CreateSettingsUi(); end
		if settingsFrame:IsVisible() then
			settingsFrame:Hide()
			workflow:SetData(list:GetData())
			if workflowFrame.wasVisible then workflowFrame:Show() end
		else
			workflowFrame.wasVisible = workflowFrame:IsVisible() 
			workflowFrame:Hide()
			settingsFrame:Show()
		end
	end)
	mainFrame.settings:SetSize(13, 13)
	mainFrame.settings:SetPoint("TOPRIGHT", -2, 0)
	mainFrame.settings:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
	mainFrame.settings:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton")

	mainFrame:Show()

	--

	workflowFrame:Hide();
	workflowFrame.resizing = false
	workflowFrame:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT")
	workflowFrame:SetPoint("RIGHT")
	workflowFrame:SetHeight(PartyMarkersStorage["height"])
	workflowFrame.texture = workflowFrame:CreateTexture()
	workflowFrame.texture:SetAllPoints(workflowFrame)
	workflowFrame.texture:SetTexture(0.1, 0.1, 0.1, 1)

	workflowFrame:SetResizable(true)
	local resizeButton = CreateFrame("Button", nil, workflowFrame)
	resizeButton:Show()
	resizeButton:SetWidth(10)
	resizeButton:SetHeight(10)
	resizeButton:SetPoint("BOTTOMRIGHT")
	resizeButton:EnableMouse(true)
	resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
	resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
	resizeButton:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			workflowFrame.resizing = true
			workflowFrame:StartSizing()
			mainFrame:SetScript("OnUpdate", Resizing)
		end 
	end)
	resizeButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			workflowFrame:StopMovingOrSizing()
			mainFrame:SetScript("OnUpdate", nil)
			workflowFrame.resizing = false
			PartyMarkersStorage["width"] = mainFrame:GetWidth()
			PartyMarkersStorage["height"] = workflowFrame:GetHeight()
		end
	end)

	local scroll = CreateFrame("ScrollFrame", "PartyMarkers_Scroll2", workflowFrame, "UIPanelScrollFrameTemplate")
	scroll:Show()
	scroll:SetPoint("TOPLEFT", 5, -5)
	scroll:SetPoint("RIGHT", workflowFrame, "RIGHT", -25, 0)
	scroll:SetPoint("BOTTOM", resizeButton, "TOP", 0, 1)

	local scrollContainer = CreateFrame("Frame", nil, scroll)
	scrollContainer:Show()
	scrollContainer:SetPoint("TOPLEFT")
	scrollContainer:SetWidth(scroll:GetWidth())
	scrollContainer:SetHeight(scroll:GetHeight())
	scroll:SetScrollChild(scrollContainer)
	workflowFrame.scroll = scroll
	workflowFrame.scrollContainer = scrollContainer

	workflow = Workflow:Create(workflowFrame.scrollContainer)
	workflow:SetData(PartyMarkersStorage["data"])
end

mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:RegisterEvent("PARTY_CONVERTED_TO_RAID")
mainFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
local function OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		CreateUi()
	elseif event == "PARTY_CONVERTED_TO_RAID" or event == "GROUP_ROSTER_UPDATE" and list then
		list:UpdatePlayers()
	end
end
mainFrame:SetScript("OnEvent", OnEvent)
