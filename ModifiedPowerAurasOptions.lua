-- Global Variables
MPOWA_CUR_MAX = 1
MPOWA_TEST_ALL = false
MPOWA_LOADED = false
MPOWA_PROFILE_SELECTED = 1
MPOWA_SOUND = {}
MPOWA_SOUND = {
	[0] = "None",
	[1] = "LEVELUP",
	[2] = "LOOTWINDOWCOINMPOWA_SOUND",
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
}

-- Local Variables
local MAX_AURAS = 49
local INITIALIZED = false
local SELECTED = 1
local CUR_EDIT = 1
local SELECTEDICON = "Interface\\ICONS\\Ability_Warrior_BattleShout"
local ICONARRAY = {}
ICONARRAY["MPowa_IconFrame_ButtonContainer_Button"] = 21
ICONARRAY["MPowa_IconFrame_ButtonContainer_2_Button"] = 20
ICONARRAY["MPowa_IconFrame_ButtonContainer_3_Button"] = 24
ICONARRAY["MPowa_IconFrame_ButtonContainer_4_Button"] = 21
ICONARRAY["MPowa_IconFrame_ButtonContainer_5_Button"] = 35
ICONARRAY["MPowa_IconFrame_ButtonContainer_6_Button"] = 36
ICONARRAY["MPowa_IconFrame_ButtonContainer_7_Button"] = 30
ICONARRAY["MPowa_IconFrame_ButtonContainer_8_Button"] = 35
ICONARRAY["MPowa_IconFrame_ButtonContainer_9_Button"] = 27
ICONARRAY["MPowa_IconFrame_ButtonContainer_10_Button"] = 39

-- Functions

function MPowa_OnLoad()
	SLASH_MPOWA1 = "/mpowa"
	SlashCmdList["MPOWA"] = function(msg)
		if MPowa_MainFrame:IsVisible() then
			MPowa_MainFrame:Hide()
		else
			MPowa_Show()
		end
	end
end

function MPowa_Options_OnEvent(event)
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
		
		MPOWA_CUR_MAX = MPowa_getNumUsed()
		
		for i=1, MPOWA_CUR_MAX  do
			if MPOWA_SAVE[i].raidgroupmember == nil then MPOWA_SAVE[i].raidgroupmember = false end
			if MPOWA_SAVE[i].exactname == nil then MPOWA_SAVE[i].exactname = false end
			MPowa_CreateIcons(i)
		end
		
		MPOWA_LOADED = true
	end
end

function MPowa_Show()
	if MPOWA_LOADED and (not INITIALIZED) then
		for i=1, MPOWA_CUR_MAX  do
			MPowa_CreateButton(i)
		end
		INITIALIZED = true
	end
	for i=1, MPOWA_CUR_MAX  do
		MPowa_ApplyAttributesToButton(i, getglobal("ConfigButton"..i))
	end
	if MPOWA_CUR_MAX > 0 then
		getglobal("ConfigButton"..SELECTED.."_Border"):Show()
	end
	MPowa_MainFrame:Show()
end

