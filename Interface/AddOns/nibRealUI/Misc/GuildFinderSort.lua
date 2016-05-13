----------------------------------------------------------------------------------------
--  Sorts the guild finder list(GuildFinderSorter by Tekkub)
----------------------------------------------------------------------------------------
-- Lua Globals --
local _G = _G

if _G.IsInGuild() then return end
local indexmap

local function guildsort(a, b)
    if a.lvl == b.lvl then
        if a.mem == b.mem then return a.ach > b.ach end
        return a.mem > b.mem
    end
    return a.lvl > b.lvl
end

local oldGetRecruitingGuildInfo = _G.GetRecruitingGuildInfo
function _G.GetRecruitingGuildInfo(index, ...)
    if not indexmap then
        indexmap = {}

        for i = 1, _G.GetNumRecruitingGuilds() do
            local _, level, numMembers, achPoints = oldGetRecruitingGuildInfo(i)
            indexmap[i] = {
                index = i,
                mem = numMembers,
                lvl = level,
                ach = achPoints
            }
        end

        _G.table.sort(indexmap, guildsort)
    end

    return oldGetRecruitingGuildInfo(indexmap[index].index, ...)
end

local f = _G.CreateFrame("Frame")
f:RegisterEvent("LF_GUILD_BROWSE_UPDATED")
f:SetScript("OnEvent", function() indexmap = nil end)
