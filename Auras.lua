local stf = strfind
local _G = getglobal
local tinsert = table.insert
local tremove = table.remove
local UN = UnitName
local strform = string.format
local flr = floor
local strgfind = string.gfind
local strfind = string.find
local GT = GetTime
local tnbr = tonumber

local UpdateTime, LastUpdate = 0.05, 0

--[[
-- If I just find a way to confirm that the press worked

local castByMe = {}
local oldUseAction = UseAction
UseAction = function(slot, checkCursor, onSelf)
	MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	MPowa_Tooltip:ClearLines()
	MPowa_Tooltip:SetAction(slot)
	castByMe[MPowa_TooltipTextLeft1:GetText()] = GT()
	oldUseAction(slot, checkCursor, onSelf)
end

local oldCastSpellByName = CastSpellByName
CastSpellByName = function(spellName, onSelf)
	castByMe[spellName] = GT()
	oldCastSpellByName(spellName, onSelf)
end

local oldCastSpell = CastSpell
CastSpell = function(spellID, spellbookType)
	local spellName, spellRank = GetSpellName(spellID, spellbookType)
	if MPOWA.auras[spellname] then
		castByMe[spellName] = GT()
	end
	oldCastSpell(spellID, spellbookType)
end
--]]


function MPOWA:OnUpdate(elapsed)
	LastUpdate = LastUpdate + elapsed
	if LastUpdate >= UpdateTime then
		for cat, val in self.NeedUpdate do
			if val then
				local path = MPOWA_SAVE[cat]
				if not self.active[cat] and self:TernaryReturn(cat, "alive", self:Reverse(UnitIsDeadOrGhost("player"))) and self:TernaryReturn(cat, "mounted", self.mounted) and self:TernaryReturn(cat, "incombat", UnitAffectingCombat("player")) and self:TernaryReturn(cat, "inparty", self.party) and self:TernaryReturn(cat, "inraid", UnitInRaid("player")) and self:TernaryReturn(cat, "inbattleground", self.bg) and self:TernaryReturn(cat, "inraidinstance", self.instance) then
					self.frames[cat][4]:Hide()
					if path["cooldown"] then
						local duration = self:GetCooldown(path["buffname"]) or 0
						if path["timer"] then
							if duration > 0 then
								if path["hundredth"] then -- check it
									self.frames[cat][3]:SetText(strform("%.2f", duration))
								else
									self.frames[cat][3]:SetText(flr(duration))
								end
								if path["inverse"] then
									self:FHide(cat)
									self.frames[cat][3]:Hide()
								else
									if path["secsleft"] then
										if duration<=path["secsleftdur"] then
											self:FShow(cat)
											self.frames[cat][3]:Show()
										else
											self:FHide(cat)
											self.frames[cat][3]:Hide()
										end
									else
										self:FShow(cat)
										self.frames[cat][3]:Show()
									end
								end
							else
								if path["inverse"] then
									self:FShow(cat)
								else
									self:FHide(cat)
								end
								self.frames[cat][3]:Hide()
							end
						else
							if path["inverse"] then
								if duration > 0 then
									self:FHide(cat)
								else
									self:FShow(cat)
								end
							else
								if path["secsleft"] then
									if duration<=path["secsleftdur"] then
										self:FShow(cat)
									else
										self:FHide(cat)
									end
								else
									if duration > 0 then
										self:FShow(cat)
									else
										self:FHide(cat)
									end
								end
							end
						end
					else
						self:FShow(cat)
					end
				else
					if path["inverse"] or path["cooldown"] then
						self:FHide(cat)
					end
				end
			end
		end
		for cat, val in self.active do
			if val then
				local path = MPOWA_SAVE[cat]
				local text, count = "", 0
				if (path["unit"] or "player") == "player" then
					count = GetPlayerBuffApplications(val)
				else
					if path["isdebuff"] then
						text, count = UnitDebuff(path["unit"], val)
					else
						text, count = UnitBuff(path["unit"], val)
					end
				end
				self:SetTexture(cat, text, val)
				if count then
					if self.pushed[cat] then
						if count<=1 and self.pushed[cat]>1 then
							count = self.pushed[cat];
						end
					end
				end
				if self:IsStacks(count or 0, cat) then
					local duration = self:GetDuration(val, cat)
					if (count or 0)>1 and not path["hidestacks"] then
						self.frames[cat][4]:SetText(count)
						self.frames[cat][4]:Show()
					else
						self.frames[cat][4]:Hide()
					end
					-- Duration
					if path["timer"] then
						if duration > 0 then
							if path["hundredth"] then -- check it
								self.frames[cat][3]:SetText(strform("%.2f", duration))
							else
								self.frames[cat][3]:SetText(flr(duration))
							end
						else
							self.frames[cat][3]:Hide()
						end
					end
					self:Flash(elapsed, cat, duration)
					if path["inverse"] then
						self:FHide(cat)
					else
						if path["secsleft"] then
							if duration<=path["secsleftdur"] then
								self:FShow(cat)
							else
								self:FHide(cat)
							end
						else
							self:FShow(cat)
						end
					end
				else
					self:FHide(cat)
				end
			else
				if not self.NeedUpdate[cat] then
					self:FHide(cat)
				end
			end
		end
		LastUpdate = 0
	end
