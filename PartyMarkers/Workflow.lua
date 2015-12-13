local L, icons = PC.L, PC.icons

PC.Workflow = {}
PC.Workflow.__index = PC.Workflow

PC._workflow = nil
function PC.Workflow:Create()
	local ret = {}
	ret.frame = nil
	ret.buttons = {}
	ret.visibleButtons = 0

	ret.checkElapsed = 0.0

	ret.autoMarkIndexes = {}
	ret.autoMarkCount = 0
	ret.autoMarkElapsed = 0.0

	ret.nameIndexes = {}

	PC._workflow = setmetatable(ret, PC.Workflow)
	return PC._workflow
end

function PC.Workflow:CreateFrame(parentFrame)
	self.frame = CreateFrame("Frame", nil, parentFrame)
	self.frame:Hide()
	self.frame:SetPoint("TOPLEFT", 0, -17)
	self.frame:SetPoint("BOTTOMRIGHT")
	
	local texture = self.frame:CreateTexture()
	texture:SetAllPoints()
	texture:SetTexture(0.1, 0.1, 0.1, 1)

	local lockButton = CreateFrame("Button", nil, self.frame)
	lockButton:Show()
	lockButton:SetSize(10, 10)
	lockButton:SetPoint("BOTTOMLEFT", 1, 0)
	lockButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatFrame-LockIcon")
	lockButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatFrame-LockIcon")
	lockButton:SetScript("OnClick", function() PartyMarkersStorage["locked"] = not PartyMarkersStorage["locked"]; PC._workflow:SetLocked(PartyMarkersStorage["locked"]); end)

	self.resizeButton = CreateFrame("Button", nil, self.frame)
	self.resizeButton:Show()
	self.resizeButton:SetWidth(10)
	self.resizeButton:SetHeight(10)
	self.resizeButton:SetPoint("BOTTOMRIGHT")
	self.resizeButton:EnableMouse(true)
	self.resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
	self.resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
	self.resizeButton:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			PC._workflow.resizing = true
			PC._mainFrame:StartSizing()
		end 
	end)
	self.resizeButton:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			PC._mainFrame:StopMovingOrSizing()
			PC._workflow.resizing = false
			
			PartyMarkersStorage["width"] = PC._mainFrame:GetWidth()
			PartyMarkersStorage["height"] = PC._mainFrame:GetHeight()
		end
	end)

	local scroll = CreateFrame("ScrollFrame", "PartyMarkers_ScrollWorkflow", self.frame, "UIPanelScrollFrameTemplate")
	scroll:Show()
	scroll:SetPoint("TOPLEFT", 5, -5)
	scroll:SetPoint("RIGHT", -25, 0)
	scroll:SetPoint("BOTTOM", self.resizeButton, "TOP", 0, 1)

	local scrollContainer = CreateFrame("Frame", nil, scroll)
	scrollContainer:Show()
	scrollContainer:SetPoint("TOPLEFT")
	scrollContainer:SetWidth(scroll:GetWidth())
	scrollContainer:SetHeight(scroll:GetHeight())
	scroll:SetScrollChild(scrollContainer)
	self.scroll = scroll
	self.scrollContainer = scrollContainer

	self:SetData(PartyMarkersStorage["data2"][ PartyMarkersStorage["currentProfile"] ])
	
	self:SetLocked(PartyMarkersStorage["locked"])
	if PartyMarkersStorage["locked"] then 	--Костыль от бага с первым запуском.
		PartyMarkers_ScrollWorkflowScrollBar:SetScript("OnShow", function(self)
			self:Hide()
			self:SetScript("OnShow", nil)
		end)
	end
end

function PC.Workflow:UpdateSize()
	self.scrollContainer:SetHeight(self.visibleButtons * 15 + (self.visibleButtons-1) * 2 + 4)
end

