-- Local Variables
local ISMOUNTED = false
local INBATTLEGROUND = false
local UPDATETIME = 0.1
local TIME_SINCE_LAST_UPDATE = 0

-- Functions
function MPowa_OnEvent(event)
	if event == "UNIT_AURA" then
		if arg1 == "target" then
			MPowa_Target()
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		MPowa_Target()
	else
		MPowa_Update()
	end
end

function MPowa_Update()
	MPowa_HideAllIcons()
	MPowa_SearchAuras()
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
		if strfind(desc, MPOWA_SCRIPT_MOUNT_100) or strfind(desc, MPOWA_SCRIPT_MOUNT_60) then
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

function MPowa_Target()
	-- Hiding Icons for enemy debuffs
	for i=1, MPOWA_CUR_MAX do
		if MPOWA_SAVE[i].enemytarget or MPOWA_SAVE[i].friendlytarget then
			local button = getglobal("TextureFrame"..i)
			button:Hide()
			button.count = 0
		end
	end
	
	-- Find enemy buffs
	local i = 1
	while true do 
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearLines()
		GameTooltip:SetUnitBuff("target", i)
		local buff = GameTooltipTextLeft1:GetText()
		if buff then
			for p=1, MPOWA_CUR_MAX do
				if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(buff)) and (not MPOWA_SAVE[p].isdebuff) then
					if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false; MPOWA_TEST_ALL = false end
					getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
					MPowa_TextureFrame_Update(i-1, getglobal("TextureFrame"..p))
					if MPOWA_SAVE[p].inverse then
						getglobal("TextureFrame"..p):Hide()
					end
					break
				end
			end
		end
		
		GameTooltip:ClearLines()
		GameTooltip:SetUnitDebuff("target", i)
		local debuff = GameTooltipTextLeft1:GetText()
		if (debuff) then
			for p=1, MPOWA_CUR_MAX do
				if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(debuff)) and MPOWA_SAVE[p].isdebuff then
					if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false; MPOWA_TEST_ALL = false end
					getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
					MPowa_TextureFrame_Update(i-1, getglobal("TextureFrame"..p))
					if MPOWA_SAVE[p].inverse then
						getglobal("TextureFrame"..p):Hide()
					end
					break
				end
			end
		end
		
		GameTooltip:Hide()
		if (not buff) and (not debuff) then break end
		i = i + 1
	end
end

function MPowa_HideAllIcons()
	for i=1, MPOWA_CUR_MAX do
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
					PlaySound(MPOWA_SOUND[MPOWA_SAVE[button:GetID()].endsound], "master")
				else
					PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..MPOWA_SOUND[MPOWA_SAVE[button:GetID()].endsound], "master")
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
	for p=1, MPOWA_CUR_MAX do
		if MPOWA_SAVE[p].cooldown or MPOWA_SAVE[p].inverse then
			if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false MPOWA_TEST_ALL = false end
				MPowa_TextureFrame_Update(99, getglobal("TextureFrame"..p))
		end
	end
	
	-- Rest
	local i = 0
	while true do
		-- HELPFUL
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearLines()
		GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local buff = GameTooltipTextLeft1:GetText()
		if buff then
			for p=1, MPOWA_CUR_MAX do
				if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(buff)) and (not MPOWA_SAVE[p].isdebuff) then
					if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false MPOWA_TEST_ALL = false end
					getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
					MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
					if MPOWA_SAVE[p].inverse then
						getglobal("TextureFrame"..p):Hide()
					end
					break
				end
			end
		end
		
		-- HARMFUL
		GameTooltip:ClearLines()
		GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HARMFUL"))
		local debuff = GameTooltipTextLeft1:GetText()
		if debuff then
			for p=1, MPOWA_CUR_MAX do
				if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(debuff)) and MPOWA_SAVE[p].isdebuff then
					if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false MPOWA_TEST_ALL = false end
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
					for i=1, MPOWA_CUR_MAX do
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
						PlaySound(MPOWA_SOUND[MPOWA_SAVE[button:GetID()].beginsound], "master")
					else
						PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..MPOWA_SOUND[MPOWA_SAVE[button:GetID()].beginsound], "master")
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
	TIME_SINCE_LAST_UPDATE = TIME_SINCE_LAST_UPDATE + elapsed
	if TIME_SINCE_LAST_UPDATE >= UPDATETIME then
		local Duration = getglobal(button:GetName().."_Timer")
		if MPOWA_SAVE[button:GetID()].timer then
			if (not MPOWA_SAVE[button:GetID()].test and (not MPOWA_TEST_ALL)) then
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
		TIME_SINCE_LAST_UPDATE = 0
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