end

function MPOWA:SetTexture(key, texture, index)
	local p = MPOWA_SAVE[key]
	if p["texture"] == "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga" then
		if texture and texture ~= "" then
			p["texture"] = texture
			self.frames[key][2]:SetTexture(texture)
		else
			local t = GetPlayerBuffTexture(index)
			if t and t ~= "" then
				p["texture"] = t
				self.frames[key][2]:SetTexture(t)
			end
		end
	end
end

function MPOWA:GetDuration(index, cat)
	local path = MPOWA_SAVE[cat]
	if not path["raidgroupmember"] then -- check this
		if path["friendlytarget"] or path["enemytarget"] then
			local time = GT()
			if (self.activeTimer[cat]+path["targetduration"]-time)<0 then
				self.activeTimer[cat] = time
			end
			return (self.activeTimer[cat]+path["targetduration"]-time)
		else
			return GetPlayerBuffTimeLeft(index) or 0
		end
	else
		return 0
	end
end

function MPOWA:GetCooldown(buff)
	-- Get Spellcooldown
	local start, duration, enabled = GetSpellCooldown(self:GetSpellSlot(buff), "spell")
	-- Get Inventory Cooldown
	if start == 0 and duration == 0 then
		for i=1, 18 do
			start, duration, enable = GetInventoryItemCooldown("player", i)
			local _,_,name = strfind(GetInventoryItemLink("player",i) or "","^.*%[(.*)%].*$")
			if (name) then
				if strfind(strlower(buff), strlower(name)) then
					if duration>2 then
						return ((start or 0)+(duration or 0))-GT()
					else
						return 0
					end
				elseif i == 18 and start == 0 and duration == 0 then
					-- Get Container Item Cooldown
					for p=0, 4 do
						for u=1, GetContainerNumSlots(p) do
							start, duration, enable = GetContainerItemCooldown(p,u)
							_,_,name=string.find(GetContainerItemLink(p,u) or "","^.*%[(.*)%].*$")
							if (not name) then break end
							if strfind(strlower(buff), strlower(name)) then
								if duration>2 then
									return ((start or 0)+(duration or 0))-GT()
								else
									return 0
								end
							elseif p == 4 and u == GetContainerNumSlots(p) then
								if duration>2 then
									return ((start or 0)+(duration or 0))-GT()
								else
									return 0
								end
							else
								return 0
							end
						end
					end
				end
			end
		end
	else
		if duration>2 then
			return ((start or 0)+(duration or 0))-GT()
		else
			return 0
		end
	end
end

function MPOWA:GetSpellSlot(buff)
	local i = 1
	while true do
		local name, rank = GetSpellName(i, "spell")
		if (not name) or strfind(strlower(buff), strlower(name)) then 
			return i
		end
		i = i + 1
	end
end

