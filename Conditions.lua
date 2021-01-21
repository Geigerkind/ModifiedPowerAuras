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
	local desc
	for i=0,31 do
		MPowa_Tooltip:ClearLines()
		MPowa_Tooltip:SetPlayerBuff(GetPlayerBuff(i, "HELPFUL|PASSIVE"))
		desc = MPowa_TooltipTextLeft2:GetText()
		if (not desc) then break end
		if stf(desc, MPOWA_SCRIPT_MOUNT_100) or stf(desc, MPOWA_SCRIPT_MOUNT_60) then
			self.mounted = true
			return
		end
	end
	self.mounted = false
end

local UnitInParty = UnitInParty
function MPOWA:InParty()
	return GetNumPartyMembers() > 0
end

function MPOWA:InBG()
	local status
	for i=1, 4 do
		status = GetBattlefieldStatus(i)
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