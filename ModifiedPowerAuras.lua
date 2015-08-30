-- Global Variables
MPOWA_LOADED = false
MPOWA_PROFILE_SELECTED = 1

-- Local Variables
local CUR_MAX = 1
local MAX_AURAS = 49
local INITIALIZED = false
local SELECTED = 1
local CUR_EDIT = 1
local TEST_ALL = false
local ISMOUNTED = false
local INBATTLEGROUND = false
local SOUND = {}
SOUND = {
	[0] = "None",
	[1] = "LEVELUP",
	[2] = "LOOTWINDOWCOINSOUND",
	[3] = "MapPing",
	[4] = "HumanExploration",
	[5] = "QUESTADDED",
	[6] = "QUESTCOMPLETED",
	[7] = "WriteQuest",
	[8] = "Fishing Reel in",
	[9] = "igPVPUpdate",
	[10] = "ReadyCheck",
	[11] = "RaidWarning",
	[12] = "AuctionWindowOpen",
	[13] = "AuctionWindowClose",
	[14] = "TellMessage",
	[15] = "igBackPackOpen",
	[16] = "aggro.ogg",
	[17] = "bam.ogg",
	[18] = "cat2.ogg",
	[19] = "cookie.ogg",
	[20] = "moan.ogg",
	[21] = "phone.ogg",
	[22] = "shot.ogg",
	[23] = "sonar.ogg",
	[24] = "splash.ogg",
	[25] = "wilhelm.ogg",
	[26] = "huh_1.ogg",
	[27] = "bear_polar.ogg",
	[28] = "bigkiss.ogg",
	[29] = "BITE.ogg",
	[30] = "PUNCH.ogg",
	[31] = "burp4.ogg",
	[32] = "chimes.ogg",
	[33] = "Gasp.ogg",
	[34] = "hic3.ogg",
	[35] = "hurricane.ogg",
	[35] = "hyena.ogg",
	[36] = "Squeakypig.ogg",
	[37] = "panther1.ogg",
	[38] = "rainroof.ogg",
	[39] = "snakeatt.ogg",
	[40] = "sneeze.ogg",
	[41] = "thunder.ogg",
	[42] = "wickedmalelaugh1.ogg",
	[43] = "wlaugh.ogg",
	[44] = "wolf5.ogg",
	[45] = "swordecho.ogg",	
	[46] = "throwknife.ogg",
	[47] = "yeehaw.ogg",
	[48] = "Fireball.ogg", 
	[49] = "rocket.ogg", 
	[50] = "Arrow_Swoosh.ogg", 
	[51] = "ESPARK1.ogg", 
	[52] = "chant4.ogg", 
	[53] = "chant2.ogg", 
	[54] = "shipswhistle.ogg", 
	[55] = "kaching.ogg", 
	[56] = "heartbeat.ogg",
};

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
	if MPOWA_LOADED and (not INITIALIZED) then
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
		if MPOWA_PROFILE == nil then
			MPOWA_PROFILE = {}
		end
		CUR_MAX = MPowa_getNumUsed()
		
		for i=1, CUR_MAX do
			MPowa_CreateIcons(i)
		end
		
		MPOWA_LOADED = true
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
		fontalpha = 1,
		fontoffsetx = 0,
		fontoffsety = 0,
		fontsize = 1.5,
		hundredth = false,
		usefontcolor = false,
		fontcolor_r = 1,
		fontcolor_g = 1,
		fontcolor_b = 1,
		usebeginsound = false,
		beginsound = 1,
		useendsound = false,
		endsound = 1,
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
		
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosX"):SetMinMaxValues(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].fontoffsetx),MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].fontoffsetx))
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosX"):SetValue(MPOWA_SAVE[CUR_EDIT].fontoffsetx)
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosXText"):SetText(MPOWA_SLIDER_POSX.." "..MPOWA_SAVE[CUR_EDIT].fontoffsetx)
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosXLow"):SetText(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].fontoffsetx))
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosXHigh"):SetText(MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].fontoffsetx))
		
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosY"):SetMinMaxValues(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].fontoffsety),MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].fontoffsety))
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosY"):SetValue(MPOWA_SAVE[CUR_EDIT].fontoffsety)
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosYText"):SetText(MPOWA_SLIDER_POSY.." "..MPOWA_SAVE[CUR_EDIT].fontoffsety)
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosYLow"):SetText(MPowa_GetMinValues(MPOWA_SAVE[CUR_EDIT].fontoffsety))
		getglobal("MPowa_ConfigFrame_Container_2_Slider_PosYHigh"):SetText(MPowa_GetMaxValues(MPOWA_SAVE[CUR_EDIT].fontoffsety))
		
		getglobal("MPowa_ConfigFrame_Container_1_Slider_Size"):SetValue(tonumber(MPOWA_SAVE[CUR_EDIT].size))
		getglobal("MPowa_ConfigFrame_Container_1_Slider_SizeText"):SetText(MPOWA_SLIDER_SIZE.." "..MPOWA_SAVE[CUR_EDIT].size)
		getglobal("MPowa_ConfigFrame_Container_2_Slider_Size"):SetValue(tonumber(MPOWA_SAVE[CUR_EDIT].fontsize))
		getglobal("MPowa_ConfigFrame_Container_2_Slider_SizeText"):SetText(MPOWA_SLIDER_SIZE.." "..MPOWA_SAVE[CUR_EDIT].fontsize)
		getglobal("MPowa_ConfigFrame_Container_2_Slider_Opacity"):SetValue(tonumber(MPOWA_SAVE[CUR_EDIT].fontalpha))
		getglobal("MPowa_ConfigFrame_Container_2_Slider_OpacityText"):SetText(MPOWA_SLIDER_OPACITY.." "..MPOWA_SAVE[CUR_EDIT].fontalpha)
		getglobal("MPowa_ConfigFrame_Container_1_2_Editbox"):SetText(MPOWA_SAVE[CUR_EDIT].buffname)
		getglobal("MPowa_ConfigFrame_Container_1_2_Editbox_Stacks"):SetText(MPOWA_SAVE[CUR_EDIT].stacks)
		getglobal("MPowa_ConfigFrame_Container_1_2_Editbox_DebuffDuration"):SetText(MPOWA_SAVE[CUR_EDIT].targetduration)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Debuff"):SetChecked(MPOWA_SAVE[CUR_EDIT].isdebuff)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowIfNotActive"):SetChecked(MPOWA_SAVE[CUR_EDIT].inverse)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_Timer"):SetChecked(MPOWA_SAVE[CUR_EDIT].timer)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowCooldowns"):SetChecked(MPOWA_SAVE[CUR_EDIT].cooldown)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_EnemyTarget"):SetChecked(MPOWA_SAVE[CUR_EDIT].enemytarget)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_FriendlyTarget"):SetChecked(MPOWA_SAVE[CUR_EDIT].friendlytarget)
		getglobal("MPowa_ConfigFrame_Container_2_2_Checkbutton_Hundreds"):SetChecked(MPOWA_SAVE[CUR_EDIT].hundredth)
		getglobal("MPowa_ConfigFrame_Container_2_2_Checkbutton_Color"):SetChecked(MPOWA_SAVE[CUR_EDIT].usefontcolor)
		getglobal("MPowa_ConfigFrame_Container_2_2_ColorpickerNormalTexture"):SetVertexColor(MPOWA_SAVE[CUR_EDIT].fontcolor_r, MPOWA_SAVE[CUR_EDIT].fontcolor_g, MPOWA_SAVE[CUR_EDIT].fontcolor_b)
		getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg").r = MPOWA_SAVE[CUR_EDIT].fontcolor_r
		getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg").g = MPOWA_SAVE[CUR_EDIT].fontcolor_g
		getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg").b = MPOWA_SAVE[CUR_EDIT].fontcolor_b
		getglobal("MPowa_ConfigFrame_Container_3_Slider_BeginSound"):SetValue(MPOWA_SAVE[CUR_EDIT].beginsound)
		getglobal("MPowa_ConfigFrame_Container_3_Slider_BeginSoundText"):SetText(MPOWA_SLIDER_BEGINSOUND..SOUND[MPOWA_SAVE[CUR_EDIT].beginsound])
		getglobal("MPowa_ConfigFrame_Container_3_Slider_EndSound"):SetValue(MPOWA_SAVE[CUR_EDIT].endsound)
		getglobal("MPowa_ConfigFrame_Container_3_Slider_EndSoundText"):SetText(MPOWA_SLIDER_BEGINSOUND..SOUND[MPOWA_SAVE[CUR_EDIT].endsound])
		getglobal("MPowa_ConfigFrame_Container_3_Checkbutton_BeginSound"):SetChecked(MPOWA_SAVE[CUR_EDIT].usebeginsound)
		getglobal("MPowa_ConfigFrame_Container_3_Checkbutton_EndSound"):SetChecked(MPOWA_SAVE[CUR_EDIT].useendsound)
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
		local button = getglobal("TextureFrame"..i)
		button.bi = nil
		button.count = 0
		if button:IsVisible() then
			button.removed = GetTime()
		else
			button.removed = 0
		end
		if (not MPOWA_SAVE[i].test) then
			button:Hide()
		end
		if button.timeLeft ~= nil then
			if (button.timeLeft < 0.5) and MPOWA_SAVE[button:GetID()].useendsound then
				if MPOWA_SAVE[button:GetID()].endsound < 16 then
					PlaySound(SOUND[MPOWA_SAVE[button:GetID()].endsound], "master")
				else
					PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..SOUND[MPOWA_SAVE[button:GetID()].endsound], "master")
				end
			end
			button.timeLeft = nil
		end
	end
