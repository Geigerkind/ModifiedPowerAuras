-- Local Variables
local ISMOUNTED = false
local INBATTLEGROUND = false
local UPDATETIME = 0.1
local TIME_SINCE_LAST_UPDATE = 0
local MPowa_BuffFrameUpdateTime = 0
local MPowa_BuffFrameFlashTime = 0
local MPowa_BuffFrameFlashState = 0
local MPowa_BUFF_ALPHA_VALUE = 0

-- Functions
function MPowa_OnEvent(event)
	if event == "UNIT_AURA" then
		if arg1 == "target" then
			MPowa_Target()
		end
		if strfind(arg1, "raid") or strfind(arg1, "party") then
			MPowa_RaidGroupMemberSingle(arg1)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		MPowa_Target()
	elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
		MPowa_RaidGroupMember()
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
	for i=0,31 do
		GameTooltip:ClearLines()
		GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local desc = GameTooltipTextLeft2:GetText()
		if (not desc) then break end
		if strfind(desc, MPOWA_SCRIPT_MOUNT_100) or strfind(desc, MPOWA_SCRIPT_MOUNT_60) then
			ISMOUNTED = true
		end
	end
end

function MPowa_IsInParty()
	if GetNumPartyMembers() > 0 or UnitInRaid("player") then
		return true
	else
		return false
	end
end

function MPowa_IsInBattleground()
	INBATTLEGROUND = false
	for i=1, 4 do
		local status, mapName, instanceID, lowestlevel, highestlevel, teamSize, registeredMatch = GetBattlefieldStatus(i)
		if status == "active" then
			INBATTLEGROUND = true
		end
	end
end

function MPowa_FilterName(name, p)
	if MPOWA_SAVE[p].exactname then
		if MPOWA_SAVE[p].raidgroupmember then
			if MPowa_GetBuffName(MPOWA_SAVE[p].buffname) == name then
				return true
			else
				return false
			end
		else
			if MPOWA_SAVE[p].buffname == name then
				return true
			else
				return false
			end
		end
	else
		if MPOWA_SAVE[p].raidgroupmember then
			if strfind(MPowa_GetBuffName(strlower(MPOWA_SAVE[p].buffname)), strlower(name)) then
				return true
			else
				return false
			end
		else
			if strfind(strlower(MPOWA_SAVE[p].buffname), strlower(name)) then
				return true
			else
				return false
			end
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
	for i=1, 32 do
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearLines()
		GameTooltip:SetUnitBuff("target", i)
		local buff = GameTooltipTextLeft1:GetText()
		if buff then
			for p=1, MPOWA_CUR_MAX do
				if MPowa_FilterName(buff, p) and (not MPOWA_SAVE[p].isdebuff) and (MPOWA_SAVE[p].enemytarget or MPOWA_SAVE[p].friendlytarget) then
					if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false; MPOWA_TEST_ALL = false end
					getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
					MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
					if MPOWA_SAVE[p].inverse then
						getglobal("TextureFrame"..p):Hide()
					end
					break
				end
			end
		end
		
		if i <= 16 then
			GameTooltip:ClearLines()
			GameTooltip:SetUnitDebuff("target", i)
			local debuff = GameTooltipTextLeft1:GetText()
			if debuff then
				for p=1, MPOWA_CUR_MAX do
					if MPowa_FilterName(debuff, p) and MPOWA_SAVE[p].isdebuff and (MPOWA_SAVE[p].enemytarget or MPOWA_SAVE[p].friendlytarget) then
						if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false; MPOWA_TEST_ALL = false end
						getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
						MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
						if MPOWA_SAVE[p].inverse then
							getglobal("TextureFrame"..p):Hide()
						end
						break
					end
				end
			end
		end
		
		GameTooltip:Hide()
		if (not buff) and (not debuff) then break end
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
		if (not MPOWA_SAVE[i].test) and (not MPOWA_SAVE[i].raidgroupmember) then
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
	for i=0, 31 do
		-- HELPFUL
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearLines()
		GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local buff = GameTooltipTextLeft1:GetText()
		if buff then
			for p=1, MPOWA_CUR_MAX do
				if MPowa_FilterName(buff, p) and (not MPOWA_SAVE[p].isdebuff) and (not MPOWA_SAVE[p].raidgroupmember) then
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
		
		if i <= 16 then
			-- HARMFUL
			GameTooltip:ClearLines()
			GameTooltip:SetPlayerBuff(GetPlayerBuff(i, "HARMFUL"))
			local debuff = GameTooltipTextLeft1:GetText()
			if debuff then
				for p=1, MPOWA_CUR_MAX do
					if MPowa_FilterName(debuff, p) and MPOWA_SAVE[p].isdebuff and (not MPOWA_SAVE[p].raidgroupmember) then
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
		end
		
		GameTooltip:Hide()
		if (buff == nil) and (debuff == nil) then break end
	end
	
