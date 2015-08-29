-- Global Variables
LOADED = false

-- Local Variables
local CUR_MAX = 1
local MAX_AURAS = 49
local INITIALIZED = false
local SELECTED = 1
local CUR_EDIT = 1
local TEST_ALL = false
local ISMOUNTED = false
local INBATTLEGROUND = false

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
		INITIALIZED = true
	end
	for i=1, CUR_MAX do
		MPowa_ApplyAttributesToButton(i, getglobal("ConfigButton"..i))
	end
	if CUR_MAX > 0 then
		getglobal("ConfigButton"..SELECTED.."_Border"):Show()
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
			if MPOWA_SAVE[i].enemytarget == nil then MPOWA_SAVE[i].enemytarget = false end
			if MPOWA_SAVE[i].friendlytarget == nil then MPOWA_SAVE[i].friendlytarget = false end
			if MPOWA_SAVE[i].stacks == nil then MPOWA_SAVE[i].stacks = ">=0" end
			if MPOWA_SAVE[i].targetduration == nil then MPOWA_SAVE[i].targetduration = 0 end
			if MPOWA_SAVE[i].alive == nil then MPOWA_SAVE[i].alive = 0 end
			if MPOWA_SAVE[i].mounted == nil then MPOWA_SAVE[i].mounted = 0 end
			if MPOWA_SAVE[i].incombat == nil then MPOWA_SAVE[i].incombat = 0 end
			if MPOWA_SAVE[i].inparty == nil then MPOWA_SAVE[i].inparty = 0 end
			if MPOWA_SAVE[i].inraid == nil then MPOWA_SAVE[i].inraid = 0 end
			if MPOWA_SAVE[i].inbattleground == nil then MPOWA_SAVE[i].inbattleground = 0 end
			MPowa_CreateIcons(i)
		end
		
		LOADED = true
	elseif event == "UNIT_AURA" then
		if arg1 == "target" then
			MPowa_Update()
		end
	else
		MPowa_Update()
	end
end

function MPowa_Update()
	MPowa_HideAllIcons()
	MPowa_SearchAuras()
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
		cooldown = false,
		enemytarget = false,
		friendlytarget = false,
		stacks = ">=0",
		targetduration = 0,
		alive = 0,
		mounted = 0,
		incombat = 0,
		inparty = 0,
		inraid = 0,
		inbattleground = 0,
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