end

function MPowa_SearchAuras()
	-- Setting Conditions
	MPowa_IsMounted()
	MPowa_IsInBattleground()
	
	-- To enable to show cooldowns
	for p=1, CUR_MAX do
		if MPOWA_SAVE[p].cooldown or MPOWA_SAVE[p].inverse then
			if MPOWA_SAVE[p].test or TEST_ALL then MPOWA_SAVE[p].test = false TEST_ALL = false end
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
					if MPOWA_SAVE[p].test or TEST_ALL then MPOWA_SAVE[p].test = false TEST_ALL = false end
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
					if MPOWA_SAVE[p].test or TEST_ALL then MPOWA_SAVE[p].test = false TEST_ALL = false end
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
				
				if (button.removed+0.5 < GetTime()) and MPOWA_SAVE[button:GetID()].usebeginsound then
					if MPOWA_SAVE[button:GetID()].beginsound < 16 then
						PlaySound(SOUND[MPOWA_SAVE[button:GetID()].beginsound], "master")
					else
						PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..SOUND[MPOWA_SAVE[button:GetID()].beginsound], "master")
					end
				end
				
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
	local Duration = getglobal(button:GetName().."_Timer")
	if MPOWA_SAVE[button:GetID()].timer then
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
						Duration:Show()
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
				Duration:Show()
				if MPOWA_SAVE[button:GetID()].hundredth and timeLeft > 0 then
					Duration:SetText(string.format("%.2f", timeLeft))
				elseif (not MPOWA_SAVE[button:GetID()].hundredth) and timeLeft > 0 then
					Duration:SetText(string.format("%.0f", timeLeft))
				end
				if timeLeft == 0 and (not MPOWA_SAVE[button:GetID()].enemytarget) and (not MPOWA_SAVE[button:GetID()].friendlytarget) then Duration:SetText("") end
				button.timeLeft = timeLeft
			end	
		else
			Duration:Show()
			if MPOWA_SAVE[button:GetID()].hundredth then
				Duration:SetText(string.format("%.2f", (random(1,23)+random(1,60)/100)))
			else
				Duration:SetText(string.format("%.0f", (random(1,23)+random(1,60)/100)))
			end
		end
	else
		Duration:Hide()
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
	local duration = getglobal("TextureFrame"..i.."_Timer")
	frame:SetAlpha(MPOWA_SAVE[i].alpha)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", MPOWA_SAVE[i].x, MPOWA_SAVE[i].y)
	frame:SetScale(MPOWA_SAVE[i].size)
	duration:SetFont("Fonts\\FRIZQT__.ttf", MPOWA_SAVE[i].fontsize*12, "OUTLINE")
	duration:SetAlpha(MPOWA_SAVE[i].fontalpha)
	duration:ClearAllPoints()
	duration:SetPoint("CENTER", frame, "CENTER", MPOWA_SAVE[i].fontoffsetx, MPOWA_SAVE[i].fontoffsety)
	if MPOWA_SAVE[i].usefontcolor then
		duration:SetTextColor(MPOWA_SAVE[i].fontcolor_r,MPOWA_SAVE[i].fontcolor_g,MPOWA_SAVE[i].fontcolor_b,MPOWA_SAVE[i].fontalpha)
	end
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
	getglobal("TextureFrame"..CUR_EDIT):Hide()
	getglobal("TextureFrame"..CUR_EDIT):Show()