end

function MPowa_GetUnitName(name)
	if strfind (name, ")") then
		return strsub(name, 2, strfind(name, ")")-1)
	else
		return ""
	end
end

function MPowa_GetBuffName(name)
	if strfind (name, ")") then
		return strsub(name, (strfind(name, ")")+1) or 1)
	else
		return ""
	end
end

function MPowa_RaidGroupMemberSingle(arg1)
	for u=1, MPOWA_CUR_MAX do
		if MPOWA_SAVE[u].raidgroupmember and UnitName(arg1) == MPowa_GetUnitName(MPOWA_SAVE[u].buffname) then
			local button = getglobal("TextureFrame"..u)
			button.count = 0
			button:Hide()
			
			GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			for t=1, 32 do
				GameTooltip:ClearLines()
				if MPOWA_SAVE[u].isdebuff then
					if t > 17 then break end
					GameTooltip:SetUnitDebuff(arg1, t)
				else
					GameTooltip:SetUnitBuff(arg1, t)
				end
				local tauraname = GameTooltipTextLeft1:GetText()
				if (not tauraname) then break end
				if MPowa_FilterName(tauraname, u) then
					button.rgcon = arg1
					button.count = button.count + 1
					MPowa_TextureFrame_Update(t, button)
					if MPOWA_SAVE[u].inverse then
						button:Hide()
					end
					break
				end
			end
			GameTooltip:Hide()
		end
	end
end

