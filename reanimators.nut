//These functions are called by callbacks in round_setup.nut

::spawnReanim <- function(player, userid) 
{
    local scope = player.GetScriptScope()

    local reanim = SpawnEntityFromTable("entity_revive_marker", {
        teamnum = player.GetTeam()
        origin = player.EyePosition()
        max_health = (player.GetMaxHealth() / 2) + (scope.reanimCount * 10)
    })

    reanim.SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    //Store the reanimator so we can KILL IT when the player revives or respawns
    reanimTable[userid] <- reanim

    NetProps.SetPropEntity(reanim, "m_hOwner", player)
    //Sets model
    NetProps.SetPropInt(reanim, "m_nBody", player.GetPlayerClass() - 1)
}