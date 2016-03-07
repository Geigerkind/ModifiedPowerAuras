MPOWA_VERSION = "v1.1"

-- Local Variables
local ISMOUNTED = false
local INBATTLEGROUND = false
local UPDATETIME = 0.1
local UPDATETIME_TWO = 0.5
local TIME_SINCE_LAST_UPDATE = 0
local TIME_SINCE_LAST_UPDATE_TWO = 0
local MPowa_BuffFrameUpdateTime = 0
local MPowa_BuffFrameFlashTime = 0
local MPowa_BuffFrameFlashState = 0
local MPowa_BUFF_ALPHA_VALUE = 0
local CD_GLOBAL_PREVENT = 2
local f = CreateFrame("Frame", "Test", UIParent)
f:SetScript('OnUpdate', function() Mpowa_OnUpdate(arg1) end)
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

-- Performance
function Mpowa_OnUpdate(t)
	TIME_SINCE_LAST_UPDATE_TWO = TIME_SINCE_LAST_UPDATE_TWO + (t or 0)
	if TIME_SINCE_LAST_UPDATE_TWO >= UPDATETIME_TWO and not MPOWA_TEST_ALL then
		for i=1, MPOWA_CUR_MAX do
			if MPowa_FKNConditions(i) and not MPOWA_SAVE[i].test then
				if (MPOWA_SAVE[i].cooldown) then
					local start, duration = MPowa_GetSpellCooldown(MPOWA_SAVE[i].buffname)
					local cd = (duration or 0)-(GetTime()-(start or 0))
					if (cd>CD_GLOBAL_PREVENT) then
						if MPOWA_SAVE[i].inverse then
							getglobal("TextureFrame"..i):Hide()
							getglobal("TextureFrame"..i.."_Count"):Hide()
						else
							if (not getglobal("TextureFrame"..i):IsVisible()) then
								getglobal("TextureFrame"..i):Show()
								getglobal("TextureFrame"..i.."_Count"):Show()
								if (MPOWA_SAVE[i].usebeginsound) then
									if MPOWA_SAVE[i].beginsound < 16 then
										PlaySound(MPOWA_SOUND[MPOWA_SAVE[i].beginsound], "master")
									else
										PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..MPOWA_SOUND[MPOWA_SAVE[i].beginsound], "master")
									end
								end
							end
						end
					else
						if MPOWA_SAVE[i].inverse then
							if (not getglobal("TextureFrame"..i):IsVisible()) then
								getglobal("TextureFrame"..i):Show()
								if (MPOWA_SAVE[i].usebeginsound) then
									if MPOWA_SAVE[i].beginsound < 16 then
										PlaySound(MPOWA_SOUND[MPOWA_SAVE[i].beginsound], "master")
									else
										PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..MPOWA_SOUND[MPOWA_SAVE[i].beginsound], "master")
									end
								end
							end
						else
							getglobal("TextureFrame"..i):Hide()
							getglobal("TextureFrame"..i.."_Count"):Hide()
						end
					end
				else
					if (Mpowa_IsActive(i)) then
						if (not getglobal("TextureFrame"..i):IsVisible()) then
							getglobal("TextureFrame"..i):Show()
							getglobal("TextureFrame"..i.."_Count"):Show()
							if (MPOWA_SAVE[i].usebeginsound) then
								if MPOWA_SAVE[i].beginsound < 16 then
									PlaySound(MPOWA_SOUND[MPOWA_SAVE[i].beginsound], "master")
								else
									PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..MPOWA_SOUND[MPOWA_SAVE[i].beginsound], "master")
								end
							end
						end
					else
						getglobal("TextureFrame"..i):Hide()
						getglobal("TextureFrame"..i.."_Count"):Hide()
					end
				end
			end
		end
		TIME_SINCE_LAST_UPDATE_TWO = 0
	end
end

function Mpowa_IsActive(p)
	MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	if (MPOWA_SAVE[p].friendlytarget or MPOWA_SAVE[p].enemytarget) then
		if (MPOWA_SAVE[p].isdebuff) then
			for i=1, 16 do
				MPowa_Tooltip:ClearLines()
				MPowa_Tooltip:SetUnitDebuff("target", i)
				local debuff = MPowa_TooltipTextLeft1:GetText()
				if (not debuff) then break end
				if MPowa_FilterName(debuff, p) then return true end
			end
		else
			for i=1, 32 do
				MPowa_Tooltip:ClearLines()
				MPowa_Tooltip:SetUnitBuff("target", i)
				local buff = MPowa_TooltipTextLeft1:GetText()
				if (not buff) then break end
				if MPowa_FilterName(buff, p) then return true end
			end
		end
	elseif (MPOWA_SAVE[p].isdebuff) then
		for i=0, 25 do
			MPowa_Tooltip:ClearLines()
			MPowa_Tooltip:SetPlayerBuff(GetPlayerBuff(i, "HARMFUL"))
			local debuff = MPowa_TooltipTextLeft1:GetText()
			if (not debuff) then break end
			if MPowa_FilterName(debuff, p) then return true end
		end
	else
		for i=0, 50 do
			MPowa_Tooltip:ClearLines()
			MPowa_Tooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
			local buff = MPowa_TooltipTextLeft1:GetText()
			if (not buff) then break end
			if MPowa_FilterName(buff, p) then return true end
		end
	end
	return false