function MPowa_RaidGroupMember()
	for u=1,MPOWA_CUR_MAX do
		if MPOWA_SAVE[u].raidgroupmember then
			local button = getglobal("TextureFrame"..u)
			button.count = 0
			button:Hide()
			if UnitInRaid("player") then
				for z=1, 40 do
					if UnitName("raid"..z) == MPowa_GetUnitName(MPOWA_SAVE[u].buffname) then
						GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
						for t=1, 32 do
							GameTooltip:ClearLines()
							if MPOWA_SAVE[u].isdebuff then
								if t > 16 then break end
								GameTooltip:SetUnitDebuff("raid"..z, t)
							else
								GameTooltip:SetUnitBuff("raid"..z, t)
							end
							local tauraname = GameTooltipTextLeft1:GetText()
							if (not tauraname) then break end
							if MPowa_FilterName(tauraname, u) then
								button.rgcon = "raid"..z
								button.count = button.count + 1
								MPowa_TextureFrame_Update(t, button)
								if MPOWA_SAVE[u].inverse then
									button:Hide()
								end
								break
							end
						end
					end
				end
			elseif UnitInParty("player") then
				for z=1, 4 do
					if UnitName("party"..z) == MPowa_GetUnitName(MPOWA_SAVE[u].buffname) then
						GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
						for t=1, 32 do
							GameTooltip:ClearLines()
							if MPOWA_SAVE[u].isdebuff then
								if t > 16 then break end
								GameTooltip:SetUnitDebuff("party"..z, t)
							else
								GameTooltip:SetUnitBuff("party"..z, t)
							end
							local tauraname = GameTooltipTextLeft1:GetText()
							if (not tauraname) then break end
							if MPowa_FilterName(tauraname, u) then
								button.rgcon = "party"..z
								button.count = button.count + 1
								MPowa_TextureFrame_Update(t, button)
								if MPOWA_SAVE[u].inverse then
									button:Hide()
								end
								break
							end
						end
					end
				end
			end
		end
		GameTooltip:Hide()
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
		local buffIndex
		if MPOWA_SAVE[button:GetID()].isdebuff then
			if ((MPOWA_SAVE[button:GetID()].enemytarget and UnitCanAttack("player", "target")) or (MPOWA_SAVE[button:GetID()].friendlytarget and (not UnitCanAttack("player", "target")))) or MPOWA_SAVE[button:GetID()].raidgroupmember then
				buffIndex = 0
			else
				buffIndex = GetPlayerBuff(bi, "HARMFUL")
			end
		else
			if ((MPOWA_SAVE[button:GetID()].enemytarget and UnitCanAttack("player", "target")) or (MPOWA_SAVE[button:GetID()].friendlytarget and (not UnitCanAttack("player", "target")))) or MPOWA_SAVE[button:GetID()].raidgroupmember then
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
						a, b, c = UnitDebuff("target", bi)
					else
						a, b = UnitBuff("target", bi)
					end
					texture = a
				else
					if MPOWA_SAVE[button:GetID()].raidgroupmember then
						if MPOWA_SAVE[button:GetID()].isdebuff then
							a, b, c = UnitDebuff(button.rgcon, bi)
						else
							a, b = UnitBuff(button.rgcon, bi)
						end
						texture = a
					else
						texture = GetPlayerBuffTexture(buffIndex)
					end
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
	local buffIndex = 0
	local timeLeft = 0
	if MPOWA_SAVE[button:GetID()].flashanim then
		if ( MPowa_BuffFrameUpdateTime > 0 ) then
			MPowa_BuffFrameUpdateTime = MPowa_BuffFrameUpdateTime - elapsed;
		else
			MPowa_BuffFrameUpdateTime = MPowa_BuffFrameUpdateTime + TOOLTIP_UPDATE_TIME;
		end
	 
		MPowa_BuffFrameFlashTime = MPowa_BuffFrameFlashTime - elapsed;
		if ( MPowa_BuffFrameFlashTime < 0 ) then
			local overtime = -BuffFrameFlashTime;
			if ( MPowa_BuffFrameFlashState == 0 ) then
				MPowa_BuffFrameFlashState = 1;
				MPowa_BuffFrameFlashTime = BUFF_FLASH_TIME_ON;
			else
				MPowa_BuffFrameFlashState = 0;
				MPowa_BuffFrameFlashTime = BUFF_FLASH_TIME_OFF;
			end
			if ( overtime < MPowa_BuffFrameFlashTime ) then
				MPowa_BuffFrameFlashTime = MPowa_BuffFrameFlashTime - overtime;
			end
		end
		if ( MPowa_BuffFrameFlashState == 1 ) then
			MPowa_BUFF_ALPHA_VALUE = (BUFF_FLASH_TIME_ON - MPowa_BuffFrameFlashTime) / BUFF_FLASH_TIME_ON;
		else
			MPowa_BUFF_ALPHA_VALUE = MPowa_BuffFrameFlashTime / BUFF_FLASH_TIME_ON;
		end
		MPowa_BUFF_ALPHA_VALUE = (MPowa_BUFF_ALPHA_VALUE * (1 - BUFF_MIN_ALPHA)) + BUFF_MIN_ALPHA;
		
		if MPOWA_SAVE[button:GetID()].cooldown then
			if (button.cdtime) then
				timeLeft = button.cdtime
			end
		else
			if MPOWA_SAVE[button:GetID()].isdebuff then
				buffIndex = GetPlayerBuff(button.bi, "HARMFUL")
			else
				buffIndex = GetPlayerBuff(button.bi, "HELPFUL")
			end
			timeLeft = GetPlayerBuffTimeLeft(buffIndex)
		end
		if (not timeLeft) then timeLeft = 0 end
		if timeLeft < MPOWA_SAVE[button:GetID()].flashanimstart then
			button:SetAlpha(MPowa_BUFF_ALPHA_VALUE);
		else
			button:SetAlpha(MPOWA_SAVE[button:GetID()].alpha)
		end
	else
		button:SetAlpha(MPOWA_SAVE[button:GetID()].alpha)
	end

	TIME_SINCE_LAST_UPDATE = TIME_SINCE_LAST_UPDATE + elapsed
	if TIME_SINCE_LAST_UPDATE >= UPDATETIME then
		local Duration = getglobal(button:GetName().."_Timer")
		if MPOWA_SAVE[button:GetID()].timer then
			if (not MPOWA_SAVE[button:GetID()].test and (not MPOWA_TEST_ALL)) then
				if MPOWA_SAVE[button:GetID()].cooldown then
					local start, duration = MPowa_GetSpellCooldown(MPOWA_SAVE[button:GetID()].buffname)
					if start > 0 and duration > 0 then
						if MPOWA_SAVE[button:GetID()].hundredth then
							Duration:SetText(string.format("%.2f", duration-(GetTime()-start)))
						else
							Duration:SetText(string.format("%.0f", duration-(GetTime()-start)))
						end
						button.cdtime = duration-(GetTime()-start)
						Duration:Show()
					else
						button:Hide()
						Duration:Hide()
					end
				else
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
						if (not MPOWA_SAVE[button:GetID()].flashanim) then
							if MPOWA_SAVE[button:GetID()].isdebuff then
								buffIndex = GetPlayerBuff(button.bi, "HARMFUL")
							else
								buffIndex = GetPlayerBuff(button.bi, "HELPFUL")
							end
							timeLeft = GetPlayerBuffTimeLeft(buffIndex)
						end
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
			if (name) then
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
							else
								return 0,0
							end
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