function MPowa_CreateSave(i)
	MPOWA_SAVE[i] = {
		texture = "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga",
		alpha = 1,
		size = 0.75,
		x = 0,
		y = -30,
		buffname = "",
		isdebuff = false,
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
		raidgroupmember = false,
		exactname = false,
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
	if MPOWA_CUR_MAX  < 49 then
		MPOWA_CUR_MAX = MPOWA_CUR_MAX + 1
		if getglobal("ConfigButton"..MPOWA_CUR_MAX) ~= nil then
			MPowa_ApplyAttributesToButton(MPOWA_CUR_MAX,getglobal("ConfigButton"..MPOWA_CUR_MAX))
			MPowa_ApplyConfig(MPOWA_CUR_MAX)
		else
			MPowa_CreateButton(MPOWA_CUR_MAX)
			MPowa_CreateIcons(MPOWA_CUR_MAX)
		end
		MPOWA_SAVE[MPOWA_CUR_MAX].used = true
		MPowa_DeselectAll()
		getglobal("ConfigButton"..MPOWA_CUR_MAX.."_Border"):Show()
		SELECTED = MPOWA_CUR_MAX
	end
end

function MPowa_DeselectAll()
	for i=1, MPOWA_CUR_MAX  do
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
		MPOWA_CUR_MAX = MPOWA_CUR_MAX - 1
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
	for i=1, MPOWA_CUR_MAX +1 do
		getglobal("ConfigButton"..i):Hide()
	end
	for i=1, MPOWA_CUR_MAX  do
		MPowa_ApplyAttributesToButton(i,getglobal("ConfigButton"..i))
	end
end

function MPowa_TestAll()
	if ConfigButton1 then
		if MPOWA_TEST_ALL then
			MPOWA_TEST_ALL = false
			for i=1, MPOWA_CUR_MAX  do
				if getglobal("TextureFrame"..i).bi == nil then
					getglobal("TextureFrame"..i):Hide()
				end
			end
		else
			MPOWA_TEST_ALL = true
			for i=1, MPOWA_CUR_MAX  do
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
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ExactName"):SetChecked(MPOWA_SAVE[CUR_EDIT].exactname)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowIfNotActive"):SetChecked(MPOWA_SAVE[CUR_EDIT].inverse)
		getglobal("MPowa_ConfigFrame_Container_2_2_Checkbutton_Timer"):SetChecked(MPOWA_SAVE[CUR_EDIT].timer)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowCooldowns"):SetChecked(MPOWA_SAVE[CUR_EDIT].cooldown)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_EnemyTarget"):SetChecked(MPOWA_SAVE[CUR_EDIT].enemytarget)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_FriendlyTarget"):SetChecked(MPOWA_SAVE[CUR_EDIT].friendlytarget)
		getglobal("MPowa_ConfigFrame_Container_1_2_Checkbutton_RaidMember"):SetChecked(MPOWA_SAVE[CUR_EDIT].raidgroupmember)
		getglobal("MPowa_ConfigFrame_Container_2_2_Checkbutton_Hundreds"):SetChecked(MPOWA_SAVE[CUR_EDIT].hundredth)
		getglobal("MPowa_ConfigFrame_Container_2_2_Checkbutton_Color"):SetChecked(MPOWA_SAVE[CUR_EDIT].usefontcolor)
		getglobal("MPowa_ConfigFrame_Container_2_2_ColorpickerNormalTexture"):SetVertexColor(MPOWA_SAVE[CUR_EDIT].fontcolor_r, MPOWA_SAVE[CUR_EDIT].fontcolor_g, MPOWA_SAVE[CUR_EDIT].fontcolor_b)
		getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg").r = MPOWA_SAVE[CUR_EDIT].fontcolor_r
		getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg").g = MPOWA_SAVE[CUR_EDIT].fontcolor_g
		getglobal("MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg").b = MPOWA_SAVE[CUR_EDIT].fontcolor_b
		getglobal("MPowa_ConfigFrame_Container_3_Slider_BeginSound"):SetValue(MPOWA_SAVE[CUR_EDIT].beginsound)
		getglobal("MPowa_ConfigFrame_Container_3_Slider_BeginSoundText"):SetText(MPOWA_SLIDER_BEGINSOUND..MPOWA_SOUND[MPOWA_SAVE[CUR_EDIT].beginsound])
		getglobal("MPowa_ConfigFrame_Container_3_Slider_EndSound"):SetValue(MPOWA_SAVE[CUR_EDIT].endsound)
		getglobal("MPowa_ConfigFrame_Container_3_Slider_EndSoundText"):SetText(MPOWA_SLIDER_BEGINSOUND..MPOWA_SOUND[MPOWA_SAVE[CUR_EDIT].endsound])
		getglobal("MPowa_ConfigFrame_Container_3_Checkbutton_BeginSound"):SetChecked(MPOWA_SAVE[CUR_EDIT].usebeginsound)
		getglobal("MPowa_ConfigFrame_Container_3_Checkbutton_EndSound"):SetChecked(MPOWA_SAVE[CUR_EDIT].useendsound)
		if MPOWA_SAVE[CUR_EDIT].enemytarget or MPOWA_SAVE[CUR_EDIT].friendlytarget then
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
		getglobal("TextureFrame"..CUR_EDIT.."_Icon"):SetTexture(MPOWA_SAVE[CUR_EDIT].texture)
	end
	
	if MPOWA_SAVE[CUR_EDIT].test or MPOWA_TEST_ALL then
		getglobal("TextureFrame"..CUR_EDIT):Hide()
		getglobal("TextureFrame"..CUR_EDIT):Show()
	else
		MPowa_Update()
		MPowa_Target()
		MPowa_RaidGroupMember()
	end