local BuffExist = {}
function MPOWA:Iterate(unit)
	BuffExist = {}
	if unit=="player" then
		self:IsMounted()
		self:InParty()
		self:InBG()
		self:InInstance()
	end
	
	for cat, val in self.active do
		if (not MPOWA_SAVE[cat]["unit"] and unit=="player") or (MPOWA_SAVE[cat]["unit"]==unit) then
			self.pushed[cat] = false;
		end
	end
	
	if self.Windfury then
		self:Push("Windfury", "player", 42, false, "Windfury")
		self:Push("Windfury Totem", "player", 43, false, "Windfury Totem")
	end
	
	for i=1, 40 do
		local p = i
		local debuff
		MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		MPowa_Tooltip:ClearLines()
		if unit == "player" then
			p = GetPlayerBuff(i-1, "HELPFUL")
			MPowa_Tooltip:SetPlayerBuff(p)
		else
			MPowa_Tooltip:SetUnitBuff(unit, i)
		end
		local buff = MPowa_TooltipTextLeft1:GetText()
		self:Push(buff, unit, p, false, MPowa_TooltipTextLeft2:GetText())
		
		if i<17 then
			MPowa_Tooltip:ClearLines()
			p = i
			if unit == "player" then
				p = GetPlayerBuff(i-1, "HARMFUL")
				MPowa_Tooltip:SetPlayerBuff(p)
			else
				MPowa_Tooltip:SetUnitDebuff(unit, i)
			end
			debuff = MPowa_TooltipTextLeft1:GetText()
			self:Push(debuff, unit, p, true, MPowa_TooltipTextLeft2:GetText())
		end
		MPowa_Tooltip:Hide()
		if not buff and not debuff then break end
	end
	for cat, val in self.active do
		if val then
			if not BuffExist[cat] then
				local p = MPOWA_SAVE[cat]
				if ((p["friendlytarget"] or p["enemytarget"]) and unit=="target") or (not p["raidgroupmember"] and not p["friendlytarget"] and not p["enemytarget"] and unit=="player") or p["raidgroupmember"] then
					self.active[cat] = false
					self.frames[cat][3]:Hide()
					if not p["inverse"] and not p["cooldown"] then
						if p["useendsound"] then
							if p.endsound < 16 then
								PlaySound(self.SOUND[p.endsound], "master")
							else
								PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..self.SOUND[p.endsound], "master")
							end
						end
						self.frames[cat][1]:SetAlpha(p["alpha"])
						self:FHide(cat)
					end
				end
			end
		end
	end
end

function MPOWA:Push(aura, unit, i, isdebuff, debuffdesc)
	if self.auras[aura] then
		for cat, val in self.auras[aura] do
			local path = MPOWA_SAVE[val]
			local bypass = self.active[val]
			if path["isdebuff"]==isdebuff and ((path["secondspecifier"] and path["secondspecifiertext"]==debuffdesc) or not path["secondspecifier"]) then
				if self:TernaryReturn(val, "alive", self:Reverse(UnitIsDeadOrGhost("player"))) and self:TernaryReturn(val, "mounted", self.mounted) and self:TernaryReturn(val, "incombat", UnitAffectingCombat("player")) and self:TernaryReturn(val, "inparty", self.party) and self:TernaryReturn(val, "inraid", UnitInRaid("player")) and self:TernaryReturn(val, "inbattleground", self.bg) and self:TernaryReturn(val, "inraidinstance", self.instance) and not path["cooldown"] then
					BuffExist[val] = true
					if path["enemytarget"] and unit == "target" then
						self.active[val] = i
					elseif path["friendlytarget"] and unit == "target" then
						self.active[val] = i
					elseif path["raidgroupmember"] then -- have to check those vars
						self.active[val] = i
					elseif not path["enemytarget"] and not path["friendlytarget"] and not path["raidgroupmember"] and unit == "player" then
						self.active[val] = i
					end
					if self.pushed[val] then
						self.pushed[val] = self.pushed[val] + 1;
					else
						self.pushed[val] = 1;
					end
					if self.active[val] and not bypass then
						self.activeTimer[val] = GT()
						if tnbr(self.frames[val][1]:GetAlpha())<=0.1 then
							self.frames[val][1]:SetAlpha(tnbr(path["alpha"]))
						end
						if path["usebeginsound"] then
							if path.beginsound < 16 then
								PlaySound(self.SOUND[path.beginsound], "master")
							else
								PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..self.SOUND[path.beginsound], "master")
							end
						end
						if not path["secsleft"] then
							self:FShow(val)
						end
						if path["timer"] then
							self.frames[val][3]:Show()
						end
					end
				end
			end
		end
	end
end

function MPOWA:IsStacks(count, id)
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
		con = strfind(MPOWA_SAVE[id].stacks, "-")
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
	return false
end