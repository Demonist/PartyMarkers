local L = PC.L

function PC.ClassColor(className)
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

PC.icons = {}
for i = 1, 8 do
	table.insert(PC.icons, "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_"..i)
end
