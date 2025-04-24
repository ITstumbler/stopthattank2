::handleBombPickup <- function()
{
    debugPrint("Handling bomb pickup")
    //Don't apply these to giants!!
    local scope = activator.GetScriptScope()
    if ("isGiant" in scope) {
        debugPrint("Bomb carrier is giant, ignoring")
        return
    }

    debugPrint("Bomb carrier is not giant, lets go give them conds and stuff")

    //Apply the identifying bomb carrier cond - used by other map entities to identify bomb carrier
    activator.AddCondEx(65, -1, null)

    //Apply all bomb carrier atributes
    foreach(attribute, value in BOMB_CARRIER_ATTRIBUTES)
    {
        activator.AddCustomAttribute(attribute, value, -1)
    }

    //Count red players - if the amount of players on red is less than MINIMUM_PLAYERS_FOR_BOMB_BUFFS, do not apply conds
    local redPlayerCount = 0
    for (local i = 1; i <= MaxPlayers ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue
        if (player.GetTeam() != 2) continue
        redPlayerCount += 1
    }

    if(redPlayerCount < MINIMUM_PLAYERS_FOR_BOMB_BUFFS) return

    //Check if player is eligible for temporary conds
    local timePickedUp = Time()
    local eligibleForTempConds = true
    if ("lastBombDropTime" in scope) {
        debugPrint("Time between last bomb drop: " + (Time() - scope.lastBombDropTime))
        if((Time() - scope.lastBombDropTime) < BOMB_CARRIER_TEMP_CONDS_DELAY) {
            //Did the player drop the bomb very recently? They're not getting those temp conds again.
            eligibleForTempConds = false
        }
    }

    //Apply all bomb carrier conds
    foreach(condition, duration in BOMB_CARRIER_CONDS)
    {
        if(duration != -1 && !eligibleForTempConds) continue //Blocks temp conds from getting re-applied if ineligible (see above)
        activator.AddCondEx(condition, duration, null)
    }
}

::handleBombDrop <- function()
{
    debugPrint("Handling bomb drop")
    local scope = activator.GetScriptScope()

    if ("isGiant" in scope) {
        debugPrint("Giant just tried dropping the bomb, undo!")

        ClientPrint(activator, 4, "Pick the bomb back up. No one else can pick up the bomb.")

        bombFlag.AcceptInput("ForceResetSilent", null, null, null)
        bombFlag.SetAbsOrigin(activator.GetOrigin())

        // bombFlag.SetOwner(activator)
        // bombFlag.AcceptInput("SetParent", "!activator", activator, activator)
        // bombFlag.AcceptInput("SetParentAttachment", "flag", activator, activator)
        // NetProps.SetPropEntity(bombFlag, "m_hPrevOwner", activator)
        // NetProps.SetPropEntity(activator, "m_hItem", bombFlag)
        // NetProps.SetPropInt(bombFlag, "m_nFlagStatus", 1)

        return
    }
    
    //Remove all bomb carrier conds
    foreach(condition, duration in BOMB_CARRIER_CONDS)
    {
        activator.RemoveCondEx(condition, true)
    }

    //Remove all bomb carrier attributes
    foreach(attribute, value in BOMB_CARRIER_ATTRIBUTES)
    {
        activator.RemoveCustomAttribute(attribute)
    }

    //Update when the player last dropped the bomb, to check if they're eligible for temporary conds (see above)
    scope.lastBombDropTime <- Time()
}

::resetBombOrigin <- function()
{
    //Bomb reset because blue left it on the ground for too long
    //This function resets it to the nearest captured point 
    bombFlag.SetAbsOrigin(bombSpawnOrigin)
    EntFire("gamerules", "PlayVO", "Announcer.MVM_Bomb_Reset")
}