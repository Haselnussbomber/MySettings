local _, addon = ...

if (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE) then
    return
end

--Cache global variables
--Lua functions
local select = select
local tonumber = tonumber
--WoW API / Variables
local GetBattlefieldScore = GetBattlefieldScore
local GetClassInfo = GetClassInfo
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumClasses = GetNumClasses
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetRaidRosterInfo = GetRaidRosterInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetUnitName = GetUnitName
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit

local roleIconTextures = {
    TANK = [[Interface\AddOns\ElvUI\media\textures\tank]],
    HEALER = [[Interface\AddOns\ElvUI\media\textures\healer]],
    DAMAGER = [[Interface\AddOns\ElvUI\media\textures\dps]]
}

--From http://forums.wowace.com/showpost.php?p=325677&postcount=5
local specNameToRole = {}
for i = 1, GetNumClasses() do
    local _, class, classID = GetClassInfo(i)
    specNameToRole[class] = {}
    for j = 1, GetNumSpecializationsForClassID(classID) do
        local _, spec, _, _, role = GetSpecializationInfoForClassID(classID, j)
        specNameToRole[class][spec] = role
    end
end

local function GetBattleFieldIndexFromUnitName(name)
    local nameFromIndex
    for index = 1, GetNumBattlefieldScores() do
        nameFromIndex = GetBattlefieldScore(index)
        if nameFromIndex == name then
            return index
        end
    end
    return nil
end

local npcRoleOverride = {
    -- Proving Grounds
    [71828] = "HEALER",  -- Sikari the Mistweaver
    [72218] = "TANK",    -- Oto the Protector
    [72219] = "DAMAGER", -- Ki the Assassin
    [72220] = "DAMAGER", -- Sooli the Survivalist
    [72221] = "DAMAGER", -- Kavan the Arcanist
}

local function getUnitRole(unit, isForced)
    local isInstance, instanceType = IsInInstance()
    if isInstance and instanceType == "pvp" then
        local name = GetUnitName(unit, true)
        local index = GetBattleFieldIndexFromUnitName(name)
        if index then
            local _, _, _, _, _, _, _, _, classToken, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(index)
            if classToken and talentSpec then
                return specNameToRole[classToken][talentSpec]
            end
        end
    end

    local role = UnitIsUnit(unit, "player") and ElvUI[1]:GetPlayerRole() or UnitGroupRolesAssigned(unit)
    if role ~= 'NONE' then
        return role
    end

    -- npc override
    if not UnitIsPlayer(unit) then
        local npcId = tonumber(UnitGUID(unit):match("-(%d+)-%x+$"))
        role = npcId and npcRoleOverride[npcId] or 'NONE'
    end
    if role ~= 'NONE' then
        return role
    end

    -- Details!
    if Details then
        local spec = Details:GetSpecByGUID(UnitGUID(unit))
        if spec then
            role = select(5, GetSpecializationInfoByID(spec))
        end
    end
    if role ~= 'NONE' then
        return role
    end

    -- raid member
    if IsInRaid() then
        local raidIndex = unit:match("^raid(%d+)$")
        if raidIndex ~= nil then
            role = select(12, GetRaidRosterInfo(raidIndex))
        end
    end
    if role ~= 'NONE' then
        return role
    end

    if isForced then
        role = "DAMAGER"
    end
    return role
end

local UpdateRoleIcon = function(self, event)
    local lfdrole = self.GroupRoleIndicator
    if not self.db then return end
    local db = self.db.roleIcon

    if (not db) or (db and not db.enable) or (not UnitIsConnected(self.unit)) then
        lfdrole:Hide()
        return
    end

    local role = getUnitRole(self.unit, self.isForced)

    local shouldHide = ((event == "PLAYER_REGEN_DISABLED" and db.combatHide and true) or false)

    if (self.isForced) or ((role == "DAMAGER" and db.damager) or (role == "HEALER" and db.healer) or (role == "TANK" and db.tank)) then
        lfdrole:SetTexture(roleIconTextures[role])
        if not shouldHide then
            lfdrole:Show()
        else
            lfdrole:Hide()
        end
    else
        lfdrole:Hide()
    end
end

local detailsHooked = false

local hookDetails = function()
    if not ElvUI or not Details or detailsHooked then
        return
    end
    detailsHooked = true

	local E = ElvUI[1]
	local UF = E:GetModule("UnitFrames")

    local locked = false
    local update = function()
        if locked then return end
        locked = true
        C_Timer.After(1, function()
            locked = false
            UF:HeaderUpdateSpecificElement("party", "GroupRoleIndicator")
            UF:HeaderUpdateSpecificElement("raid", "GroupRoleIndicator")
        end)
    end

    hooksecurefunc(Details, "IlvlFromNetwork", update)
    hooksecurefunc(Details, "GuessSpec", update)
    hooksecurefunc(Details, "ReGuessSpec", update)

    if Details.LibGroupInSpecT_UpdateReceived then
        hooksecurefunc(Details, "LibGroupInSpecT_UpdateReceived", update)
    end
end

tinsert(addon.addons.ElvUI, function()
	local E = ElvUI[1]
	local UF = E:GetModule("UnitFrames")

	hooksecurefunc(UF, "Configure_RoleIcon", function(self, frame)
        if frame._injectedRoleIconFix then
            return
        end

        local role = frame.GroupRoleIndicator
        role.Override = UpdateRoleIcon
        self:UnregisterEvent("UNIT_CONNECTION")
        self:RegisterEvent("UNIT_CONNECTION", function(_, event)
            UpdateRoleIcon(frame, event)
        end)

        frame._injectedRoleIconFix = true
    end)

    hookDetails()
end)

addon:RegisterAddonFix("Details", hookDetails)
