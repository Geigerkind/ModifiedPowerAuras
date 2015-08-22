-- Global Variables
LOADED = false

-- Local Variables
local CUR_MAX = 1
local MAX_AURAS = 49
local INITIALIZED = false
local SELECTED = 1
local CUR_EDIT = 1
local TEST_ALL = false

-- Functions

function MPowa_OnLoad()
	SLASH_MPOWA1 = "/mpowa"
	SLASH_MPOWA2 = "/MPOWA"
	SlashCmdList["MPOWA"] = function(msg)
		if MPowa_MainFrame:IsVisible() then
			MPowa_MainFrame:Hide()
		else
			MPowa_Show()
		end
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
	for i=1, CUR_MAX do
		MPowa_ApplyAttributesToButton(i, getglobal("ConfigButton"..i))
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
		
		for i=1, CUR_MAX do
			MPowa_CreateIcons(i)
		end
		
		LOADED = true
	elseif event == "PLAYER_AURAS_CHANGED" then
		MPowa_HideAllIcons()
		MPowa_SearchAuras()
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
		test = false,
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
			MPowa_ApplyConfig(CUR_MAX)
		else
			MPowa_CreateButton(CUR_MAX)
			MPowa_CreateIcons(CUR_MAX)
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
	if ConfigButton1 then
		table.remove(MPOWA_SAVE, SELECTED)
		MPowa_CreateSave(49)
		CUR_MAX = CUR_MAX - 1
		MPowa_Reposition()
		if SELECTED == CUR_EDIT then
			MPowa_ConfigFrame:Hide()
		end
		SELECTED = 1
		getglobal("ConfigButton"..SELECTED.."_Border"):Show()
	end
end

function MPowa_Reposition()
	for i=1, CUR_MAX+1 do
		getglobal("ConfigButton"..i):Hide()
	end
	for i=1, CUR_MAX do
		MPowa_ApplyAttributesToButton(i,getglobal("ConfigButton"..i))
	end
end

function MPowa_TestAll()
	if ConfigButton1 then
		if TEST_ALL then
			TEST_ALL = false
			for i=1, CUR_MAX do
				if getglobal("TextureFrame"..i).bi == nil then
					getglobal("TextureFrame"..i):Hide()
				end
			end
		else
			TEST_ALL = true
			for i=1, CUR_MAX do
				getglobal("TextureFrame"..i):Show()
			end
		end
	end
end

function MPowa_Test()
	if ConfigButton1 then
		if MPOWA_SAVE[SELECTED].test then
			MPOWA_SAVE[SELECTED].test = false
			if getglobal("TextureFrame"..SELECTED).bi == nil then
				getglobal("TextureFrame"..SELECTED):Hide()
			end
		else
			MPOWA_SAVE[SELECTED].test = true
			getglobal("TextureFrame"..SELECTED):Show()
		end
	end
end

function MPowa_Edit()
	if ConfigButton1 then
		CUR_EDIT = SELECTED
		getglobal("MPowa_ConfigFrame_Container_1_Icon_Texture"):SetTexture(MPOWA_SAVE[CUR_EDIT].texture)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_Opacity"):SetValue(MPOWA_SAVE[CUR_EDIT].alpha)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_OpacityText"):SetText(MPOWA_SLIDER_OPACITY.." "..MPOWA_SAVE[CUR_EDIT].alpha)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosX"):SetValue(MPOWA_SAVE[CUR_EDIT].x)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosXText"):SetText(MPOWA_SLIDER_POSX.." "..MPOWA_SAVE[CUR_EDIT].x)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosY"):SetValue(MPOWA_SAVE[CUR_EDIT].y)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosYText"):SetText(MPOWA_SLIDER_POSY.." "..MPOWA_SAVE[CUR_EDIT].y)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_Size"):SetValue(MPOWA_SAVE[CUR_EDIT].size)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_SizeText"):SetText(MPOWA_SLIDER_SIZE.." "..MPOWA_SAVE[CUR_EDIT].size)
		getglobal("MPowa_ConfigFrame_Container_1_2_Editbox"):SetText(MPOWA_SAVE[CUR_EDIT].buffname)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Debuff"):SetChecked(MPOWA_SAVE[CUR_EDIT].isdebuff)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowIfNotActive"):SetChecked(MPOWA_SAVE[CUR_EDIT].inverse)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Timer"):SetChecked(MPOWA_SAVE[CUR_EDIT].timer)
		MPowa_ConfigFrame:Show()
	end
end

function MPowa_CreateIcons(i)
	local frame = CreateFrame("Frame", "TextureFrame"..i, UIParent, "MPowa_IconTemplate")
	frame:SetID(i)
	getglobal("TextureFrame"..i.."_Icon"):SetTexture(MPOWA_SAVE[i].texture)
	MPowa_ApplyConfig(i)
	frame:Hide()
end

function MPowa_HideAllIcons()
	for i=1, CUR_MAX do
		if (not MPOWA_SAVE[i].test) then
			getglobal("TextureFrame"..i):Hide()
		end
		getglobal("TextureFrame"..i).bi = nil
		getglobal("TextureFrame"..i).count = 0
	end
end

function MPowa_SearchAuras()
	local i = 0
	while true do
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local buff = GameTooltipTextLeft1:GetText()
		GameTooltip:Hide()
		if (buff == nil) then break end
		for p=1, CUR_MAX do
			if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(buff)) then
				if MPOWA_SAVE[p].test then MPOWA_SAVE[p].test = false end
				getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
				MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
				break
			end
		end
		i = i + 1
	end
