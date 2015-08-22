-- Global Variables

-- Local Variables
local CUR_MAX = 1
local MAX_AURAS = 49
local LOADED = false
local INITIALIZED = false
local SELECTED = 1

-- Functions

function MPowa_OnLoad()
	SLASH_MPOWA1 = "/mpowa"
	SLASH_MPOWA2 = "/MPOWA"
	SlashCmdList["MPOWA"] = function(msg)
		MPowa_Show()
	end
end

function MPowa_Show()
	if LOADED and (not INITIALIZED) then
		for i=1, CUR_MAX do
			MPowa_CreateButton(i)
		end
		if CUR_MAX > 0 then
			getglobal("ConfigButton1_Border"):Show()
		end
		INITIALIZED = true
	end
	MPowa_MainFrame:Show()
end

function MPowa_OnEvent(event)
	if event == "ADDON_LOADED" then
		if MPOWA_SAVE == nil then
			MPOWA_SAVE = {}
			for i=1, 49 do
				MPowa_CreateSave(i)
			end
		end
		CUR_MAX = MPowa_getNumUsed()
		LOADED = true
	end
end

function MPowa_CreateSave(i)
	MPOWA_SAVE[i] = {
		texture = "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga",
		anim1 = 1,
		anim2 = 0,
		speed = 1.00,
		begin = 0,
		duration = 0,
		alpha = 0.75,
		size = 0.75,
		torsion = 1,
		symetrie = 0,
		x = 0,
		y = -30,
		buffname = "",
		isdebuff = false,
		isdebufftype = false,
		timer = false,
		inverse = false,
		used = false,
	}
end

function MPowa_getNumUsed()
	for i=1, 49 do
		if (not MPOWA_SAVE[i].used) then
			return i-1
		else
			if i == 49 then
				return 49
			end
		end
	end
end

function MPowa_CreateButton(i)
	local button = CreateFrame("Button","ConfigButton"..i,MPowa_ButtonContainer,"MPowa_ContainerBuffButtonTemplate")
	MPowa_ApplyAttributesToButton(i, button)
end

function MPowa_ApplyAttributesToButton(i, button)
	button:ClearAllPoints()
	button:SetPoint("TOPLEFT",MPowa_ButtonContainer,"TOPLEFT",42*(i-1)+6 - floor((i-1)/7)*7*42,-11-floor((i-1)/7)*41)
	button:SetID(i)
	getglobal("ConfigButton"..i.."_Icon"):SetTexture(MPOWA_SAVE[i].texture)
	getglobal("ConfigButton"..i.."_Count"):SetText(i)
	getglobal("ConfigButton"..i.."_Border"):Hide()
	button:Show()
end

function MPowa_AddAura()
	if CUR_MAX < 49 then
		CUR_MAX = CUR_MAX + 1
		if getglobal("ConfigButton"..CUR_MAX) ~= nil then
			MPowa_ApplyAttributesToButton(CUR_MAX,getglobal("ConfigButton"..CUR_MAX))
		else
			MPowa_CreateButton(CUR_MAX)
		end
		MPOWA_SAVE[CUR_MAX].used = true
		MPowa_DeselectAll()
		getglobal("ConfigButton"..CUR_MAX.."_Border"):Show()
		SELECTED = CUR_MAX
	end
end

function MPowa_DeselectAll()
	for i=1, CUR_MAX do
		getglobal("ConfigButton"..i.."_Border"):Hide()
	end
end

function MPowa_SelectAura(button)
	SELECTED = button:GetID()
	MPowa_DeselectAll()
	getglobal("ConfigButton"..SELECTED.."_Border"):Show()
end

function MPowa_Remove()
	table.remove(MPOWA_SAVE, SELECTED)
	MPowa_CreateSave(49)
	CUR_MAX = CUR_MAX - 1
	MPowa_Reposition()
	SELECTED = 1
	getglobal("ConfigButton"..SELECTED.."_Border"):Show()
end

function MPowa_Reposition()
	for i=1, CUR_MAX+1 do
		getglobal("ConfigButton"..i):Hide()
	end
	for i=1, CUR_MAX do
		MPowa_ApplyAttributesToButton(i,getglobal("ConfigButton"..i))
	end
end