function MPowa_EditProfile()
	if MPowa_ProfileFrame:IsVisible() then
		MPowa_ProfileFrame:Hide()
	else
		MPowa_ProfileFrame:Show()
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
		if SELECTED == CUR_EDIT then
			MPowa_ConfigFrame:Hide()
		end
		getglobal("TextureFrame"..SELECTED):Hide()
		SELECTED = 1
		getglobal("ConfigButton"..SELECTED.."_Border"):Show()
		MPowa_Reposition()
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
		MPowa_ConfigFrame:Hide()
		CUR_EDIT = SELECTED
		getglobal("MPowa_ConfigFrame_Container_1_Icon_Texture"):SetTexture(MPOWA_SAVE[CUR_EDIT].texture)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_Opacity"):SetValue(MPOWA_SAVE[CUR_EDIT].alpha)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_OpacityText"):SetText(MPOWA_SLIDER_OPACITY.." "..MPOWA_SAVE[CUR_EDIT].alpha)
		
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosX"):SetMinMaxValues(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].x),MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].x))
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosX"):SetValue(MPOWA_SAVE[CUR_EDIT].x)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosXText"):SetText(MPOWA_SLIDER_POSX.." "..MPOWA_SAVE[CUR_EDIT].x)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosXLow"):SetText(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].x))
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosXHigh"):SetText(MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].x))
		
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosY"):SetMinMaxValues(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].y),MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].y))
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosY"):SetValue(MPOWA_SAVE[CUR_EDIT].y)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosYText"):SetText(MPOWA_SLIDER_POSY.." "..MPOWA_SAVE[CUR_EDIT].y)
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosYLow"):SetText(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].y))
		getglobal("MPowa_ConfigFrame_Container_1_Slider_PosYHigh"):SetText(MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].y))
		
		getglobal("MPowa_ConfigFrame_Container_1_Slider_Size"):SetValue(tonumber(MPOWA_SAVE[CUR_EDIT].size))
		getglobal("MPowa_ConfigFrame_Container_1_Slider_SizeText"):SetText(MPOWA_SLIDER_SIZE.." "..MPOWA_SAVE[CUR_EDIT].size)
		getglobal("MPowa_ConfigFrame_Container_1_2_Editbox"):SetText(MPOWA_SAVE[CUR_EDIT].buffname)
		getglobal("MPowa_ConfigFrame_Container_1_2_Editbox_Stacks"):SetText(MPOWA_SAVE[CUR_EDIT].stacks)
		getglobal("MPowa_ConfigFrame_Container_1_2_Editbox_DebuffDuration"):SetText(MPOWA_SAVE[CUR_EDIT].targetduration)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Debuff"):SetChecked(MPOWA_SAVE[CUR_EDIT].isdebuff)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowIfNotActive"):SetChecked(MPOWA_SAVE[CUR_EDIT].inverse)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Timer"):SetChecked(MPOWA_SAVE[CUR_EDIT].timer)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowCooldowns"):SetChecked(MPOWA_SAVE[CUR_EDIT].cooldown)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_EnemyTarget"):SetChecked(MPOWA_SAVE[CUR_EDIT].enemytarget)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_FriendlyTarget"):SetChecked(MPOWA_SAVE[CUR_EDIT].friendlytarget)
		if MPOWA_SAVE[CUR_EDIT].isdebuff or MPOWA_SAVE[CUR_EDIT].enemytarget or MPOWA_SAVE[CUR_EDIT].friendlytarget then
			getglobal("MPowa_ConfigFrame_Container_1_2_Editbox_DebuffDuration"):Show()
		else
			getglobal("MPowa_ConfigFrame_Container_1_2_Editbox_DebuffDuration"):Hide()
		end
		MPowa_TernarySetState(getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Alive"), MPOWA_SAVE[CUR_EDIT].alive)
		MPowa_TernarySetState(getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Mounted"), MPOWA_SAVE[CUR_EDIT].mounted)
		MPowa_TernarySetState(getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_InCombat"), MPOWA_SAVE[CUR_EDIT].incombat)
		MPowa_TernarySetState(getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_InParty"), MPOWA_SAVE[CUR_EDIT].inparty)
		MPowa_TernarySetState(getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_InRaid"), MPOWA_SAVE[CUR_EDIT].inraid)
		MPowa_TernarySetState(getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_InBattleground"), MPOWA_SAVE[CUR_EDIT].inbattleground)
		MPowa_ConfigFrame:Show()
	end
end

function MPowa_GetMaxValues(val)
	val = tonumber(val)
	if val > 0 then
		return 100*ceil(val/100)+50
	else
		return -(100*ceil(-1*(val)/100)-100)
	end
end

function MPowa_GetMinValues(val)
	val = tonumber(val)
	if val > 0 then
		return 100*ceil(val/100)-50
	else
		return -(100*ceil(-1*(val)/100))
	end
end

function MPowa_CreateIcons(i)
	local frame = CreateFrame("Frame", "TextureFrame"..i, UIParent, "MPowa_IconTemplate")
	frame:SetID(i)
	getglobal("TextureFrame"..i.."_Icon"):SetTexture(MPOWA_SAVE[i].texture)
	MPowa_ApplyConfig(i)
	frame:Hide()
end

function MPowa_IsMounted()
	ISMOUNTED = false
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	local i = 0
	while true do
		GameTooltip:ClearLines()
		GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local desc = GameTooltipTextLeft2:GetText()
		if (not desc) then break end
		if strfind(desc, "Increases speed by 100") or strfind(desc, "Increases speed by 60") then
			ISMOUNTED = true
		end
		i = i + 1
	end
end

function MPowa_IsInParty()
	if GetNumPartyMembers() > 1 then
		return true
	else
		return false
	end
end

function MPowa_IsInBattleground()
	INBATTLEGROUND = false
	for i=1, 4 do
		local status, mapName, instanceID, lowestlevel, highestlevel, teamSize, registeredMatch = GetBattlefieldStatus(i)
		if status == 3 then
			INBATTLEGROUND = true
		end
	end
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
	-- Setting Conditions
	MPowa_IsMounted()
	MPowa_IsInBattleground()
	
	-- To enable to show cooldowns
	for p=1, CUR_MAX do
		if MPOWA_SAVE[p].cooldown or MPOWA_SAVE[p].inverse then
			if MPOWA_SAVE[p].test or TEST_ALL then MPOWA_SAVE[p].test = false; TEST_ALL = false end
				MPowa_TextureFrame_Update(99, getglobal("TextureFrame"..p))
		end
	end
	
	-- Rest
	local i = 0
	while true do
		local buff
		local debuff
		-- HELPFUL
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		
		for p=1, CUR_MAX do
			buff = nil
			if MPOWA_SAVE[p].enemytarget or MPOWA_SAVE[p].friendlytarget then
				GameTooltip:SetUnitBuff("target", i+1)
				buff = GameTooltipTextLeft1:GetText()
			else
				GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
				buff = GameTooltipTextLeft1:GetText()
			end
			if (buff ~= nil) then
				--DEFAULT_CHAT_FRAME:AddMessage(buff.." I: "..i.." P: "..p)
				if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(buff)) and (not MPOWA_SAVE[p].isdebuff) then
					if MPOWA_SAVE[p].test or TEST_ALL then MPOWA_SAVE[p].test = false; TEST_ALL = false end
					getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
					MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
					if MPOWA_SAVE[p].inverse then
						getglobal("TextureFrame"..p):Hide()
					end
					--DEFAULT_CHAT_FRAME:AddMessage(buff.." I: "..i.." P: "..p)
					break
				end
			end
		end
		-- HARMFUL
		for p=1, CUR_MAX do
			debuff = nil
			GameTooltip:ClearLines()
			if MPOWA_SAVE[p].enemytarget or MPOWA_SAVE[p].friendlytarget then
				GameTooltip:SetUnitDebuff("target", i+1)
				debuff = GameTooltipTextLeft1:GetText()
			else
				GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HARMFUL"))
				debuff = GameTooltipTextLeft1:GetText()
			end
			if (debuff ~= nil) then
				if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(debuff)) and MPOWA_SAVE[p].isdebuff then
					if MPOWA_SAVE[p].test or TEST_ALL then MPOWA_SAVE[p].test = false; TEST_ALL = false end
					getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
					MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
					if MPOWA_SAVE[p].inverse then
						getglobal("TextureFrame"..p):Hide()
					end
					break
				end
			end
		end
		GameTooltip:Hide()
		if (buff == nil) and (debuff == nil) then break end
		i = i + 1
	end
end

function MPowa_TernaryReturn(id, var, real)
	if MPOWA_SAVE[id][var] == 0 then
		return true
	elseif MPOWA_SAVE[id][var] == true and real then
		return true
	elseif MPOWA_SAVE[id][var] == false and (not real) then
		return true
	end
end

function MPowa_ReverseBoolean(bool)
	if bool then
		return false
	else
		return true
	end
end

function MPowa_TextureFrame_Update(bi, button)
	if MPowa_TernaryReturn(button:GetID(), "alive", MPowa_ReverseBoolean(UnitIsDeadOrGhost("player"))) and MPowa_TernaryReturn(button:GetID(), "mounted", ISMOUNTED) and MPowa_TernaryReturn(button:GetID(), "incombat", UnitAffectingCombat("player")) and MPowa_TernaryReturn(button:GetID(), "inparty", MPowa_IsInParty()) and MPowa_TernaryReturn(button:GetID(), "inraid", UnitInRaid("player")) and MPowa_TernaryReturn(button:GetID(), "inbattleground", INBATTLEGROUND) then
		local buffIndex, enemy
		local englishFaction, _ = UnitFactionGroup("target")
		local penglishFaction, _ = UnitFactionGroup("player")
		if penglishFaction == "Alliance" then enemy = "Horde" else enemy = "Alliance" end
		if MPOWA_SAVE[button:GetID()].isdebuff then
			if ((MPOWA_SAVE[button:GetID()].enemytarget and englishFaction == enemy) or (MPOWA_SAVE[button:GetID()].friendlytarget and englishFaction ~= enemy)) then
				buffIndex = 0
			else
				buffIndex = GetPlayerBuff(bi, "HARMFUL")
			end
		else
			if ((MPOWA_SAVE[button:GetID()].enemytarget and englishFaction == enemy) or (MPOWA_SAVE[button:GetID()].friendlytarget and englishFaction ~= enemy)) then
				buffIndex = 0
			else
				buffIndex = GetPlayerBuff(bi, "HELPFUL")
			end
		end
		if (buffIndex > -1) or bi == 99 then
			local buffApplications = GetPlayerBuffApplications(buffIndex)
			if (MPowa_IsStacks(buffApplications, button:GetID()) or MPowa_IsStacks(button.count, button:GetID())) then
				local texture
				if MPOWA_SAVE[button:GetID()].enemytarget or MPOWA_SAVE[button:GetID()].friendlytarget then
					local a,b,c = nil
					if MPOWA_SAVE[button:GetID()].isdebuff then
						a, b, c = UnitDebuff("target", bi+1)
					else
						a, b = UnitBuff("target", bi+1)
					end
					texture = a
				else
					texture = GetPlayerBuffTexture(buffIndex)
				end
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
				--Icon:SetTexture(texture)
				
				-- Enabling Count for certain buffs and Holy Strength
				if (button.count > 1 or buffApplications > 1) then
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
		end
	end
end

function MPowa_IsStacks(count, id)
	if MPOWA_SAVE[id].stacks ~= "" then
		local con = strsub(MPOWA_SAVE[id].stacks, 1, 2)
		local amount = tonumber(strsub(MPOWA_SAVE[id].stacks, 3))
		if amount ~= nil and con ~= nil then
			if con == ">=" and count >= amount then
				return true
			elseif con == "<=" and count <= amount then
				return true
			end
		end
		con = strsub(MPOWA_SAVE[id].stacks, 1, 1)
		amount = tonumber(strsub(MPOWA_SAVE[id].stacks, 2))
		if amount ~= nil and con ~= nil then
			if con == "<" and count < amount then
				return true
			elseif con == ">" and count > amount then
				return true
			elseif con == "=" and count == amount then
				return true
			elseif con == "!" and count ~= amount then
				return true
			end
		end
		con = string.find(MPOWA_SAVE[id].stacks, "-")
		local amount1 = tonumber(strsub(MPOWA_SAVE[id].stacks, 1, con-1))
		local amount2 = tonumber(strsub(MPOWA_SAVE[id].stacks, con+1))
		if con and amount1 and amount2 and ((count >= amount1 and count <= amount2) or (count >= amount2 and count <= amount1)) then
			return true
		end
	end
end

function MPowa_TextureFrame_OnUpdate(elapsed, button)
	if MPOWA_SAVE[button:GetID()].timer then
		local Duration = getglobal(button:GetName().."_Timer")
		if (not MPOWA_SAVE[button:GetID()].test and (not TEST_ALL)) then
			if MPOWA_SAVE[button:GetID()].cooldown then
				local start, duration = MPowa_GetSpellCooldown(MPOWA_SAVE[button:GetID()].buffname)
				if start > 0 and duration > 0 then
					Duration:SetText(duration-(GetTime()-start))
					Duration:Show()
				else
					button:Hide()
					Duration:Hide()
				end
			else
				local buffIndex
				local timeLeft
				if MPOWA_SAVE[button:GetID()].enemytarget or MPOWA_SAVE[button:GetID()].friendlytarget then
					timeLeft = 0
					if (not button.tdurationstart) then
						button.tduration = MPOWA_SAVE[button:GetID()].targetduration
						button.tdurationstart = GetTime()
					end
					if ((button.tdurationstart+button.tduration) >= GetTime()) and button.tduration ~= 0 then
						if MPOWA_SAVE[button:GetID()].timer then
							Duration:SetText(string.format("%.2f", (-GetTime()+button.tduration+button.tdurationstart)))
						else
							Duration:SetText(string.format("%.0f", (-GetTime()+button.tduration+button.tdurationstart)))
						end
					else
						Duration:SetText("")
						button.tdurationstart = nil
					end
				else
					if MPOWA_SAVE[button:GetID()].isdebuff then
						buffIndex = GetPlayerBuff(button.bi, "HARMFUL")
					else
						buffIndex = GetPlayerBuff(button.bi, "HELPFUL")
					end
					timeLeft = GetPlayerBuffTimeLeft(buffIndex)
				end
				if MPOWA_SAVE[button:GetID()].timer and timeLeft > 0 then
					Duration:SetText(string.format("%.2f", timeLeft))
				elseif (not MPOWA_SAVE[button:GetID()].timer) and timeLeft > 0 then
					Duration:SetText(string.format("%.0f", timeLeft))
				end
				if timeLeft == 0 and (not MPOWA_SAVE[button:GetID()].enemytarget) and (not MPOWA_SAVE[button:GetID()].friendlytarget) then Duration:SetText("") end
			end	
		else
			Duration:SetText(random(1,23)+random(1,60)/100)
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
	MPOWA_SAVE[CUR_EDIT][var] = string.format("%.2f", obj:GetValue())
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

function MPowa_Editbox_Stacks(obj)
	local oldcon = MPOWA_SAVE[CUR_EDIT].stacks
	MPOWA_SAVE[CUR_EDIT].stacks = obj:GetText()
	if oldcon ~= MPOWA_SAVE[CUR_EDIT].stacks then
		MPowa_Update()
	end
end

function MPowa_Checkbutton(var)
	if MPOWA_SAVE[CUR_EDIT][var] then
		MPOWA_SAVE[CUR_EDIT][var] = false
	else
		MPOWA_SAVE[CUR_EDIT][var] = true
	end
	MPowa_Update()
end

function MPowa_Editbox_Duration(obj)
	MPOWA_SAVE[CUR_EDIT].targetduration = tonumber(obj:GetText())
	MPowa_Update()
end

function MPowa_TernarySetState(button, value)
	local label = getglobal(button:GetName().."Text")
	button:Enable();
	label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

	if value==0 then
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		button:SetChecked(0)
	elseif value==false then
		button:SetCheckedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		button:SetChecked(1)
	elseif value==true then
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		button:SetChecked(1)
	end
end

function MPowa_Ternary_OnClick(obj, var)
	if (MPOWA_SAVE[CUR_EDIT][var]==0) then
		MPOWA_SAVE[CUR_EDIT][var] = true; -- Ignore => On
	elseif (MPOWA_SAVE[CUR_EDIT][var]==true) then
		MPOWA_SAVE[CUR_EDIT][var] = false; -- On => Off
	else
		MPOWA_SAVE[CUR_EDIT][var] = 0; -- Off => Ignore
	end	

	MPowa_TernarySetState(obj, MPOWA_SAVE[CUR_EDIT][var])
	MPowa_Update()
end