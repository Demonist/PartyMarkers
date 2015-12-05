local ClassColor, icons = PC.ClassColor, PC.icons

PC.SettingsList = {}
PC.SettingsList.__index = PC.SettingsList

PC._settingsList = nil
function PC.SettingsList:Create(parentFrame)
	if PC.settingsList then return PC._settingsList; end

	local list = {}
	list.parentFrame = parentFrame
	list.rows = {}
	list.visibleRows = 0

	list.markers = nil
	list.players = nil

	PC._settingsList = setmetatable(list, PC.SettingsList)
	return PC._settingsList
end

function PC.SettingsList:HidePopups()
	if self.markers then self.markers:Hide(); end
	if self.players then self.players:Hide(); end
end

function PC.SettingsList:UpdateSize()
	self.parentFrame:SetHeight( self.visibleRows * 20 + (self.visibleRows - 1) * 10 + 6 )
end

function PC.SettingsList:GetRow()
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
	row:SetPoint("LEFT")
	row:SetPoint("RIGHT")
	row:SetHeight(20)
	if #self.rows == 0 then row:SetPoint("TOP", self.parentFrame, "TOP", 0, -3);
	else row:SetPoint("TOP", self.rows[#self.rows], "BOTTOM", 0, -10); end

	row.SetText = function(self, text) self.edit:SetText(text); end
	row.GetData = function(self) return {text = self.edit:GetText(), iconIndex = self.iconIndex}; end
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
	remove:SetScript("OnClick", function(self, button) if button == "LeftButton" then PC._settingsList:RemoveRow(self:GetParent().index); end end)

	local up = CreateFrame("Button", nil, row)
	up:Show()
	up:SetSize(10, row:GetHeight()/2)
	up:SetPoint("TOPRIGHT", remove, "TOPLEFT", -7, 0)
	up:SetNormalTexture("Interface\\Buttons\\Arrow-Up-Up")
	up:SetHighlightTexture("Interface\\Buttons\\Arrow-Up-Up")
	up:SetPushedTexture("Interface\\Buttons\\Arrow-Up-Down")
	up:SetScript("OnClick", function(self, button) if button == "LeftButton" then PC._settingsList:Up(self:GetParent().index); end end)

	local down = CreateFrame("Button", nil, row)
	down:Show()
	down:SetSize(10, row:GetHeight()/2)
	down:SetPoint("BOTTOMRIGHT", remove, "BOTTOMLEFT", -7, 0)
	down:SetNormalTexture("Interface\\Buttons\\Arrow-Down-Up")
	down:SetHighlightTexture("Interface\\Buttons\\Arrow-Down-Up")
	down:SetPushedTexture("Interface\\Buttons\\Arrow-Down-Down")
	down:SetScript("OnClick", function(self, button) if button == "LeftButton" then PC._settingsList:Down(self:GetParent().index); end end)

	--
	local comboBox = CreateFrame("Button", nil, row)
	comboBox:Show()
	comboBox:SetSize(row:GetHeight(), row:GetHeight())
	comboBox:SetPoint("TOPRIGHT", up, "TOPLEFT", -10, 0)
	local icon = icons[row.iconIndex]
	comboBox:SetNormalTexture(icon)
	comboBox:SetHighlightTexture(icon)

	if not self.markers then
		self.markers = CreateFrame("Frame", nil, PC._mainFrame)
		self.markers:Hide()
		self.markers.rowIndex = 0
		self.markers:SetSize(row:GetHeight() + 8, 8 * row:GetHeight() + 22)
		self.markers:SetPoint("LEFT", comboBox)
		self.markers:SetBackdrop(GameTooltip:GetBackdrop())
		self.markers:SetBackdropColor(0.3, 0.3, 0.3, 1)
		self.markers:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
		self.markers:EnableKeyboard(true)
		for i = 1, 8 do
			local button = CreateFrame("Button", nil, self.markers)
			button:Show()
			button:SetSize(row:GetHeight() - 4, row:GetHeight() - 4)
			button:SetPoint("TOPLEFT", self.markers, 6, -(i-1)*(button:GetHeight() + 6) - 5)
			button.index = i
			button:SetScript("OnClick", function(self, button)
				if button == "LeftButton" then
					PC._settingsList.rows[PC._settingsList.markers.rowIndex]:SetIcon(self.index);
					PC._settingsList.markers:Hide()
				end
			end)
			local icon = icons[i]
			button:SetNormalTexture(icon)
			button:SetHighlightTexture(icon)
		end
		self.markers:SetScript("OnKeyDown", function(self, key) if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then self:Hide(); end end)
		self.markers.Popup = function(self, index)
			self:Show()
			self:SetPoint("TOP", PC._settingsList.rows[index].comboBox, "BOTTOM", 0, -10)
			self.rowIndex = index
		end
		self.markers.ToogleVisible = function(self, index)
			if PC._settingsList.players then PC._settingsList.players:Hide(); end
			if self:IsVisible() and index == self.index then self:Hide();
			else self:Popup(index); end
		end
	end

	comboBox:SetScript("OnClick", function(self, button) if button == "LeftButton" then PC._settingsList.markers:ToogleVisible( self:GetParent().index ); end end)
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
		if PC._settingsList.markers then PC._settingsList.markers:Hide(); end

		if button == "LeftButton" then
			self:SetFocus()
			if PC._settingsList.players then PC._settingsList.players:Hide(); end
		elseif button == "MiddleButton" then
			local text = UnitName("target")
			if not text then text = ""; end
			PC._settingsList.rows[self:GetParent().index]:SetText(text);
		elseif button == "RightButton" then
			PC._settingsList.players:Popup(self:GetParent().index)
		end
	end)

	if not self.players then
		self.players = CreateFrame("Frame", nil, PC._mainFrame)
		self.players:Hide()
		self.players.rowIndex = 0
		self.players.buttons = {}
		self.players.list = {}
		self.players:SetPoint("LEFT", edit, "LEFT")
		self.players:SetPoint("RIGHT", edit, "RIGHT")
		self.players:SetBackdrop(GameTooltip:GetBackdrop())
		self.players:SetBackdropColor(0.3, 0.3, 0.3, 1)
		self.players:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
		self.players:EnableKeyboard(true)
		self.players:SetScript("OnKeyDown", function(self, key) if GetBindingFromClick(key)=="TOGGLEGAMEMENU" then self:Hide(); end end)
		self.players.Popup = function(self, index)
			if self:IsVisible() and self.rowIndex == index then
				self:Hide()
				return
			end

			self.rowIndex = index
			self:SetPoint("TOP", PC._settingsList.rows[self.rowIndex].edit, "BOTTOM", 0, -10)

			if #self.list == 0 then return; end

			while #self.buttons < #self.list do
				local button = CreateFrame("Button", nil, self)
				button:SetPoint("LEFT")
				button:SetPoint("RIGHT")
				button:SetHeight(15)
				if #self.buttons == 0 then button:SetPoint("TOP", self, "TOP", 0, -4);
				else button:SetPoint("TOP", self.buttons[#self.buttons], "BOTTOM", 0, -2);
				end
				
				button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
				button.text:SetPoint("TOPLEFT", 7, -1)
				button.text:SetPoint("BOTTOMRIGHT")
				button.text:SetTextColor(1,1,1,1)
				button.text:SetText("")

				button.texture = button:CreateTexture()
				button.texture:SetAllPoints()
				button.texture:SetTexture(0.2, 0.2, 0.2, 1)
				button:SetHighlightTexture(button.texture)

				button:SetScript("OnClick", function(self, button)
					if button == "LeftButton" then
						PC._settingsList.rows[PC._settingsList.players.rowIndex].edit:SetText( self.text:GetText() )
					end
					PC._settingsList.players:Hide()
				end)
				button:SetScript("OnMouseDown", function(self, button) if button == "RightButton" then PC._settingsList.players:Hide(); end end)
				table.insert(self.buttons, button)
			end

			for i = 1, #self.list do
				self.buttons[i].text:SetText(self.list[i].name)
				self.buttons[i].text:SetTextColor(self.list[i].color[1], self.list[i].color[2], self.list[i].color[3], 1)
				self.buttons[i]:Show()
			end
			self:SetHeight(#self.list*15 + (#self.buttons-1)*2 + 8)
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

function PC.SettingsList:RemoveRow(index)
	for i = index+1, self.visibleRows do self.rows[i-1]:SetData(self.rows[i]:GetData()); end
	self.rows[self.visibleRows]:Hide()

	self.visibleRows = self.visibleRows - 1
	self:UpdateSize()
end

function PC.SettingsList:Up(index)
	if index == 1 then return; end
	local data = self.rows[index-1]:GetData()
	self.rows[index-1]:SetData(self.rows[index]:GetData())
	self.rows[index]:SetData(data)
end

function PC.SettingsList:Down(index)
	if index >= self.visibleRows then return; end
	local data = self.rows[index+1]:GetData()
	self.rows[index+1]:SetData(self.rows[index]:GetData())
	self.rows[index]:SetData(data)
end

function PC.SettingsList:GetData()
	local data = {}
	for i = 1, self.visibleRows do
		table.insert(data, self.rows[i]:GetData())
	end
	return data
end

function PC.SettingsList:SetData(data)
	for i = 1, self.visibleRows do self.rows[i]:Hide(); end
	self.visibleRows = 0
	for k,v in ipairs(data) do self:GetRow():SetData(v); end
end

function PC.SettingsList:ClearFocus()
	for i = 1, self.visibleRows do self.rows[i].edit:ClearFocus(); end
end

function PC.SettingsList:UpdatePlayers()
	if self.players then
		self.players:Hide()
		for i = 1, math.min(#self.players.list, #self.players.buttons) do self.players.buttons[i]:Hide(); end
		self.players.list = {}

		if IsInRaid() then
			for i = 1, 40 do
				local name = UnitName("raid"..i)
				if name then
					local _, className = UnitClass("raid"..i)
					table.insert(self.players.list, {name=name, color=ClassColor(className)});
				end
			end
		elseif IsInGroup() then
			for i = 1, 4 do
				local name = UnitName("party"..i)
				if name then
					local _, className = UnitClass("party"..i)
					table.insert(self.players.list, {name=name, color=ClassColor(className)});
				end
			end
		end

		if #self.players.list == 0 then
			local name = UnitName("player")
			if name then
				local _, className = UnitClass("player")
				table.insert(self.players.list, {name=name, color=ClassColor(className)});
			end
		end

		if #self.players.list > 1 then
			table.sort(self.players.list, function(left, right) return string.lower(left.name) < string.lower(right.name); end)
		end
	end
end