end

function MPowa_Editbox_Stacks(obj)
	local oldcon = MPOWA_SAVE[CUR_EDIT].stacks
	MPOWA_SAVE[CUR_EDIT].stacks = obj:GetText()
	if oldcon ~= MPOWA_SAVE[CUR_EDIT].stacks then
		MPowa_Target()
		MPowa_Update()
	end
end

function MPowa_Checkbutton(var)
	if MPOWA_SAVE[CUR_EDIT][var] then
		MPOWA_SAVE[CUR_EDIT][var] = false
	else
		MPOWA_SAVE[CUR_EDIT][var] = true
	end
	
	if MPOWA_SAVE[CUR_EDIT].test or MPOWA_TEST_ALL then
		getglobal("TextureFrame"..CUR_EDIT):Hide()
		getglobal("TextureFrame"..CUR_EDIT):Show()
	else
		MPowa_Update()
		MPowa_Target()
	end
end

function MPowa_Editbox_Duration(obj)
	if tonumber(obj:GetText()) ~= nil then
		MPOWA_SAVE[CUR_EDIT].targetduration = tonumber(obj:GetText())
		MPowa_Target()
	end
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
	if MPOWA_SAVE[CUR_EDIT].test or MPOWA_TEST_ALL then
		getglobal("TextureFrame"..CUR_EDIT):Hide()
		getglobal("TextureFrame"..CUR_EDIT):Show()
	else
		MPowa_Update()
		MPowa_Target()
	end
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
	
	ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	
	ColorPickerFrame:SetMovable()
	ColorPickerFrame:EnableMouse()
	ColorPickerFrame:SetScript("OnMouseDown", function() ColorPickerFrame:StartMoving() end)
	ColorPickerFrame:SetScript("OnMouseUp", function() ColorPickerFrame:StopMovingOrSizing() end)
	
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
	getglobal(obj:GetName().."Text"):SetText(MPOWA_SLIDER_BEGINSOUND..MPOWA_SOUND[MPOWA_SAVE[CUR_EDIT][var]])
	if MPOWA_SAVE[CUR_EDIT][var] ~= oldvar then
		if MPOWA_SAVE[CUR_EDIT][var] < 16 then
			PlaySound(MPOWA_SOUND[MPOWA_SAVE[CUR_EDIT][var]], "master")
		else
			PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..MPOWA_SOUND[MPOWA_SAVE[CUR_EDIT][var]], "master")
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
		table.remove(MPOWA_SAVE, MPOWA_CUR_MAX +1)
		table.insert(MPOWA_SAVE, MPOWA_CUR_MAX +1, MPOWA_PROFILE[MPOWA_PROFILE_SELECTED])
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

function MPowa_SelectIcon(obj)
	SELECTEDICON = getglobal(obj:GetName().."_Icon"):GetTexture()
	for cat, p in pairs(ICONARRAY) do
		for i=1,p do
			getglobal(cat..i.."_Border"):Hide()
		end
	end
	getglobal(obj:GetName().."_Border"):Show()
end

function MPowa_IconFrameOkay()
	getglobal("MPowa_ConfigFrame_Container_1_Icon_Texture"):SetTexture(SELECTEDICON)
	getglobal("ConfigButton"..CUR_EDIT.."_Icon"):SetTexture(SELECTEDICON)
	getglobal("TextureFrame"..CUR_EDIT.."_Icon"):SetTexture(SELECTEDICON)
	MPOWA_SAVE[CUR_EDIT].texture = SELECTEDICON
	getglobal("MPowa_IconFrame"):Hide()
end