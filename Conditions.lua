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

function MPOWA:IsMounted()
	MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	for i=0,31 do
		MPowa_Tooltip:ClearLines()
		MPowa_Tooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL|PASSIVE"))
		local desc = MPowa_TooltipTextLeft2:GetText()
		if (not desc) then break end
		if stf(desc, MPOWA_SCRIPT_MOUNT_100) or stf(desc, MPOWA_SCRIPT_MOUNT_60) then
			self.mounted = true
			return
		end
	end
	self.mounted = false
end

function MPOWA:InParty()
	if GetNumPartyMembers() > 0 or UnitInRaid("player") then
		self.party = true
	end
	self.party = false
end

function MPOWA:InBG()
	for i=1, 4 do
		local status = GetBattlefieldStatus(i)
		if status == "active" then
			self.bg = true
			break
		end
	end
	self.bg = false
end

function MPOWA:InInstance()
	local zone = GetRealZoneText()
	if self.Zones[zone] then
		self.instance = true
	end
	self.instance = false
end