end

function MPowa_Editbox_Duration(obj)
	MPOWA_SAVE[CUR_EDIT].targetduration = tonumber(obj:GetText())
	MPowa_Update()
end

function MPowa_TernarySetState(button, value)
	local label = getglobal(button:GetName().."Text")
	button:Enable()
	label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

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
		MPOWA_SAVE[CUR_EDIT][var] = true -- Ignore => On
	elseif (MPOWA_SAVE[CUR_EDIT][var]==true) then
		MPOWA_SAVE[CUR_EDIT][var] = false -- On => Off
	else
		MPOWA_SAVE[CUR_EDIT][var] = 0 -- Off => Ignore
	end	

	MPowa_TernarySetState(obj, MPOWA_SAVE[CUR_EDIT][var])
	getglobal("TextureFrame"..CUR_EDIT):Hide()
	getglobal("TextureFrame"..CUR_EDIT):Show()
end

function MPowa_OptionsFrame_SetColor()
	local r,g,b = ColorPickerFrame:GetColorRGB()
	local swatch,frame
	swatch = getglobal("MPowa_ConfigFrame_Container_2_2_ColorpickerNormalTexture") -- juste le visuel
	frame = getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg")      -- enregistre la couleur
	swatch:SetVertexColor(r,g,b)
	frame.r = r
	frame.g = g
	frame.b = b

	MPOWA_SAVE[CUR_EDIT].fontcolor_r = r
	MPOWA_SAVE[CUR_EDIT].fontcolor_g = g
	MPOWA_SAVE[CUR_EDIT].fontcolor_b = b
	
	if MPOWA_SAVE[CUR_EDIT].usefontcolor then
		getglobal("TextureFrame"..CUR_EDIT.."_Timer"):SetTextColor(r,g,b,MPOWA_SAVE[CUR_EDIT].fontalpha)
	else
		getglobal("TextureFrame"..CUR_EDIT.."_Timer"):SetTextColor(1,1,1,MPOWA_SAVE[CUR_EDIT].fontalpha)
	end
