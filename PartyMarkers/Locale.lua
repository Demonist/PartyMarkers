local L = {}
local locale = GetLocale()

L["settings"] = "Settings"
L["profile"] = "Profile"
L["commonProfile"] = "[Common]"
L["load"] = "Load"
L["save"] = "Save"
L["remove"] = "Remove"

--------------------------------   ruRU:   -------------------------------------

if locale == "ruRU" then
	L["settings"] = "Настройка"
	L["profile"] = "Профиль"
	L["commonProfile"] = "[Общий]"
	L["load"] = "Загрузить"
	L["save"] = "Сохранить"
	L["remove"] = "Удалить"
end

--------------------------------   deDE:   -------------------------------------

if locale == "deDE" then
	L["settings"] = "Einstellungen"
	L["profile"] = "Profil"
	L["commonProfile"] = "[Gemeinsam]"
	L["load"] = "Belastung"
	L["save"] = "Sparen"
	L["remove"] = "Entfernen"
end

--------------------------------   esES:   -------------------------------------

if locale == "esES" then
	L["settings"] = "Ajustes"
	["profile"] = "Perfil"
	L["commonProfile"] = "[Común]"
	L["load"] = "Carga"
	L["save"] = "Ahorrar"
	L["remove"] = "Eliminar"
end

--------------------------------   frFR:   -------------------------------------

if locale == "frFR" then
	L["settings"] = "Paramètres"
	["profile"] = "Profil"
	L["commonProfile"] = "[Commun]"
	L["load"] = "Charge"
	L["save"] = "Sauvegarder"
	L["remove"] = "Retirer"
end

--------------------------------   itIT:   -------------------------------------

if locale == "itIT" then
	L["settings"] = "Impostazioni"
	["profile"] = "Profilo"
	L["commonProfile"] = "[Comune]"
	L["load"] = "Caricare"
	L["save"] = "Salvare"
	L["remove"] = "Rimuovere"
end

--------------------------------   ptBR:   -------------------------------------

if locale == "ptBR" then
	L["settings"] = "Configurações"
	["profile"] = "Perfil"
	L["commonProfile"] = "[Comum]"
	L["load"] = "Carregar"
	L["save"] = "Guardar"
	L["remove"] = "Remover"
end

--------------------------------   zhCN:   -------------------------------------

if locale == "zhCN" then
	L["settings"] = "设置"
	["profile"] = "简介"
	L["commonProfile"] = "[共同]"
	L["load"] = "加载"
	L["save"] = "保存"
	L["remove"] = "删除"
end

--------------------------------   zhTW:   -------------------------------------

if locale == "zhTW" then
	L["settings"] = "設置"
	["profile"] = "簡介"
	L["commonProfile"] = "[共同]"
	L["load"] = "加載"
	L["save"] = "保存"
	L["remove"] = "刪除"
end

--------------------------------   koKR:   -------------------------------------

if locale == "koKR" then
	L["settings"] = "설정"
	["profile"] = "윤곽"
	L["commonProfile"] = "[공유지]"
	L["load"] = "하중"
	L["save"] = "구하다"
	L["remove"] = "풀다"
end

PC = {}
PC.L = L
