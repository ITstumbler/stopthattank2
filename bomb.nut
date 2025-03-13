::applyBombCarrierProperties <- function()
{
    debugPrint("Trying to apply bomb carrier properties")
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

::removeBombCarrierProperties <- function()
{
    debugPrint("Trying to remove bomb carrier properties")
    //If player is giant, revoke their giant privileges
    local scope = activator.GetScriptScope()
    if ("isGiant" in scope) {
        delete scope.isGiant
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
}