end

function MPowa_Update()
	MPowa_HideAllIcons()
	MPowa_SearchAuras()
end

function MPowa_FKNConditions(i)
	if MPowa_TernaryReturn(i, "alive", MPowa_ReverseBoolean(UnitIsDeadOrGhost("player"))) and MPowa_TernaryReturn(i, "mounted", ISMOUNTED) and MPowa_TernaryReturn(i, "incombat", UnitAffectingCombat("player")) and MPowa_TernaryReturn(i, "inparty", MPowa_IsInParty()) and MPowa_TernaryReturn(i, "inraid", UnitInRaid("player")) and MPowa_TernaryReturn(i, "inbattleground", INBATTLEGROUND) then
		return true
	end	
	return false
end

function MPowa_CreateIcons(i)
	local frame = CreateFrame("Frame", "TextureFrame"..i, UIParent, "MPowa_IconTemplate")
	frame:SetID(i)
	frame:EnableMouse(0)
	getglobal("TextureFrame"..i.."_Icon"):SetTexture(MPOWA_SAVE[i].texture)
	MPowa_ApplyConfig(i)
	frame:Hide()
end

function MPowa_IsMounted()
	ISMOUNTED = false
	MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	for i=0,50 do
		MPowa_Tooltip:ClearLines()
		MPowa_Tooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local desc = MPowa_TooltipTextLeft2:GetText()
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
	MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	
	-- Hiding Icons for enemy debuffs
	for i=1, MPOWA_CUR_MAX do
		local s = MPOWA_SAVE[i]
		if s.enemytarget or s.friendlytarget then
			local button = getglobal("TextureFrame"..i)
			button:Hide()
			button.count = 0
		end
	end
	
	-- Find enemy buffs
	for i=1, 32 do
		MPowa_Tooltip:ClearLines()
		MPowa_Tooltip:SetUnitBuff("target", i)
		local buff = MPowa_TooltipTextLeft1:GetText()
		if buff then
			for p=1, MPOWA_CUR_MAX do
				local s = MPOWA_SAVE[p]
				if MPowa_FilterName(buff, p) and (not s.isdebuff) and (s.enemytarget or s.friendlytarget) then
					local b = getglobal("TextureFrame"..p)
					if s.test or MPOWA_TEST_ALL then s.test = false; MPOWA_TEST_ALL = false end
					b.count = b.count + 1
					MPowa_TextureFrame_Update(i, b)
				end
			end
		else
			break
		end
	end
	
	for i=1, 16 do
		MPowa_Tooltip:ClearLines()
		MPowa_Tooltip:SetUnitDebuff("target", i)
		local debuff = MPowa_TooltipTextLeft1:GetText()
		if debuff then
			for p=1, MPOWA_CUR_MAX do
				local s = MPOWA_SAVE[p]
				if MPowa_FilterName(debuff, p) and s.isdebuff and (s.enemytarget or s.friendlytarget) then
					local b = getglobal("TextureFrame"..p)
					if s.test or MPOWA_TEST_ALL then s.test = false; MPOWA_TEST_ALL = false end
					b.count = b.count + 1
					MPowa_TextureFrame_Update(i, b)
				end
			end
		else
			break
		end
	end
	
	MPowa_Tooltip:Hide()
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
	for i=0, 50 do
		-- HELPFUL
		MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		MPowa_Tooltip:ClearLines()
		MPowa_Tooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL"))
		local buff = MPowa_TooltipTextLeft1:GetText()
		if buff then
			for p=1, MPOWA_CUR_MAX do
				if MPowa_FilterName(buff, p) and (not MPOWA_SAVE[p].isdebuff) and (not MPOWA_SAVE[p].raidgroupmember) then
					if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false MPOWA_TEST_ALL = false end
					getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
					MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
					if (MPOWA_SAVE[p].inverse) then
						getglobal("TextureFrame"..p):Hide()
					end
					break
				end
			end
		end
		
		if i <= 25 then
			-- HARMFUL
			MPowa_Tooltip:ClearLines()
			MPowa_Tooltip:SetPlayerBuff(GetPlayerBuff(i, "HARMFUL"))
			local debuff = MPowa_TooltipTextLeft1:GetText()
			if debuff then
				for p=1, MPOWA_CUR_MAX do
					if MPowa_FilterName(debuff, p) and MPOWA_SAVE[p].isdebuff and (not MPOWA_SAVE[p].raidgroupmember) then
						if MPOWA_SAVE[p].test or MPOWA_TEST_ALL then MPOWA_SAVE[p].test = false MPOWA_TEST_ALL = false end
						getglobal("TextureFrame"..p).count = getglobal("TextureFrame"..p).count + 1
						MPowa_TextureFrame_Update(i, getglobal("TextureFrame"..p))
						if (MPOWA_SAVE[p].inverse) then
							getglobal("TextureFrame"..p):Hide()
						end
						break
					end
				end
			end
		end
		
		MPowa_Tooltip:Hide()
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
			
			MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
			for t=1, 32 do
				MPowa_Tooltip:ClearLines()
				if MPOWA_SAVE[u].isdebuff then
					if t > 17 then break end
					MPowa_Tooltip:SetUnitDebuff(arg1, t)
				else
					MPowa_Tooltip:SetUnitBuff(arg1, t)
				end
				local tauraname = MPowa_TooltipTextLeft1:GetText()
				if (not tauraname) then break end
				if MPowa_FilterName(tauraname, u) then
					button.rgcon = arg1
					button.count = button.count + 1
					MPowa_TextureFrame_Update(t, button)
					break
				end
			end
			MPowa_Tooltip:Hide()
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
						MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
						for t=1, 32 do
							MPowa_Tooltip:ClearLines()
							if MPOWA_SAVE[u].isdebuff then
								if t > 16 then break end
								MPowa_Tooltip:SetUnitDebuff("raid"..z, t)
							else
								MPowa_Tooltip:SetUnitBuff("raid"..z, t)
							end
							local tauraname = MPowa_TooltipTextLeft1:GetText()
							if (not tauraname) then break end
							if MPowa_FilterName(tauraname, u) then
								button.rgcon = "raid"..z
								button.count = button.count + 1
								MPowa_TextureFrame_Update(t, button)
								break
							end
						end
					end
				end
			elseif UnitInParty("player") then
				for z=1, 4 do
					if UnitName("party"..z) == MPowa_GetUnitName(MPOWA_SAVE[u].buffname) then
						MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
						for t=1, 32 do
							MPowa_Tooltip:ClearLines()
							if MPOWA_SAVE[u].isdebuff then
								if t > 16 then break end
								MPowa_Tooltip:SetUnitDebuff("party"..z, t)
							else
								MPowa_Tooltip:SetUnitBuff("party"..z, t)
							end
							local tauraname = MPowa_TooltipTextLeft1:GetText()
							if (not tauraname) then break end
							if MPowa_FilterName(tauraname, u) then
								button.rgcon = "party"..z
								button.count = button.count + 1
								MPowa_TextureFrame_Update(t, button)
								break
							end
						end
					end
				end
			end
		end
		MPowa_Tooltip:Hide()
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
	local butId = button:GetID()
	if MPowa_FKNConditions(butId) then
		local buffIndex, s = nil, MPOWA_SAVE[butId] 
		if s.isdebuff then
			if ((s.enemytarget and UnitCanAttack("player", "target")) or (s.friendlytarget and (not UnitCanAttack("player", "target")))) or s.raidgroupmember then
				buffIndex = 0
			else
				buffIndex = GetPlayerBuff(bi, "HARMFUL")
			end
		else
			if ((s.enemytarget and UnitCanAttack("player", "target")) or (s.friendlytarget and (not UnitCanAttack("player", "target")))) or s.raidgroupmember then
				buffIndex = 0
			else
				buffIndex = GetPlayerBuff(bi, "HELPFUL")
			end
		end
		if (buffIndex > -1) or bi == 99 then
			local buffApplications = GetPlayerBuffApplications(buffIndex)
			if (MPowa_IsStacks(buffApplications, butId) or MPowa_IsStacks(button.count, butId)) then
				local Icon = getglobal(button:GetName().."_Icon")
				local Count = getglobal(button:GetName().."_Count")
				
				Icon:SetTexture(MPowa_GetTexture(s, bi, button, buffIndex))
				
				-- Enabling Count for certain buffs and Holy Strength
				if (button.count > 1 or buffApplications > 1) then
					if button.count > 1 then
						Count:SetText(button.count)
					else
						Count:SetText(buffApplications)
					end
					Count:Show()
				else
					Count:Hide()
				end
				
				button.bi = bi
				
				if (button.removed+0.5 < GetTime()) and s.usebeginsound then
					if s.beginsound < 16 then
						PlaySound(MPOWA_SOUND[s.beginsound], "master")
					else
						PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..MPOWA_SOUND[s.beginsound], "master")
					end
				end
				
				button:Show()
			end
		end
	end