end

function MPowa_OptionsFrame_CancelColor()
	local r = ColorPickerFrame.previousValues.r
	local g = ColorPickerFrame.previousValues.g
	local b = ColorPickerFrame.previousValues.b
	local swatch,frame
	swatch = getglobal("MPowa_ConfigFrame_Container_2_2_ColorpickerNormalTexture") -- juste le visuel
	frame = getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg")      -- enregistre la couleur
	swatch:SetVertexColor(r,g,b)
	frame.r = r
	frame.g = g
	frame.b = b
	
	if MPOWA_SAVE[CUR_EDIT].usefontcolor then
		getglobal("TextureFrame"..CUR_EDIT.."_Timer"):SetTextColor(r,g,b,MPOWA_SAVE[CUR_EDIT].fontalpha)
	else
		getglobal("TextureFrame"..CUR_EDIT.."_Timer"):SetTextColor(1,1,1,MPOWA_SAVE[CUR_EDIT].fontalpha)
	end
end

function MPowa_OpenColorPicker()
	CloseMenus()
	
	button = getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg")

	ColorPickerFrame.func = MPowa_OptionsFrame_SetColor -- button.swatchFunc
	ColorPickerFrame:SetColorRGB(button.r, button.g, button.b)
	ColorPickerFrame.previousValues = {r = button.r, g = button.g, b = button.b, opacity = button.opacity}
	ColorPickerFrame.cancelFunc = MPowa_OptionsFrame_CancelColor

	ColorPickerFrame:SetPoint("TOPLEFT", MPowa_ConfigFrame_Container_2_2_Colorpicker, "TOPRIGHT", 0, 0)

	ColorPickerFrame:Show()