end

function MPowa_TextureFrame_Update(bi, button)
	local buffIndex = GetPlayerBuff(bi, "HELPFUL")
	local texture = GetPlayerBuffTexture(buffIndex)
	local Icon = getglobal(button:GetName().."_Icon")
	local Count = getglobal(button:GetName().."_Count")
	
	-- Correctly saving the texture
	if MPOWA_SAVE[button:GetID()].texture == "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga" and texture then
		MPOWA_SAVE[button:GetID()].texture = texture
		for i=1, CUR_MAX do
			MPowa_ApplyAttributesToButton(i, getglobal("ConfigButton"..i))
		end
		if button:GetID() == CUR_EDIT then
			getglobal("MPowa_ConfigFrame_Container_1_Icon_Texture"):SetTexture(MPOWA_SAVE[CUR_EDIT].texture)
		end
	end
	
	Icon:SetTexture(MPOWA_SAVE[button:GetID()].texture)
	
	-- Enabling Count for certain buffs and Holy Strength
	local buffApplications = GetPlayerBuffApplications(buffIndex)
	
	if button.count > 1 or buffApplications > 1 then
		Count:SetText(buffApplications)
		if button.count > 1 then
			Count:SetText(button.count)
		end
		Count:Show()
	else
		Count:Hide()
	end
	
	button.bi = bi
	
	button:Show()
end

function MPowa_TextureFrame_OnUpdate(elapsed, button)
	local Duration = getglobal(button:GetName().."_Timer")
	if (not MPOWA_SAVE[button:GetID()].test and (not TEST_ALL)) then
		local timeLeft = GetPlayerBuffTimeLeft(GetPlayerBuff(button.bi, "HELPFUL"))
		Duration:SetText(floor(timeLeft))
		
		-- Get Spellcooldown
		local start, duration, enabled = GetSpellCooldown(MPowa_GetSpellSlot(MPOWA_SAVE[button:GetID()].buffname), "spell")
		
		if start > 0 and duration > 0 and enabled then
			Duration:SetText(GetTime()-start)
			Duration:Show()
		else
			Duration:SetText("")
			Duration:Hide()
		end
		
	else
		Duration:SetText(random(1,23)+random(1,60)/100)
		local start, duration = MPowa_GetSpellCooldown(MPOWA_SAVE[button:GetID()].buffname)
		if start > 0 and duration > 0 then
			Duration:SetText(duration-(GetTime()-start))
			Duration:Show()
		else
			Duration:Hide()
		end
	end
end

function MPowa_GetSpellCooldown(buff)
	-- Get Spellcooldown
	local start, duration, enabled = GetSpellCooldown(MPowa_GetSpellSlot(buff), "spell")
	
	-- Get Inventory Cooldown
	if start == 0 and duration == 0 then
		for i=1, 18 do
			start, duration, enable = GetInventoryItemCooldown("player", i)
			local _,_,name = string.find(GetInventoryItemLink("player",i) or "","^.*%[(.*)%].*$")
			if strfind(strlower(buff), strlower(name)) then
				return start, duration
			elseif i == 18 and start == 0 and duration == 0 then
				-- Get Container Item Cooldown
				for p=0, 4 do
					for u=1, GetContainerNumSlots(p) do
						start, duration, enable = GetContainerItemCooldown(p,u)
						_,_,name=string.find(GetContainerItemLink(p,u) or "","^.*%[(.*)%].*$")
						if (not name) then break end
						if strfind(strlower(buff), strlower(name)) then
							return start, duration
						elseif p == 4 and u == GetContainerNumSlots(p) then
							return start, duration
						end
					end
				end
			end
		end
	else
		return start, duration
	end
end

function MPowa_GetSpellSlot(buff)
	local i = 1
	while true do
		local name, rank = GetSpellName(i, "spell")
		if (not name) or strfind(strlower(buff), strlower(name)) then 
			return i
		end
		i = i + 1
	end
end

function MPowa_ApplyConfig(i)
	local frame = getglobal("TextureFrame"..i)
	frame:SetAlpha(MPOWA_SAVE[i].alpha)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", MPOWA_SAVE[i].x, MPOWA_SAVE[i].y)
	frame:SetScale(MPOWA_SAVE[i].size)
end

function MPowa_SliderChange(var, obj, text)
	MPOWA_SAVE[CUR_EDIT][var] = string.format("%.1f", obj:GetValue())
	getglobal(obj:GetName().."Text"):SetText(text.." "..MPOWA_SAVE[CUR_EDIT][var])
	MPowa_ApplyConfig(CUR_EDIT)
end

function MPowa_Editbox_Name(obj)
	local oldname = MPOWA_SAVE[CUR_EDIT].buffname
	MPOWA_SAVE[CUR_EDIT].buffname = obj:GetText()
	if oldname ~= MPOWA_SAVE[CUR_EDIT].buffname then
		MPOWA_SAVE[CUR_EDIT].texture = "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga"
		getglobal("MPowa_ConfigFrame_Container_1_Icon_Texture"):SetTexture(MPOWA_SAVE[CUR_EDIT].texture)
		getglobal("ConfigButton"..CUR_EDIT.."_Icon"):SetTexture(MPOWA_SAVE[CUR_EDIT].texture)
	end
end