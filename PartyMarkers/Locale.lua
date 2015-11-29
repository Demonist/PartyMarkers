local L = {}
local locale = GetLocale()

L["settings"] = "Settings"
L["profile"] = "Profile"
L["commonProfile"] = "[Common]"

--------------------------------   ruRU:   -------------------------------------

if locale == "ruRU" then
	L["settings"] = "Настройка"
	L["profile"] = "Профиль"
	L["commonProfile"] = "[Общий]"
end

--------------------------------   deDE:   -------------------------------------

if locale == "deDE" then
	L["settings"] = "Einstellungen"
end

--------------------------------   esES:   -------------------------------------

if locale == "esES" then
	L["settings"] = "Ajustes"
end

--------------------------------   frFR:   -------------------------------------

if locale == "frFR" then
	L["settings"] = "Paramètres"
end

--------------------------------   itIT:   -------------------------------------

if locale == "itIT" then
	L["settings"] = "Impostazioni"
end

--------------------------------   ptBR:   -------------------------------------

if locale == "ptBR" then
	L["settings"] = "Configurações"
end

--------------------------------   zhCN:   -------------------------------------

if locale == "zhCN" then
	L["settings"] = "设置"
end

--------------------------------   zhTW:   -------------------------------------

if locale == "zhTW" then
	L["settings"] = "設置"
end

--------------------------------   koKR:   -------------------------------------

if locale == "koKR" then
	L["settings"] = "설정"
end

PC = {}
PC.L = L