end

function MPowa_Checkbutton_USEFONTCOLOR()
	if MPOWA_SAVE[CUR_EDIT].usefontcolor then
		MPOWA_SAVE[CUR_EDIT].usefontcolor = false
		getglobal("TextureFrame"..CUR_EDIT.."_Timer"):SetTextColor(1,1,1,MPOWA_SAVE[CUR_EDIT].usefontcolor)
	else
		MPOWA_SAVE[CUR_EDIT].usefontcolor = true
		getglobal("TextureFrame"..CUR_EDIT.."_Timer"):SetTextColor(MPOWA_SAVE[CUR_EDIT].fontcolor_r,MPOWA_SAVE[CUR_EDIT].fontcolor_g,MPOWA_SAVE[CUR_EDIT].fontcolor_b,MPOWA_SAVE[CUR_EDIT].usefontcolor)
	end
end

function MPowa_SoundSliderChange(obj, var)
	local oldvar = MPOWA_SAVE[CUR_EDIT][var]
	MPOWA_SAVE[CUR_EDIT][var] = obj:GetValue()
	getglobal(obj:GetName().."Text"):SetText(MPOWA_SLIDER_BEGINSOUND..SOUND[MPOWA_SAVE[CUR_EDIT][var]])
	if MPOWA_SAVE[CUR_EDIT][var] ~= oldvar then
		if MPOWA_SAVE[CUR_EDIT][var] < 16 then
			PlaySound(SOUND[MPOWA_SAVE[CUR_EDIT][var]], "master")
		else
			PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..SOUND[MPOWA_SAVE[CUR_EDIT][var]], "master")
		end
	end
end

function MPowa_ProfileSave()
	table.insert(MPOWA_PROFILE, MPOWA_SAVE[SELECTED])
	MPowa_ScrollFrame_Update()
end

function MPowa_ProfileRemove()
	if MPOWA_PROFILE[MPOWA_PROFILE_SELECTED] ~= nil then
		table.remove(MPOWA_PROFILE, MPOWA_PROFILE_SELECTED)
		MPOWA_PROFILE_SELECTED = 1
		MPowa_ScrollFrame_Update()
	end
end

function MPowa_Import()
	if MPOWA_PROFILE[MPOWA_PROFILE_SELECTED] ~= nil then
		table.remove(MPOWA_SAVE, CUR_MAX+1)
		table.insert(MPOWA_SAVE, CUR_MAX+1, MPOWA_PROFILE[MPOWA_PROFILE_SELECTED])
		MPowa_AddAura()
	end
end

function MPowa_GetTableLength(T)
	local count = 0
	for _ in pairs(T) do 
		count = count + 1 
	end 
	return count
end

function MPowa_ScrollFrame_Update()
	local line -- 1 through 5 of our window to scroll
	local lineplusoffset -- an index into our data calculated from the scroll offset
	local FRAME = MPowa_ProfileFrame_ScrollFrame
	FauxScrollFrame_Update(FRAME,MPowa_GetTableLength(MPOWA_PROFILE),7,40)
	for line=1,7 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(FRAME)
		if MPOWA_PROFILE[lineplusoffset] ~= nil then
			getglobal("MPowa_ProfileFrame_ScrollFrame_Button"..line.."_Name"):SetText(MPOWA_PROFILE[lineplusoffset].buffname)
			getglobal("MPowa_ProfileFrame_ScrollFrame_Button"..line.."_Icon"):SetTexture(MPOWA_PROFILE[lineplusoffset].texture)
			getglobal("MPowa_ProfileFrame_ScrollFrame_Button"..line).line = lineplusoffset
			getglobal("MPowa_ProfileFrame_ScrollFrame_Button"..line):Show()
		else
			getglobal("MPowa_ProfileFrame_ScrollFrame_Button"..line):Hide()
		end
	end
end