function PC.Workflow:GetButton()
	if self.visibleButtons < #self.buttons then
		local button = self.buttons[self.visibleButtons + 1]
		button:Show()
		self.visibleButtons = self.visibleButtons + 1
		self:UpdateSize()
		return button
	end

	local button = CreateFrame("Button", nil, self.scrollContainer)
	button:Show()
	button.iconIndex = 0
	button:SetPoint("LEFT", 17, 0)
	button:SetPoint("RIGHT")
	button:SetHeight(15)
	if #self.buttons == 0 then button:SetPoint("TOP", 0, -2);
	else button:SetPoint("TOP", self.buttons[#self.buttons], "BOTTOM", 0, -2); end

	button.texture = button:CreateTexture()
	button.texture:SetAllPoints()
	button.texture:SetTexture(0.2, 0.2, 0.2, 1)
	button:SetHighlightTexture(button.texture)

	button.check = CreateFrame("CheckButton", nil, self.scrollContainer, "OptionsBaseCheckButtonTemplate")
	button.check:Show()
	button.check:SetPoint("TOPLEFT", button, "TOPLEFT", -17, 0)
	button.check:SetSize(15, 15)
	button.check.index = #self.buttons + 1
	button.check:SetScript("OnClick", function(self) PC._workflow:SetAutoMarks(self.index, self:GetChecked()); end)
	button:SetScript("OnShow", function(self) self.check:Show(); end)
	button:SetScript("OnHide", function(self) self.check:Hide(); end)

	button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	button.text:SetPoint("TOPLEFT", 5, -1)
	button.text:SetPoint("BOTTOMRIGHT", -20, 0)
	button.text:SetTextColor(1,1,1,1)

	button.SetNormal = function(self) self.text:SetTextColor(1, 1, 1, 1) end
	button.SetGray = function(self) self.text:SetTextColor(0.5, 0.5, 0.5, 1) end
	button.SetRed = function(self) self.text:SetTextColor(1, 0.5, 0.5, 1) end
	button.SetGreen = function(self) self.text:SetTextColor(0.5, 1, 0.5, 1) end

	button.icon = button:CreateTexture()
	button.icon:SetPoint("TOPRIGHT")
	button.icon:SetSize(button:GetHeight(), button:GetHeight())

	button.SetData = function(self, data)
		self.text:SetText(data.text)
		self.iconIndex = data.iconIndex
		self.icon:SetTexture(icons[data.iconIndex])
		self:SetNormal()
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

function PC.Workflow:SetData(data)
	for i = 1, self.visibleButtons do self.buttons[i]:Hide(); end
	self.visibleButtons = 0
	self.nameIndexes = {}
	for k, v in ipairs(data) do
		self:GetButton():SetData(v)

		if not self.nameIndexes[v.text] then
			self.nameIndexes[v.text] = {}
			self.nameIndexes[v.text].index = 1
			self.nameIndexes[v.text].iconIndexes = {}
		end
		table.insert(self.nameIndexes[v.text].iconIndexes, v.iconIndex)
	end

	for i, _ in pairs(self.autoMarkIndexes) do
		if i > self.visibleButtons then
			self:SetAutoMark(i, false)
			self.buttons[i].check:SetChecked(false)
		end
	end
end

function PC.Workflow:OnUpdate(elapsed)
	if self.resizing then
		if PC._mainFrame:GetWidth() < 100 then PC._mainFrame:SetWidth(100); end
		if PC._mainFrame:GetHeight() < 80 then PC._mainFrame:SetHeight(80); end
		self.scrollContainer:SetWidth( self.scroll:GetWidth() )
	elseif self.frame:IsVisible() then
		self.checkElapsed = self.checkElapsed + elapsed
		if self.checkElapsed >= 5.0 then
			self.checkElapsed = 0.0
			self:Check()
		end

		if self.autoMarkCount > 0 then
			self.autoMarkElapsed = self.autoMarkElapsed + elapsed
			if self.autoMarkElapsed >= 1.0 then
				self.autoMarkElapsed = 0.0
				self:AutoMark()
			end
		end
	end
end

function PC.Workflow:Hide()
	self.frame:Hide()
end

function PC.Workflow:Show()
	self.frame:Show()
	if PartyMarkersStorage["locked"] then PartyMarkers_ScrollWorkflowScrollBar:Hide(); end
end

function PC.Workflow:Check()
	for i = 1, self.visibleButtons do
		local text = self.buttons[i].text:GetText()
		if text then
			if UnitExists(text) then
				if CanBeRaidTarget(text) then self.buttons[i]:SetGreen();
				else self.buttons[i]:SetRed(); end
			else
				self.buttons[i]:SetGray()
			end
		end
	end
end

function PC.Workflow:SetLocked(locked)
	if locked then
		self.resizeButton:Hide()
		PC._mainFrame.header:Hide()
		if PartyMarkers_ScrollWorkflowScrollBar then
			PartyMarkers_ScrollWorkflowScrollBar:Hide()
			self.scroll:SetPoint("RIGHT", -5, 0, self.frame)
			self.scrollContainer:SetWidth( self.scroll:GetWidth() )
		end
	else
		self.resizeButton:Show()
		PC._mainFrame.header:Show()
		if PartyMarkers_ScrollWorkflowScrollBar then
			PartyMarkers_ScrollWorkflowScrollBar:Show()
			self.scroll:SetPoint("RIGHT", -25, 0, self.frame)
			self.scrollContainer:SetWidth( self.scroll:GetWidth() )
		end
	end
end

function PC.Workflow:SetAutoMark(index, enable)
	if enable then
		self.autoMarkIndexes[index] = true
		self.autoMarkCount = self.autoMarkCount + 1
	else
		self.autoMarkIndexes[index] = nil
		self.autoMarkCount = self.autoMarkCount - 1
	end
end

function PC.Workflow:SetAutoMarks(index, enable)
	self:SetAutoMark(index, enable)
	local text = self.buttons[index].text:GetText()
	for i = 1, self.visibleButtons do
		if i ~= index and self.buttons[i].text:GetText() == text then 
			self:SetAutoMark(i, enable)
			self.buttons[i].check:SetChecked(enable)
		end
	end
end

function PC.Workflow:GetIconIndex(name)
	local indexes = self.nameIndexes[name]
	if indexes then
		local currentIndex = indexes.index
		if currentIndex < #indexes.iconIndexes then indexes.index = indexes.index + 1;
		elseif currentIndex == #indexes.iconIndexes and currentIndex > 1 then indexes.index = 1; end
		return indexes.iconIndexes[currentIndex]
	end
	return 0
end

function PC.Workflow:AutoMark()
	local target = UnitName("target")
	local mouseOver = UnitName("mouseover")
	for index, _ in pairs(self.autoMarkIndexes) do
		local name = self.buttons[index].text:GetText()
		local text = name
		if text == target then text = "target";
		elseif text == mouseOver then text = "mouseover"; end

		if UnitExists(text) and CanBeRaidTarget(text) then
			local iconIndex = GetRaidTargetIndex(text)
			if not iconIndex then
				SetRaidTargetIcon(text, self:GetIconIndex(name))
			end
		end
	end
end

function PC.Workflow:ClearAutoMark()
	if self.autoMarkCount > 0 then
		self.autoMarkCount = 0
		for index, _ in pairs(self.autoMarkIndexes) do
			self.buttons[index].check:SetChecked(false)
		end
		self.autoMarkIndexes = {}
	end
end

function PC.Workflow:OnMouseOverChanged()
	if self.autoMarkCount == 0 or self.frame:IsVisible() == false then return; end

	local mouseOver = UnitName("mouseover")
	for index, _ in pairs(self.autoMarkIndexes) do
		local name = self.buttons[index].text:GetText()
		if name == mouseOver then
			if CanBeRaidTarget("mouseover") then
				local iconIndex = GetRaidTargetIndex("mouseover")
				if not iconIndex then
					SetRaidTargetIcon("mouseover", self:GetIconIndex(name))
				end
			end
			break
		end
	end
end