end

function MPowa_GetTexture(s, bi, button, buffIndex)
	local t
	if s.texture == "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga" then
		if s.enemytarget or s.friendlytarget then
			local a,b,c
			if s.isdebuff then
				a, b, c = UnitDebuff("target", bi)
			else
				a, b = UnitBuff("target", bi)
			end
			t = a
		else
			if s.raidgroupmember then
				if s.isdebuff then
					a, b, c = UnitDebuff(button.rgcon, bi)
				else
					a, b = UnitBuff(button.rgcon, bi)
				end
				t = a
			else
				t = GetPlayerBuffTexture(buffIndex)
			end
		end
	else
		t = s.texture
	end
	return t
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
		if con then
			local amount1 = tonumber(strsub(MPOWA_SAVE[id].stacks, 1, con-1))
			local amount2 = tonumber(strsub(MPOWA_SAVE[id].stacks, con+1))
			if con and amount1 and amount2 and ((count >= amount1 and count <= amount2) or (count >= amount2 and count <= amount1)) then
				return true
			end
		else
			return false
		end
	end
end

function MPowa_TextureFrame_OnUpdate(elapsed, button)
	local buffIndex, timeLeft, butId = 0, 0, button:GetID()
	local s = MPOWA_SAVE[butId]
	local time = GetTime()
	if s.flashanim then
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
		
		if s.cooldown then
			if (button.cdtime) then
				timeLeft = button.cdtime
			end
		else
			if s.isdebuff then
				buffIndex = GetPlayerBuff(button.bi, "HARMFUL")
			else
				buffIndex = GetPlayerBuff(button.bi, "HELPFUL")
			end
			timeLeft = GetPlayerBuffTimeLeft(buffIndex)
		end
		if (not timeLeft) then timeLeft = 0 end
		if timeLeft < s.flashanimstart then
			button:SetAlpha(MPowa_BUFF_ALPHA_VALUE);
		else
			button:SetAlpha(s.alpha)
		end
	else
		button:SetAlpha(s.alpha)
	end

	TIME_SINCE_LAST_UPDATE = TIME_SINCE_LAST_UPDATE + elapsed
	if TIME_SINCE_LAST_UPDATE >= UPDATETIME and button.bi then
		local Duration = getglobal(button:GetName().."_Timer")
		if s.timer then
			if (not s.test and (not MPOWA_TEST_ALL)) then
				if s.cooldown then
					local start, duration = MPowa_GetSpellCooldown(s.buffname)
					if (not start) or (not duration) then return end -- Has to be handled in GetSpellCooldown
					if start > 0 and duration > 0 then
						if s.hundredth then
							Duration:SetText(string.format("%.2f", duration-(time-start)))
						else
							Duration:SetText(ceil(duration-(time-start)))
						end
						button.cdtime = duration-(time-start)
						if (s.inverse) then
							button:Hide()
						else
							button:Show()
						end
					else
						if (s.inverse) then
							button:Show()
						else
							button:Hide()
						end
						Duration:Hide()
					end
				else
					if s.enemytarget or s.friendlytarget then
						timeLeft = 0
						if (not button.tdurationstart) then
							button.tduration = s.targetduration
							button.tdurationstart = time
						end
						if ((button.tdurationstart+button.tduration) >= time) and button.tduration ~= 0 then
							Duration:Show()
							if s.timer and s.hundredth then
								Duration:SetText(string.format("%.2f", (-time+button.tduration+button.tdurationstart)))
							else
								Duration:SetText(ceil(-time+button.tduration+button.tdurationstart))
							end
						else
							Duration:SetText("")
							button.tdurationstart = nil
						end
					else
						if (not s.flashanim) then
							if s.isdebuff then
								buffIndex = GetPlayerBuff(button.bi, "HARMFUL")
							else
								buffIndex = GetPlayerBuff(button.bi, "HELPFUL")
							end
							timeLeft = GetPlayerBuffTimeLeft(buffIndex)
						end
					end
					Duration:Show()
					if s.hundredth and timeLeft > 0 then
						Duration:SetText(string.format("%.2f", timeLeft))
					elseif (not s.hundredth) and timeLeft > 0 then
						Duration:SetText(ceil(timeLeft))
					end
					if timeLeft == 0 and (not s.enemytarget) and (not s.friendlytarget) then Duration:SetText("") end
					button.timeLeft = timeLeft
				end	
			else
				Duration:Show()
				if s.hundredth then
					Duration:SetText(string.format("%.2f", (random(1,23)+random(1,60)/100)))
				else
					Duration:SetText(ceil(random(1,23)+random(1,60)/100))
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