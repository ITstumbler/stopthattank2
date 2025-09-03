//Prevent dead and currently being revived players from being revived by constantly setting their state to 2
function root::addReanimatorThink()
{
    gamerules.ValidateScriptScope()
    local scope = gamerules.GetScriptScope()
    scope.reanimatorThink <- function()
    {
        foreach(userid, reanim in reanimTable) {
            local player = GetPlayerFromUserID(userid)
            local playerScope = player.GetScriptScope()
            // if(playerScope.isReviving) NetProps.SetPropInt(player, "mShared.m_nPlayerState", 3)
            NetProps.SetPropInt(player, "mShared.m_nPlayerState", 3)
        }
        return -1
    }

    AddThinkToEnt(gamerules, "reanimatorThink")
}

// addReanimatorThink()

//These functions are called by callbacks in round_setup.nut

function root::spawnReanim(player, userid) 
{
    local scope = player.GetScriptScope()

    local reanim = SpawnEntityFromTable("entity_revive_marker", {
        teamnum = player.GetTeam()
        origin = player.EyePosition()
        max_health = (player.GetMaxHealth() / 2) + (scope.reanimCount * 10)
    })

    //Store the reanimator so we can KILL IT when the player revives or respawns
    reanimTable[userid] <- reanim

    NetProps.SetPropEntity(reanim, "m_hOwner", player)
    //Sets model
    NetProps.SetPropInt(reanim, "m_nBody", player.GetPlayerClass() - 1)
}